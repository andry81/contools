''' Read a path all property values.

''' USAGE:
'''   read_path_all_props.vbs [-n] [-e] [--] <Path>

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
'''   <Path>
'''     Path to read.

''' Examples:
'''   1. >
'''      cscript //nologo read_path_all_props.vbs -n "c:\windows\system32\cmd.exe"
'''   2. >
'''      cscript //nologo read_path_all_props.vbs -n "c:\Windows\System32\MSDRM\MsoIrmProtector.doc"

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
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <Path> argument is not defined."
  WScript.Quit 1
End If

Dim Path : Path = cmd_args(0)

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
  Dim FilePropName, FilePropValue, FilePropEncodedValue, Char, CharAsc, CharHex
  Dim FilePropIndex : FilePropIndex = 0
  Dim FilePropIndexStr

  ' 65535 - maximum
  For FilePropIndex = 0 To 65535 : Do ' empty `Do-Loop` to emulate `Continue`
    FilePropName = objNamespace.GetDetailsOf(objFile.Name, FilePropIndex)

    If Not (Len(FilePropName) > 0) Then Exit For

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
  Loop While False : Next
End If
