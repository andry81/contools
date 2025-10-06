''' Reads all verb values from a path.

''' USAGE:
'''   read_path_all_props.vbs
'''     [-obj] [-i[gnore-unexist]]
'''     [-line-return | -lr]
'''     [--]
'''       <Path>

''' DESCRIPTION:
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''
'''   -obj
'''     Handles <Path> as an object string. See <Path> description for details.
'''
'''   -i[gnore-unexist]
'''     Ignores unexisted path.
'''     Useful in case of an unlinked or unresolved path with partial property
'''     list.
'''     Has no effect if `-obj` flag is used.
'''
'''   -line-return | -lr
'''     Return on first line print.
'''     Useful to skip iteration over property list.
'''
'''   <Path>
'''     Path to read.
'''     The script tries to use the path as a file system path if:
'''       * Has no `?`, `*`, `<`, `>`, `|`, `"` characters AND:
'''       * Has `\\?\X:[\/]` prefix OR.
'''       * Has `X:[\/]` prefix OR.
'''       * Has no `:` character and `[\/]` prefix.
'''     Otherwise does used as an object string and path function calls are
'''     avoided. Use `-obj` flag to explicitly handle it as an object string.
'''     NOTE:
'''       The `?`, `*`, `<` and `>` characters does used only to fast detect an
'''       object string and is not supposed to avoid path function calls in all
'''       cases.

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

''' CAUTION:
'''   Windows Scripting Host version 5.8 (Windows 7, 8, 8.1) has an issue
'''   around a conditional expression:
'''     `If Expr1 Or Expr2 ...`
'''   , where `Expr2` does execute even if `Expr1` is `True`.
'''
'''   Additionally, there is another issue, when the `Expr2` can trigger the
'''   corruption of following code.
'''
'''   The case is found in the `Expr2` expression, where a function does write
'''   into it's input parameter.
'''
'''   To workaround that we must declare a temporary parameter in the function
'''   of the `Expr2` and write into a temporary variable instead of an input
'''   parameter.
'''
'''   Example of potentially corrupted code:
'''
'''     Dim Expr1 : Expr1 = True ' or returned from a function call
'''     Function Expr2(MyVar1)
'''       MyVar1 = ... ' write into input parameter triggers the issue
'''     End Function
'''     If Expr1 Or Expr2 Then
'''       ... ' code here is potentially corrupted
'''     End If
'''
'''   Example of workarounded code:
'''
'''     Dim Expr1 : Expr1 = True ' or returned from a function call
'''     Function Expr2(MyVar1)
'''       Dim TempVar1 : TempVar1 = MyVar1
'''       TempVar1 = ... ' write into temporary parameter instead
'''     End Function
'''     If Expr1 Or Expr2 Then
'''       ... ' workarounded
'''     End If
'''
'''   Another workaround is to split the `Or` expression in a single `If` by a
'''   sequence of `If`/`ElseIf` conditions.
'''

Dim ErrNumber, ErrSource, ErrDesc, ErrHelpFile, ErrHelpContext

Function CopyError()
  ErrNumber = Err.Number
  ErrSource = Err.Source
  ErrDesc = Err.Description
  ErrHelpFile = Err.HelpFile
  ErrHelpContext = Err.HelpContext
End Function

Function HasProperty(ObjName, PropertyName)
  On Error Resume Next
  Eval(ObjName & "." & PropertyName)
  If err = 0 Then
    HasProperty = True
    On Error Goto 0
  ElseIf err = 424 Then ' Object required
    HasProperty = False
    On Error Goto 0
  Else
    CopyError()
    On Error Goto 0
    err.Raise ErrNumber, ErrSource, ErrDesc, ErrHelpFile, ErrHelpContext ' rethrow
  End If
End Function

Function GetProperty(ObjName, PropertyName)
  On Error Resume Next
  GetProperty = Eval(ObjName & "." & PropertyName)
  If err = 0 Then
    On Error Goto 0
  ElseIf err = 424 Then ' Object required
    On Error Goto 0
  Else
    CopyError()
    On Error Goto 0
    err.Raise ErrNumber, ErrSource, ErrDesc, ErrHelpFile, ErrHelpContext ' rethrow
  End If
