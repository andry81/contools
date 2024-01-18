''' Read a path property values.

''' USAGE:
'''   read_path_props.vbs [-n] [-url-encode] [-x] [--] <PropertyPattern> <Path>

''' DESCRIPTION:
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''
'''   -n
'''     Print only not empty properties.
'''
'''   -url-encode
'''     URL encode property value characters in form of `%NN` in case if
'''     ASCII value < 32 OR > 127 OR = &H25 OR = &H3F, where:
'''       `&H3F` - is not printable character which can not pass through the
'''                stdout redirection.
'''       `&H25` - `%`.
'''
'''   -x
'''     Use `ExtendedPropery` method (O(1)) instead of enumeration with
'''     `GetDetailsOf` (O(N)).
'''
'''   <PropertyPattern>
'''     List of property names or property indexes to read, separated by `|`
'''     character.
'''     Property indexes has effect only when `-extended-prop` is not used.
'''
'''   <Path>
'''     Path to read.

''' Examples:
'''   1. >
'''      cscript //nologo read_path_props.vbs "File version|Product version" "c:\windows\system32\cmd.exe"
'''   2. >
'''      cscript //nologo read_path_props.vbs "158|280" "c:\windows\system32\cmd.exe"
'''   3. >
'''      cscript //nologo read_path_props.vbs -x "FileVersion|ProductVersion" "c:\windows\system32\cmd.exe"
'''   4. Read `System.Software.ProductName`:
'''      https://learn.microsoft.com/en-us/windows/win32/properties/props-system-software-productname
'''      >
'''      cscript //nologo read_path_props.vbs -x "{0CEF7D53-FA64-11D1-A203-0000F81FEDEE} 8" "c:\windows\system32\cmd.exe"
'''   5. Read the Word document `Title` and `Authors`:
'''      https://learn.microsoft.com/en-us/windows/win32/shell/shellfolderitem-extendedproperty
'''      >
'''      cscript //nologo read_path_props.vbs -x "{F29F85E0-4FF9-1068-AB91-08002B27B3D9} 2|{F29F85E0-4FF9-1068-AB91-08002B27B3D9} 8" "c:\Windows\System32\MSDRM\MsoIrmProtector.doc"

Sub PrintOrEchoLine(str)
  On Error Resume Next
  WScript.stdout.WriteLine str
  If err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

Sub PrintOrEchoErrorLine(str)
  On Error Resume Next
  WScript.stderr.WriteLine str
  If err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim PrintNotEmpty : PrintNotEmpty = False
Dim UrlEncode : UrlEncode = False
Dim UseExtendedProperty : UseExtendedProperty = False

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Mid(arg, 1, 1) = "-" Then
      If arg = "-n" Then
        PrintNotEmpty = True
      ElseIf arg = "-url-encode" Then
        UrlEncode = True
      ElseIf arg = "-x" Then
        UseExtendedProperty = True
      Else
        PrintOrEchoErrorLine WScript.ScriptName & ": error: unknown flag: `" & arg & "`"
        WScript.Quit 255
      End If
    Else
      ExpectFlags = False

      If arg = "--" Then Exit Do
    End If
  End If

  If Not ExpectFlags Then
    cmd_args(j) = arg

    j = j + 1
  End If
Loop While False : Next

ReDim Preserve cmd_args(j - 1)

' MsgBox Join(cmd_args, " ")

Dim cmd_args_ubound : cmd_args_ubound = UBound(cmd_args)

If cmd_args_ubound < 0 Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <PropertyPattern> argument is not defined."
  WScript.Quit 2
End If

If cmd_args_ubound < 1 Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <Path> argument is not defined."
  WScript.Quit 1
End If

Dim PropertyPattern : PropertyPattern = cmd_args(0)
Dim Path : Path = cmd_args(1)

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

Dim PathAbs : PathAbs = objFS.GetAbsolutePathName(Path) ' CAUTION: can alter a path character case if path exists

' remove `\\?\` prefix
If Left(PathAbs, 4) = "\\?\" Then
  PathAbs = Mid(PathAbs, 5)
End If

