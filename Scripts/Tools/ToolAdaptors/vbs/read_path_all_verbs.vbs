''' Read a path all verb values.

''' USAGE:
'''   read_path_all_props.vbs
'''     [-i[gnore-unexist]]
'''     [-line-return | -lr]
'''     [--]
'''       <Path>

''' DESCRIPTION:
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''
'''   -i[gnore-unexist]
'''     Ignores unexisted path.
'''     Useful in case of an unlinked or unresolved path with partial property
'''     list.
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

''' NOTE:
'''   Script may return a localized name of a verb.

''' Examples:
'''   1. >
'''      cscript //nologo read_path_all_verbs.vbs "c:\windows\system32\cmd.exe"
'''   2. >
'''      cscript //nologo read_path_all_verbs.vbs "...\shortcut.lnk"
'''   3. >
'''      cscript //nologo read_path_all_verbs.vbs "c:\Windows\System32\MSDRM\MsoIrmProtector.doc"

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

Function IsEmptyArg(args, index)
  ''' Based on: https://stackoverflow.com/questions/4466967/how-can-i-determine-if-a-dynamic-array-has-not-be-dimensioned-in-vbscript/4469121#4469121
  On Error Resume Next
  Dim args_ubound : args_ubound = UBound(args)
  If Err = 0 Then
    If args_ubound >= index Then
      ' CAUTION:
      '   Must be a standalone condition.
      '   Must be negative condition in case of an invalid `index`
      If Not (Len(args(index)) > 0) Then
        IsEmptyArg = True
      Else
        IsEmptyArg = False
      End If
    Else
      IsEmptyArg = True
    End If
  Else
    ' Workaround for `WScript.Arguments`
    Err.Clear
    Dim num_args : num_args = args.count
    If Err = 0 Then
      If index < num_args Then
        ' CAUTION:
        '   Must be a standalone condition.
        '   Must be negative condition in case of an invalid `index`
        If Not (Len(args(index)) > 0) Then
          IsEmptyArg = True
        Else
          IsEmptyArg = False
        End If
      Else
        IsEmptyArg = True
      End If
    Else
      IsEmptyArg = True
    End If
  End If
  On Error Goto 0
End Function

Function FixStrToPrint(str)
  Dim new_str : new_str = ""
  Dim i, Char, CharAsc

  For i = 1 To Len(str)
    Char = Mid(str, i, 1)
    CharAsc = Asc(Char)

    ' NOTE:
    '   `&H3F` - is not printable unicode origin character which can not pass through the stdout redirection.
    If CharAsc <> &H3F Then
      new_str = new_str & Char
    Else
      new_str = new_str & "?"
    End If
  Next

  FixStrToPrint = new_str
End Function

Sub PrintOrEchoLine(str)
  On Error Resume Next
  WScript.stdout.WriteLine str
  If err = 5 Then ' Access is denied
    WScript.stdout.WriteLine FixStrToPrint(str)
  ElseIf err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

Sub PrintOrEchoErrorLine(str)
  On Error Resume Next
  WScript.stderr.WriteLine str
  If err = 5 Then ' Access is denied
    WScript.stderr.WriteLine FixStrToPrint(str)
  ElseIf err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim IgnoreUnexist : IgnoreUnexist = False
Dim LineReturn : LineReturn = False

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Mid(arg, 1, 1) = "-" Then
      If arg = "-ignore-unexist" Or arg = "-i" Then
        IgnoreUnexist = True
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

If IsEmptyArg(cmd_args, 0) Then
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
Else
  Set objNamespace = objShell.Namespace(PathToOpen)
  Set objFile = objNamespace.Self
End if

If IsNothing(objFile) Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: path is not parsed." & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & PathAbs & "`"
  WScript.Quit 128
End If

Dim Verb

For Each Verb In objFile.Verbs
  PrintOrEchoLine Verb.Name

  If LineReturn Then Exit For
Next
