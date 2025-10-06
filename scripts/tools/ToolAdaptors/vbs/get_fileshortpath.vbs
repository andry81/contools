''' Gets short file path.

''' USAGE:
'''   get_shortfilepath.vbs <Path>

''' NOTE:
'''   This script does not require the Administrator privileges.
'''

''' CAUTION:
'''   A file or directory must have has the short file path version otherwise
'''   the script will return the long path. This is by design, as long as each
'''   component of a path can has or not the short version and the resulted
'''   path can be partially short. You must compare a long path with a short
'''   path to deduce the difference.

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
        '   Must be a stand alone condition.
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

If IsEmptyArg(WScript.Arguments, 0) Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: <Path> is empty."
  WScript.Quit 255
End If

Dim Path : Path = WScript.Arguments(0)

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

Dim IsObjPath : IsObjPath = IsWin32NamespaceObjectPath(Path)

If IsObjPath Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: <Path> is not valid:" & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & Path & "`"
  WScript.Quit 255
End If

Dim PathAbs
Dim IsFileExist
Dim IsFolderExist : IsFolderExist = False

PathAbs = objFS.GetAbsolutePathName(Path) ' CAUTION: can alter a path character case if path exists

PathAbs = RemoveWin32NamespacePathPrefix(PathAbs)

' test on path existence including long path
IsFileExist = FileExists(PathAbs)
If Not IsFileExist Then
  IsFolderExist = FolderExists(PathAbs)
End If
If (Not IsFileExist) And (Not IsFolderExist) Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: <Path> does not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & PathAbs & "`"
  WScript.Quit 255
End If

If IsFileExist Then
  Dim File : Set File = GetFile(PathAbs)
  Dim FileShortPath : FileShortPath = File.ShortPath
  If Left(FileShortPath, 4) = "\\?\" Then
    FileShortPath = Mid(FileShortPath, 5)
  End If

  PrintOrEchoLine FileShortPath

  WScript.Quit 0
ElseIf IsFolderExist Then
  Dim Folder : Set Folder = GetFolder(PathAbs)
  Dim FolderShortPath : FolderShortPath = Folder.ShortPath
  If Left(FolderShortPath, 4) = "\\?\" Then
    FolderShortPath = Mid(FolderShortPath, 5)
  End If

  PrintOrEchoLine FolderShortPath

  WScript.Quit 0
End If

WScript.Quit 1