' test on path existence including long path
Dim IsFileExist : IsFileExist = objFS.FileExists("\\?\" & PathAbs)
Dim IsFolderExist : IsFolderExist = False
If Not IsFileExist Then
  IsFolderExist = objFS.FolderExists("\\?\" & PathAbs)
End If
If (Not IsFileExist) And (Not IsFolderExist) Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: path does not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & PathAbs & "`"
  WScript.Quit 1
End If

Dim PathToOpen

' test on long path existence
If (IsFileExist And objFS.FileExists(PathAbs)) Or (IsFolderExist And objFS.FolderExists(PathAbs)) Then
  ' is not long path
  PathToOpen = PathAbs
Else
  ' translate into short path

  If IsFileExist Then
    ' WORKAROUND:
    '   We use `\\?\` to bypass `GetFile` error: `File not found`.
    Dim File : Set File = objFS.GetFile("\\?\" & PathAbs)
    Dim FileShortPath : FileShortPath = File.ShortPath
    If Left(FileShortPath, 4) = "\\?\" Then
      FileShortPath = Mid(FileShortPath, 5)
    End If
    PathToOpen = FileShortPath
  ElseIf IsFolderExist Then ' just in case
    ' WORKAROUND:
    '   We use `\\?\` to bypass `GetFolder` error: `Path not found`.
    Dim Folder : Set Folder = objFS.GetFolder("\\?\" & PathAbs & "\")
    Dim FolderShortPath : FolderShortPath = Folder.ShortPath
    If Left(FolderShortPath, 4) = "\\?\" Then
      FolderShortPath = Mid(FolderShortPath, 5)
    End If
    PathToOpen = FolderShortPath
  End If
End If

Dim objShell : Set objShell = CreateObject("Shell.Application")

Dim objNamespace : Set objNamespace = objShell.Namespace(objFS.GetFolder(objFS.GetParentFolderName(PathToOpen)).Path)
Dim objFile : Set objFile = objNamespace.ParseName(objFS.GetFileName(PathToOpen))

If Not (objFile Is Nothing) Then
  Dim PropertyArr : PropertyArr = Split(PropertyPattern, "|", -1, vbTextCompare)
  Dim PropertyArrUbound : PropertyArrUbound = UBound(PropertyArr)
  Dim PropertyName, IsPropNameNum

  Dim FilePropName, FilePropValue, FilePropEncodedValue, Char, CharAsc, CharHex
  Dim FilePropIndex
  Dim FilePropIndexStr

  For j = 0 To PropertyArrUbound
    PropertyName = PropertyArr(j)

    If UseExtendedProperty Then
      FilePropValue = objFile.ExtendedProperty(PropertyName)

      If (Not IsNull(FilePropValue)) And ((Not PrintNotEmpty) Or Len(FilePropValue)) Then
        If UrlEncode Then
          FilePropEncodedValue = ""

          For i = 1 To Len(FilePropValue)
            Char = Mid(FilePropValue, i, 1)
            CharAsc = Asc(Char)

            ' NOTE:
            '   `&H3F` - is not printable character which can not pass through the stdout redirection.
            '   `&H25` - `%`.
            If CharAsc < 32 Or CharAsc > 127 Or CharAsc = &H25 Or CharAsc = &H3F Then
              CharHex = Hex(CharAsc)
              FilePropEncodedValue = FilePropEncodedValue & "%" & Left("00", 2 - Len(CStr(CharHex))) & CStr(CharHex)
            Else
              FilePropEncodedValue = FilePropEncodedValue & Char
            End If
          Next

          FilePropValue = FilePropEncodedValue
        End If

        PrintOrEchoLine PropertyName & "=`" & FilePropValue & "`"
      End If
    Else
      IsPropNameNum = IsNumeric(PropertyName)

      ' 65535 - maximum
      For FilePropIndex = 0 To 65535 : Do ' empty `Do-Loop` to emulate `Continue`
        FilePropName = objNamespace.GetDetailsOf(objFile.Name, FilePropIndex)

        If Not (Len(FilePropName) > 0) Then Exit For

        If IsPropNameNum Then
          If Int(PropertyName) <> FilePropIndex Then Exit Do ' Continue
        Else
          If PropertyName <> FilePropName Then Exit Do ' Continue
        End If

        FilePropValue = objNamespace.GetDetailsOf(objFile, FilePropIndex)

        If (Not IsNull(FilePropValue)) And ((Not PrintNotEmpty) Or Len(FilePropValue)) Then
          FilePropIndexStr = CStr(FilePropIndex)

          If UrlEncode Then
            FilePropEncodedValue = ""

            For i = 1 To Len(FilePropValue)
              Char = Mid(FilePropValue, i, 1)
              CharAsc = Asc(Char)

              ' NOTE:
              '   `&H3F` - is not printable character which can not pass through the stdout redirection.
              '   `&H25` - `%`.
              If CharAsc < 32 Or CharAsc > 127 Or CharAsc = &H25 Or CharAsc = &H3F Then
                CharHex = Hex(CharAsc)
                FilePropEncodedValue = FilePropEncodedValue & "%" & Left("00", 2 - Len(CStr(CharHex))) & CStr(CharHex)
              Else
                FilePropEncodedValue = FilePropEncodedValue & Char
              End If
            Next

            FilePropValue = FilePropEncodedValue
          End If

          PrintOrEchoLine "[" & Left("000", 3 - Len(FilePropIndexStr)) & FilePropIndexStr & "] " & FilePropName & "=`" & FilePropValue & "`"
        End If

        Exit For
      Loop While False : Next
    End If
  Next
End If
