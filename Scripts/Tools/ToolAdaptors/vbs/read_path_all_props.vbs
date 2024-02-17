''' Read a path all property values.

''' USAGE:
'''   read_path_all_props.vbs
'''     [-v[al-only]]
'''     [-v[al-decor-only] | -vd]
'''     [-val-null | -vnull]
'''     [-val-notempty | -n]
'''     [-i[gnore-unexist]]
'''     [-u[rl-encode]]
'''     [-line-return | -lr]
'''     [--]
'''       <Path>

''' DESCRIPTION:
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''
'''   -v[al-only]
'''     Print only undecorated property value instead of decorated assignment
'''     expression.
'''     Has no effect if `-val-null` is used.
'''     Has effect if `-val-notempty` is used.
'''     Has no effect if `-val-decor-only` is used.
'''
'''   -v[al-decor-only] | -vd
'''     Print only decorated property value instead of decorated assignment
'''     expression.
'''     Has effect if `-val-null` is used.
'''     Has effect if `-val-notempty` is used.
'''
'''   -val-null | -vnull
'''     Print Null values as part of decorated assignment expression:
'''       ...=<null>
'''     By default Null values does skip to print.
'''
'''   -val-notempty | -n
'''     Print only not empty property values.
'''     Has effect only for not Null values.
'''
'''   -i[gnore-unexist]
'''     Ignores unexisted path.
'''     Useful in case of an unlinked or unresolved path with partial property
'''     list.
'''
'''   -u[rl-encode]
'''     URL encode property value characters in form of `%NN` in case if
'''     ASCII value < 32 OR > 127 OR = &H25 OR = &H3F, where:
'''       `&H3F` - is not printable character which may not pass through the
'''                stdout redirection.
'''       `&H25` - `%`.
'''
'''   -line-return | -lr
'''     Return on first line print.
'''     Useful to skip iteration over property list.
'''
'''   <Path>
'''     Path to read.

''' Error codes:
'''   255 - unspecified error
'''   128 - <Path> is not convertible to ShellFolderItem
'''   1   - <Path> is not defined or not exist
'''   0   - Success

''' NOTE:
'''   Script can read unlinked or unresolvable paths. In that case you must use
'''   `-ignore-unexist` flag.

''' CAUTION:
'''   Script may return a lozalized name of a property. To read a particular
'''   not lozalized property name you must use another script -
'''   `read_path_props.vbs` with `-x` flag.

''' Examples:
'''   1. >
'''      cscript //nologo read_path_all_props.vbs -n "c:\windows\system32\cmd.exe"
'''   2. >
'''      cscript //nologo read_path_all_props.vbs -n "...\shortcut.lnk"
'''   3. >
'''      cscript //nologo read_path_all_props.vbs -n "c:\Windows\System32\MSDRM\MsoIrmProtector.doc"

Function IsNothing(obj)
  If IsEmpty(obj) Then
    IsNothing = True
    Exit Function
  End If
  If obj Is Nothing Then
    IsNothing = True
  Else
    IsNothing = False
  End If
End Function

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

Dim PrintValueOnly : PrintValueOnly = False
Dim PrintDecorValueOnly : PrintDecorValueOnly = False
Dim PrintValueNull : PrintValueNull = False
Dim PrintValueNotEmptyOnly : PrintValueNotEmptyOnly = False
Dim IgnoreUnexist : IgnoreUnexist = False
Dim UrlEncode : UrlEncode = False
Dim LineReturn : LineReturn = False

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Mid(arg, 1, 1) = "-" Then
      If arg = "-val-only" Or arg = "-v" Then
        If Not PrintValueNull Then ' "has no effect"
          PrintValueOnly = True
        End If
      ElseIf arg = "-val-decor-only" Or arg = "-vd" Then
        PrintDecorValueOnly = True
      ElseIf arg = "-val-null" Or arg = "-vnull" Then
        PrintValueOnly = False ' "has no effect"
        PrintValueNull = True
      ElseIf arg = "-val-notempty" Or arg = "-n" Then
        PrintValueNotEmptyOnly = True
      ElseIf arg = "-ignore-unexist" Or arg = "-i" Then
        IgnoreUnexist = True
      ElseIf arg = "-url-encode" Or arg = "-u" Then
        UrlEncode = True
      ElseIf arg = "-line-return" Or arg = "-lr" Then
        LineReturn = True
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
If (Not IgnoreUnexist) And (Not IsFileExist) And (Not IsFolderExist) Then
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
  ElseIf IgnoreUnexist Then
    PathToOpen = PathAbs
  End If
End If

Dim objShell : Set objShell = CreateObject("Shell.Application")

Dim ParentPath : ParentPath = objFS.GetParentFolderName(PathToOpen)

Dim objNamespace, objFile

If Len(ParentPath) > 0 Then
  Set objNamespace = objShell.Namespace(ParentPath)
  Set objFile = objNamespace.ParseName(objFS.GetFileName(PathToOpen))
End if

If IsNothing(objFile) Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: path has no parent namespace." & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & PathAbs & "`"
  WScript.Quit 128
End If

Dim FilePropName, FilePropValue, FilePropEncodedValue, Char, CharAsc, CharHex
Dim FilePropIndex : FilePropIndex = 0
Dim FilePropIndexStr

' 65535 - maximum
For FilePropIndex = 0 To 65535 : Do ' empty `Do-Loop` to emulate `Continue`
  FilePropName = objNamespace.GetDetailsOf(objFile.Name, FilePropIndex)

  If Not (Len(FilePropName) > 0) Then Exit For

  FilePropValue = objNamespace.GetDetailsOf(objFile, FilePropIndex)

  ' CAUTION:
  '   `Len(...) > 0` is not equal here to `Not IsEmpty(...)`:
  '   https://stackoverflow.com/questions/40600276/using-empty-vs-to-define-or-test-a-variable-in-vbscript/40600539#40600539
  '
  If (PrintValueNull Or Not IsNull(FilePropValue)) And ((Not PrintValueNotEmptyOnly) Or Len(FilePropValue) > 0) Then
    FilePropIndexStr = CStr(FilePropIndex)

    If UrlEncode And Len(FilePropValue) > 0 Then
      FilePropEncodedValue = ""

      For i = 1 To Len(FilePropValue)
        Char = Mid(FilePropValue, i, 1)
        CharAsc = Asc(Char)

        ' NOTE:
        '   `&H3F` - is not printable character which may not pass through the stdout redirection.
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

    If (Not PrintValueOnly) And (Not PrintDecorValueOnly) Then
      If Not IsNull(FilePropValue) Then
        PrintOrEchoLine "[" & Left("000", 3 - Len(FilePropIndexStr)) & FilePropIndexStr & "] " & FilePropName & "=`" & FilePropValue & "`"
      Else
        PrintOrEchoLine "[" & Left("000", 3 - Len(FilePropIndexStr)) & FilePropIndexStr & "] " & FilePropName & "=<null>"
      End If
    Else
      If PrintDecorValueOnly Then
        If Not IsNull(FilePropValue) Then
          PrintOrEchoLine "`" & FilePropValue & "`"
        Else
          PrintOrEchoLine "<null>"
        End If
      Else
        PrintOrEchoLine "" & FilePropValue
      End If
    End If

    If LineReturn Then Exit For
  End If
Loop While False : Next