End Function

Function GetObjectProperty(ObjName, PropertyName)
  On Error Resume Next
  Set GetObjectProperty = Eval(ObjName & "." & PropertyName)
  If err = 0 Then
    On Error Goto 0
  ElseIf err = 424 Then ' Object required
    On Error Goto 0
  Else
    CopyError()
    On Error Goto 0
    err.Raise ErrNumber, ErrSource, ErrDesc, ErrHelpFile, ErrHelpContext ' rethrow
  End If
End Function

Function IsNothing(obj)
  If IsEmpty(obj) Then
    IsNothing = True
    Exit Function
  End If
  If obj Is Nothing Then ' TypeName(obj) = "Nothing"
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

Function GetFile(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  If Not Left(PathAbs, 4) = "\\?\" Then
    Set GetFile = objFS.GetFile("\\?\" & PathAbs)
  Else
    Set GetFile = objFS.GetFile(PathAbs)
  End If
End Function

Function GetFolder(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFolder` error: `Path not found`.
  If Not Left(PathAbs, 4) = "\\?\" Then
    Set GetFolder = objFS.GetFolder("\\?\" & PathAbs & "\")
  Else
    Set GetFolder = objFS.GetFolder(PathAbs)
  End If
End Function

Function FileExists(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `FileExists` error: `File not found`.
  If Not Left(PathAbs, 4) = "\\?\" Then
    FileExists = objFS.FileExists("\\?\" & PathAbs)
  Else
    FileExists = objFS.FileExists(PathAbs)
  End If
End Function

Function FolderExists(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `FolderExists` error: `Path not found`.
  If Not Left(PathAbs, 4) = "\\?\" Then
    FolderExists = objFS.FolderExists("\\?\" & PathAbs & "\")
  Else
    FolderExists = objFS.FolderExists(PathAbs)
  End If
End Function

Function FileExistsNoPrefix(PathAbs)
  If Left(PathAbs, 4) = "\\?\" Then
    FileExistsNoPrefix = objFS.FileExists(Mid(PathAbs, 5))
  Else
    FileExistsNoPrefix = objFS.FileExists(PathAbs)
  End If
End Function

Function FolderExistsNoPrefix(PathAbs)
  If Left(PathAbs, 4) = "\\?\" Then
    FolderExistsNoPrefix = objFS.FolderExists(Mid(PathAbs, 5))
  Else
    FolderExistsNoPrefix = objFS.FolderExists(PathAbs)
  End If
End Function

' Detects Win32 Namespace object path.
Function IsWin32NamespaceObjectPath(PathAbs)
  ' NOTE: does not check the drive letter
  If Left(PathAbs, 4) = "\\?\" Then
    If Mid(PathAbs, 6, 1) = ":" And InStr(1, "\/", Mid(PathAbs, 7, 1), vbTextCompare) Then
      IsWin32NamespaceObjectPath = False
    Else
      IsWin32NamespaceObjectPath = True
    End If
  ElseIf Mid(PathAbs, 2, 1) = ":" And InStr(1, "\/", Mid(PathAbs, 3, 1), vbTextCompare) Then
    IsWin32NamespaceObjectPath = False
  ElseIf InStr(1, PathAbs, ":", vbTextCompare) Or InStr(1, PathAbs, "?", vbTextCompare) Or InStr(1, PathAbs, "*", vbTextCompare) Then
    IsWin32NamespaceObjectPath = True
  Else
    IsWin32NamespaceObjectPath = False
  End If
End Function

Function RemoveWin32NamespacePathPrefix(PathAbs)
  ' CAUTION:
  '   Avoid to remove path prefixes started by `\\`:
  '     * UNC: \\domain...
  '     * Volume: \\?\Volume{...
  '
  If Left(PathAbs, 4) = "\\?\" And Mid(PathAbs, 6, 1) = ":" And InStr(1, "\/", Mid(PathAbs, 7, 1), vbTextCompare) Then
    RemoveWin32NamespacePathPrefix = Mid(PathAbs, 5)
  Else
    RemoveWin32NamespacePathPrefix = PathAbs
  End If
End Function

Function GetParentFolderName(PathAbs)
  If IsWin32NamespaceObjectPath(PathAbs) Then
    Dim ParentPathAbs : ParentPathAbs = objFS.GetParentFolderName(PathAbs)
    If Len(ParentPathAbs) > 0 Then
      If Left(ParentPathAbs, 4) <> "\\?\" Then
        GetParentFolderName = "\\?\" & ParentPathAbs ' restores `\\?\` prefix
      Else
        GetParentFolderName = ParentPathAbs
      End If
    Else
      GetParentFolderName = PathAbs ' parent of an object string root is the object string root
    End If
  Else
    GetParentFolderName = objFS.GetParentFolderName(PathAbs) ' can be empty
  End If
End Function

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim IsObjPath: IsObjPath = False
Dim IgnoreUnexist : IgnoreUnexist = False
Dim LineReturn : LineReturn = False

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Mid(arg, 1, 1) = "-" Then
      If arg = "-obj" Then
        IsObjPath = True
      ElseIf arg = "-ignore-unexist" Or arg = "-i" Then
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
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <Path> is empty."
  WScript.Quit 1
End If

Dim Path : Path = cmd_args(0)

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

If Not IsObjPath Then
  IsObjPath = IsWin32NamespaceObjectPath(Path)
End If

Dim PathAbs
Dim IsFileExist
Dim IsFolderExist : IsFolderExist = False

If Not IsObjPath Then
  PathAbs = objFS.GetAbsolutePathName(Path) ' CAUTION: can alter a path character case if path exists

  PathAbs = RemoveWin32NamespacePathPrefix(PathAbs)

  ' test on path existence including long path
  IsFileExist = FileExists(PathAbs)
  If Not IsFileExist Then
    IsFolderExist = FolderExists(PathAbs)
  End If
  If (Not IgnoreUnexist) And (Not IsFileExist) And (Not IsFolderExist) Then
    PrintOrEchoErrorLine _
      WScript.ScriptName & ": error: <Path> does not exist:" & vbCrLf & _
      WScript.ScriptName & ": info: Path=`" & PathAbs & "`"
    WScript.Quit 1
  End If
Else
  PathAbs = Path
End If

Dim PathToOpen

' test on long path existence if not an object string
If IsObjPath Or (IsFileExist And FileExistsNoPrefix(PathAbs)) Or (IsFolderExist And FolderExistsNoPrefix(PathAbs)) Then
  ' is not long path
  PathToOpen = PathAbs
Else
  ' translate into short path

  If IsFileExist Then
    Dim File : Set File = GetFile(PathAbs)
    Dim FileShortPath : FileShortPath = File.ShortPath
    If Left(FileShortPath, 4) = "\\?\" Then
      FileShortPath = Mid(FileShortPath, 5)
    End If
    PathToOpen = FileShortPath
  ElseIf IsFolderExist Then
    Dim Folder : Set Folder = GetFolder(PathAbs)
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

Dim ParentPath : ParentPath = GetParentFolderName(PathToOpen)

Dim objNamespace, objFile

If Len(ParentPath) > 0 Then
  Set objNamespace = objShell.Namespace(ParentPath)
  If Not IsNothing(objNamespace) Then
    Set objFile = objNamespace.ParseName(objFS.GetFileName(PathToOpen))
  End If
Else
  Set objNamespace = objShell.Namespace(PathToOpen)
  If Not IsNothing(objNamespace) Then
    If HasProperty("objNamespace", "Self") Then
      Set objFile = objNamespace.Self
    Else
      objFile = GetObjectProperty("objNamespace", "Items().Item()")
    End If
  End If
End if

If IsNothing(objFile) Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: <Path> is not parsed." & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & PathAbs & "`"
  WScript.Quit 128
End If

Dim Verb

For Each Verb In objFile.Verbs
  PrintOrEchoLine Verb.Name

  If LineReturn Then Exit For
Next
