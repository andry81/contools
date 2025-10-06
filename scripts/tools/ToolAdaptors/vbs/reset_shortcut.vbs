''' Resets the Windows shortcut file using inner value(s).

''' CAUTION:
'''   WScript.Shell can not handle all Unicode characters in path properties, including characters in the path to a shortcut file.
'''   Details: https://stackoverflow.com/questions/39365489/how-do-you-keep-diacritics-in-shortcut-paths
'''

''' USAGE:
'''   reset_shortcut.vbs
'''     [-CD <CurrentDirectoryPath>]
'''     [-obj] [-ignore-unexist]
'''     [-reset-wd[-from-target-path]]
'''     [-reset-target-path-from-wd]
'''     [-reset-target-path-from-desc]
'''     [-reset-target-name-from-file-path]
'''     [-reset-target-drive-from-file-path]
'''     [-allow-auto-recover]
'''     [-allow-target-path-reassign]
'''     [-allow-dos-current-dir] [-allow-dos-target-path] [-allow-dos-wd] [-allow-dos-paths]
'''     [-use-getlink | -g] [-print-remapped-names | -k]
'''     [-p[rint-assign]] [-print-assigned | -pd]
'''     [-q]
'''     [--]
'''       <ShortcutFilePath>

''' DESCRIPTION:
'''   By default resaves shortcut which does trigger the Windows Shell
'''   component to validate all properties and rewrite the shortcut file even
'''   if nothing is changed reducing the shortcut content.
'''   Does not apply if TargetPath does not exist and `-ignore-unexist`
'''   option is not used to avoid a shortcut accident corruption by the
'''   Windows Shell component internal guess logic (see `-ignore-unexist`
'''   option description).
'''   Has no effect if TargetPath is already changed using `-reset-*` flags or
'''   by any other reset.
'''
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''
'''   -CD <CurrentDirectoryPath>
'''     Changes current directory to <CurrentDirectoryPath> before the
'''     execution.
'''
'''   -obj
'''     Handles shortcut target path as an object string. See <ShortcutTarget>
'''     description for details.
'''     Can not be used together with  `-q` flag.
'''     Can reduce or remove the effect of `-reset-*` or `-allow-auto-recover`
'''     flags.
'''
'''   -ignore-unexist
'''     By default TargetPath and WorkingDirectory does check on existence
'''     before assign. Use this flag to skip the check.
'''     Can not be used together with `-allow-auto-recover` flag.
'''     Has no effect for TargetPath if `-obj` flag is used.
'''
'''     CAUTION:
'''       The Windows Shell component does use a guess logic to restore
'''       inexistent or invalid target path or/and working directory
'''       properties. In some cases or OS versions it may lead to a path
'''       property corruption or even an entire shortcut corruption.
'''
'''       Details:
'''         https://learn.microsoft.com/en-us/windows/win32/shell/links#link-resolution
'''         https://github.com/libyal/liblnk/tree/HEAD/documentation/Windows%20Shortcut%20File%20(LNK)%20format.asciidoc#8-corruption-scenarios
'''         https://stackoverflow.com/questions/22382010/what-options-are-available-for-shell32-folder-getdetailsof/37061433#37061433
'''
'''       In the wild has been caught several cases of a shortcut corruption:
'''       - Shortcut path can change length from long path to short DOS path.
'''       - Shortcut path can change language characters localization from
'''         Unicode to ANSI with wrong code page.
'''       - Shortcut path can convert unknown unicode characters into `?`
'''         characters.
'''       - Shortcut path can be vandalized like path end truncation or even
'''         the space characters replacement by the underscore character.
'''       - Shortcut can change type from a file shortcut to a directory
'''         shortcut with or without old path save into Description property.
'''       - Shortcut can be completely rewritten losing other properties and
'''         data.
'''
'''     Use this option with the caution.
'''
'''   -reset-wd[-from-target-path]
'''     Reset WorkingDirectory from TargetPath.
'''     Does not apply if TargetPath is empty.
'''     Has no effect if `-obj` flag is used.
'''   -reset-target-path-from-wd
'''     Reset TargetPath from WorkingDirectory leaving the file name as is.
'''     Does not apply if WorkingDirectory or TargetPath is empty.
'''     Has no effect if `-obj` flag is used.
'''   -reset-target-path-from-desc
'''     Reset TargetPath from Description.
'''     Does not apply if Description is empty.
'''     Does not apply if Description is not a path and `-obj` flag is not
'''     used.
'''     Has no effect if TargetPath is already resetted.
'''     Has effect if `-obj` flag is used.
'''   -reset-target-name-from-file-path
'''     Reset TargetPath name from shortcut file name without `.lnk` extension.
'''     Has no effect if `-obj` flag is used.
'''   -reset-target-drive-from-file-path
'''     Reset TargetPath drive from shortcut file drive.
'''     Has no effect if `-obj` flag is used.
'''
'''   -allow-auto-recover
'''     Allow auto recover by using the guess logic applying in this order:
'''     1. Reset WorkingDirectory from TargetPath.
'''        Has no effect if `-obj` flag is used.
'''        Has no effect if TargetPath is empty.
'''        Has no effect if resulted WorkingDirectory does not exist.
'''     2. Reset TargetPath from WorkingDirectory leaving the file name as is.
'''        Has no effect if `-obj` flag is used.
'''        Has no effect if WorkingDirectory or TargetPath is empty.
'''        Has no effect if resulted TargetPath does not exist.
'''     3. Reset TargetPath from Description.
'''        Has no effect if Description is empty.
'''        Has no effect if not a path and `-obj` flag is not used.
'''        Has no effect if resulted TargetPath does not exist.
'''     4. Reset TargetPath name from shortcut file name without `.lnk`
'''        extension.
'''        Has no effect if `-obj` flag is used.
'''        Has no effect if resulted TargetPath does not exist.
'''     5. Reset TargetPath/WorkingDirectory drive from shortcut file drive.
'''        Has no effect if `-obj` flag is used.
'''        Has no effect if resulted TargetPath/WorkingDirectory does not
'''        exist.
'''     6. The rest combinations of above steps 1-5 with the order preserving:
'''        1+5, 2+4, 2+5, 3+4, 3+5, 2+4+5, 3+4+5
'''        Has no effect if `-obj` flag is used.
'''     Implies all `-reset-*` flags.
'''     Can not be used together with `-ignore-unexist` flag.
'''
'''   -allow-target-path-reassign
'''     Allows `TargetPath` property reassign if has not been assigned.
'''     Has no effect if `TargetPath` is already resetted.
'''     Has effect if `-obj` flag is used.
'''
'''   -allow-dos-current-dir
'''     Allows long path conversion into a reduced DOS path version for the
'''     current directory.
'''     Has no effect if path does not exist.
'''   -allow-dos-target-path
'''     Rereads target path after assign and if it does not exist, then
'''     reassigns it by a reduced DOS path version.
'''     It is useful when you want to create not truncated shortcut target file
'''     path to open it by an old version application which does not support
'''     long paths or Win32 Namespace paths, but supports open target paths by
'''     a shortcut file.
'''     Has no effect if path does not exist.
'''     Has no effect if `-obj` flag is used.
'''   -allow-dos-wd
'''     Rereads working directory after assign and if it does not exist, then
'''     reassign it by a reduced DOS path version.
'''     Has no effect if path does not exist.
'''   -allow-dos-paths
'''     Implies all `-allow-dos-*` flags.
'''
'''   -use-getlink | -g
'''     Use `GetLink` property instead of `CreateShortcut` method.
'''     Alternative interface to assign path properties with Unicode
'''     characters.
'''   -print-remapped-names | -k
'''     Print remapped key names instead of `CreateShortcut` method object
'''     names.
'''     Has no effect if `-use-getlink` flag is not used.
'''
'''   -p[rint-assign]
'''     Print property assign before assign.
'''   -print-assigned | -pd
'''     Rereads property after assign and prints it.
'''
'''   -q
'''     Always quote target path argument if has no quote characters.
'''     Can not be used together with  `-obj` flag.
'''
'''   <ShortcutTarget>
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

''' NOTE:
'''   See details and examples in the `make_shortcut.vbs` script.

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

Function GetExistedFileShortPath(FilePathAbs)
  Dim File : Set File = GetFile(FilePathAbs)
  GetExistedFileShortPath = RemoveWin32NamespacePathPrefix(File.ShortPath)
End Function

Function GetExistedFolderShortPath(FolderPathAbs)
  Dim Folder : Set Folder = GetFolder(FolderPathAbs)
  GetExistedFolderShortPath = RemoveWin32NamespacePathPrefix(Folder.ShortPath)
End Function

Function GetShortPath(PathAbs)
  If FileExists(PathAbs) Then
    GetShortPath = GetExistedFileShortPath(PathAbs)
  ElseIf FolderExists(PathAbs) Then
    GetShortPath = GetExistedFolderShortPath(PathAbs)
  Else
    GetShortPath = ""
  End If
End Function

Function GetFolderShortPath(PathAbs)
  If FolderExists(PathAbs) Then
    GetFolderShortPath = GetExistedFolderShortPath(PathAbs)
  Else
    GetFolderShortPath = ""
  End If
End Function

Function IsPathExistsNoPrefix(Path)
  If FileExistsNoPrefix(Path) Or FolderExistsNoPrefix(Path) Then
    IsPathExistsNoPrefix = True
  Else
    IsPathExistsNoPrefix = False
  End If
End Function

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim PrintAssign : PrintAssign = False
Dim PrintAssigned : PrintAssigned = False

Dim IgnoreUnexist : IgnoreUnexist = False

Dim ResetWorkingDirFromTargetPath : ResetWorkingDirFromTargetPath = False
Dim ResetTargetPathFromWorkingDir : ResetTargetPathFromWorkingDir = False
Dim ResetTargetPathFromDesc : ResetTargetPathFromDesc = False
Dim ResetTargetNameFromFilePath : ResetTargetNameFromFilePath = False
Dim ResetTargetDriveFromFilePath : ResetTargetDriveFromFilePath = False

Dim AllowAutoRecover : AllowAutoRecover = False
Dim AllowTargetPathReassign : AllowTargetPathReassign = False

Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim ChangeCurrentDirectoryExist : ChangeCurrentDirectoryExist = False

Dim ShortcutTarget : ShortcutTarget = ""
Dim ShortcutTargetObj : ShortcutTargetObj = False
Dim ShortcutTargetUnquoted : ShortcutTargetUnquoted = "" ' CAUTION: DOES used in case of `-obj` flag
Dim ShortcutTargetEmpty : ShortcutTargetEmpty = False
Dim ShortcutTargetExist : ShortcutTargetExist = False ' not empty and exists
Dim ShortcutTargetToAssign : ShortcutTargetToAssign = ""
Dim ShortcutTargetToAssignExist : ShortcutTargetToAssignExist = False ' not empty and exists
Dim ShortcutTargetAssigned : ShortcutTargetAssigned = False

Dim ShortcutWorkingDirectory : ShortcutWorkingDirectory = ""
Dim ShortcutWorkingDirectoryUnquoted : ShortcutWorkingDirectoryUnquoted = ""
Dim ShortcutWorkingDirectoryEmpty : ShortcutWorkingDirectoryEmpty = False
Dim ShortcutWorkingDirectoryExist : ShortcutWorkingDirectoryExist = False ' not empty and exists
Dim ShortcutWorkingDirectoryToAssign : ShortcutWorkingDirectoryToAssign = ""
Dim ShortcutWorkingDirectoryToAssignExist : ShortcutWorkingDirectoryToAssignExist = False ' not empty and exists
Dim ShortcutWorkingDirectoryAssigned : ShortcutWorkingDirectoryAssigned = False

Dim ShortcutDesc : ShortcutDesc = ""
Dim ShortcutDescObj : ShortcutDescObj = False
Dim ShortcutDescUnquoted : ShortcutDescUnquoted = ""
Dim ShortcutDescEmpty : ShortcutDescEmpty = False
Dim ShortcutDescExist : ShortcutDescExist = False ' not empty and exists

Dim AlwaysQuote : AlwaysQuote = False

Dim AllowDOSCurrentDirectory : AllowDOSCurrentDirectory = False
Dim AllowDOSTargetPath : AllowDOSTargetPath = False
Dim AllowDOSWorkingDirectory : AllowDOSWorkingDirectory = False
Dim AllowDOSPaths : AllowDOSPaths = False

Dim UseGetLink : UseGetLink = False
Dim PrintRemappedNames : PrintRemappedNames = False

Dim objShell : Set objShell = WScript.CreateObject("WScript.Shell")

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Left(arg, 1) = "-" Then
      If arg = "-CD" Then ' Change current directory
        i = i + 1
        ChangeCurrentDirectory = WScript.Arguments(i)
        ChangeCurrentDirectoryExist = True
      ElseIf arg = "-obj" Then
       ShortcutTargetObj = True
      ElseIf arg = "-ignore-unexist" Then
       IgnoreUnexist = True
      ElseIf arg = "-reset-wd-from-target-path" Or arg = "-reset-wd" Then
        ResetWorkingDirFromTargetPath = True
      ElseIf arg = "-reset-target-path-from-wd" Then
        ResetTargetPathFromWorkingDir = True
      ElseIf arg = "-reset-target-path-from-desc" Then
        ResetTargetPathFromDesc = True
      ElseIf arg = "-reset-target-name-from-file-path" Then
        ResetTargetNameFromFilePath = True
      ElseIf arg = "-reset-target-drive-from-file-path" Then
        ResetTargetDriveFromFilePath = True
      ElseIf arg = "-allow-auto-recover" Then
        AllowAutoRecover = True
      ElseIf arg = "-allow-target-path-reassign" Then
        AllowTargetPathReassign = True
      ElseIf arg = "-allow-dos-current-dir" Then ' Allow long path conversion into DOS path for the current directory
        AllowDOSCurrentDirectory = True
      ElseIf arg = "-allow-dos-target-path" Then ' Allow target path reset by a reduced DOS path version
        AllowDOSTargetPath = True
      ElseIf arg = "-allow-dos-wd" Then ' Allow working directory reset by a reduced DOS path version
        AllowDOSWorkingDirectory = True
      ElseIf arg = "-allow-dos-paths" Then ' Allow a property reset by a reduced DOS path version
        AllowDOSPaths = True
      ElseIf arg = "-use-getlink" Or arg = "-g" Then
        UseGetLink = True
      ElseIf arg = "-print-remapped-names" Or arg = "-k" Then
        PrintRemappedNames = True
      ElseIf arg = "-print-assign" Or arg = "-p" Then ' Print assign
        PrintAssign = True
      ElseIf arg = "-print-assigned" Or arg = "-pd" Then ' Print assigned
        PrintAssigned = True
      ElseIf arg = "-q" Then ' Always quote target path property if has no quote characters
        AlwaysQuote = True
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

If ShortcutTargetObj And AlwaysQuote Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: flags is mixed: -obj <-> -q"
  WScript.Quit 255
End If

If IgnoreUnexist And AllowAutoRecover Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: flags is mixed: -ignore-unexist <-> -allow-auto-recover"
  WScript.Quit 255
End If

If IsEmptyArg(cmd_args, 0) Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <ShortcutFilePath> is empty."
  WScript.Quit 255
End If

If AllowAutoRecover Then
  ResetWorkingDirFromTargetPath = True
  ResetTargetPathFromWorkingDir = True
  ResetTargetPathFromDesc = True
  ResetTargetNameFromFilePath = True
  ResetTargetDriveFromFilePath = True
End If

If AllowDOSPaths Then
  AllowDOSCurrentDirectory = AllowDOSPaths
  AllowDOSTargetPath = AllowDOSPaths
  AllowDOSWorkingDirectory = AllowDOSPaths
End If

' additional functions

Function GetShortcut(ShortcutFilePathToOpen)
  If Not UseGetLink Then
    ' CAUTION:
    '   Base `CreateShortcut` method does not support all Unicode characters.
    '   Use `GetLink` property (`-use-getlink` flag) instead to workaround that.
    '
    Set GetShortcut = objShell.CreateShortcut(ShortcutFilePathToOpen)
  Else
    Dim objShellApp : Set objShellApp = CreateObject("Shell.Application")
    Dim ShortcutParentPath : ShortcutParentPath = GetParentFolderName(ShortcutFilePathToOpen)
    Dim objNamespace, objFile
    If Len(ShortcutParentPath) > 0 Then
      Set objNamespace = objShellApp.Namespace(ShortcutParentPath)
      If Not IsNothing(objNamespace) Then
        Set objFile = objNamespace.ParseName(objFS.GetFileName(ShortcutFilePathToOpen))
      End If
    Else
      Set objNamespace = objShellApp.Namespace(ShortcutFilePathToOpen)
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
        WScript.ScriptName & ": info: Path=`" & ShortcutFilePathToOpen & "`"
      WScript.Quit 128
    End If

    If objFile.IsLink Then
      Set GetShortcut = objFile.GetLink
    Else
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": error: <Path> is not a shortcut." & vbCrLf & _
        WScript.ScriptName & ": info: Path=`" & ShortcutFilePathToOpen & "`"
      WScript.Quit 129
    End If
  End If
End Function

Function GetShortcutProperty(PropertyName)
  Dim PropertyName_ : PropertyName_ = PropertyName

  If UseGetLink Then
    ' remap property name
    If PropertyName = "TargetPath" Then
      PropertyName_ = "Path"
    ElseIf PropertyName = "TargetArgs" Then ' alternative name
      PropertyName_ = "Arguments"
    ElseIf PropertyName = "WindowStyle" Then
      PropertyName_ = "ShowCommand"
    End If

    If Not (PropertyName_ = "IconLocation") Then
      GetShortcutProperty = Eval("objSC." & PropertyName_)
    Else
      GetShortcutProperty = objSC.Path & "," & objSC.GetIconLocation(objSC.Path)
    End If
  Else
    GetShortcutProperty = Eval("objSC." & PropertyName_)
  End If
End Function

Function GetShortcutPropertyNameToPrint(PropertyName)
  Dim PropertyName_ : PropertyName_ = PropertyName

  If UseGetLink And PrintRemappedNames Then
    ' remap property name
    If PropertyName = "TargetPath" Then
      PropertyName_ = "Path"
    ElseIf PropertyName = "TargetArgs" Then ' alternative name
      PropertyName_ = "Arguments"
    ElseIf PropertyName = "WindowStyle" Then
      PropertyName_ = "ShowCommand"
    End If
  End If

  GetShortcutPropertyNameToPrint = PropertyName_
End Function

Sub SetShortcutProperty_ShellLinkObject(PropertyName, PropertyValue)
  On Error Resume Next
  If PropertyName = "TargetPath" Then
    objSC.Path = PropertyValue
  ElseIf PropertyName = "Arguments" Or PropertyName = "TargetArgs" Then ' alternative name
    objSC.Arguments = PropertyValue
  ElseIf PropertyName = "WorkingDirectory" Then
    objSC.WorkingDirectory = PropertyValue
  ElseIf PropertyName = "Description" Then
    objSC.Description = PropertyValue
  ElseIf PropertyName = "WindowStyle" Then
    objSC.WindowsStyle = PropertyValue
  ElseIf PropertyName = "HotKey" Then
    objSC.HotKey = Eval(PropertyValue)  ' ex: `&H400+&H200+Asc("Q")` (`Asc` requires capital letters)
  ElseIf PropertyName = "IconLocation" Then
    Dim IconLocationArr : IconLocationArr = Split(PropertyValue, ",", -1, 1)
    objSC.SetIconLocation IconLocationArr(0), CInt(IconLocationArr(1))
  End If
  On Error Goto 0
End Sub

Sub SetShortcutProperty_WScript_Shell_CreateShortcut(PropertyName, PropertyValue)
  On Error Resume Next
  If PropertyName = "TargetPath" Then
    objSC.TargetPath = PropertyValue
  ElseIf PropertyName = "Arguments" Or PropertyName = "TargetArgs" Then ' alternative name
    objSC.Arguments = PropertyValue
  ElseIf PropertyName = "WorkingDirectory" Then
    objSC.WorkingDirectory = PropertyValue
  ElseIf PropertyName = "Description" Then
    objSC.Description = PropertyValue
  ElseIf PropertyName = "WindowStyle" Then
    objSC.WindowsStyle = PropertyValue
  ElseIf PropertyName = "HotKey" Then
    objSC.HotKey = PropertyValue        ' ex: `Ctrl+Alt+Q`
  ElseIf PropertyName = "IconLocation" Then
    objSC.IconLocation = PropertyValue  ' ex: `notepad.exe, 0`
  End If
  On Error Goto 0
End Sub

Sub SetShortcutProperty(PropertyName, PropertyValue)
  If UseGetLink Then
    SetShortcutProperty_ShellLinkObject PropertyName, PropertyValue
  Else
    SetShortcutProperty_WScript_Shell_CreateShortcut PropertyName, PropertyValue
  End If
End Sub

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

' change current directory before any file system request because of relative paths
If ChangeCurrentDirectoryExist Then
  Dim ChangeCurrentDirectoryAbs : ChangeCurrentDirectoryAbs = objFS.GetAbsolutePathName(ChangeCurrentDirectory) ' CAUTION: can alter a path character case if path exists

  ChangeCurrentDirectoryAbs = RemoveWin32NamespacePathPrefix(ChangeCurrentDirectoryAbs)

  ' test on path existence including long path
  Dim IsCurrentDirectoryExist : IsCurrentDirectoryExist = FolderExists(ChangeCurrentDirectoryAbs)
  If Not IsCurrentDirectoryExist Then
    PrintOrEchoErrorLine _
      WScript.ScriptName & ": error: could not change current directory:" & vbCrLf & _
      WScript.ScriptName & ": info: CurrentDirectory=`" & ChangeCurrentDirectoryAbs & "`"
    WScript.Quit 1
  End If

  ' test on long path existence
  If (Not AllowDOSCurrentDirectory) Or FolderExistsNoPrefix(ChangeCurrentDirectoryAbs) Then
    ' is not long path
    objShell.CurrentDirectory = ChangeCurrentDirectoryAbs
  ElseIf AllowDOSCurrentDirectory Then
    ' translate into short path
    objShell.CurrentDirectory = GetExistedFolderShortPath(ChangeCurrentDirectoryAbs)
  End If
End If

Dim ShortcutFilePath : ShortcutFilePath = cmd_args(0)

Dim ShortcutFilePathAbs : ShortcutFilePathAbs = objFS.GetAbsolutePathName(ShortcutFilePath) ' CAUTION: can alter a path character case if path exists

ShortcutFilePathAbs = RemoveWin32NamespacePathPrefix(ShortcutFilePathAbs)

' test on path existence including long path
Dim IsShortcutFileExist : IsShortcutFileExist = FileExists(ShortcutFilePathAbs)
If Not IsShortcutFileExist Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: <ShortcutFilePath> does not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: ShortcutFilePath=`" & ShortcutFilePathAbs & "`"
  WScript.Quit 10
End If

Dim ShortcutFilePathToOpen

' test on long path existence
If FileExistsNoPrefix(ShortcutFilePathAbs) Then
  ' is not long path
  ShortcutFilePathToOpen = ShortcutFilePathAbs
Else
  ' translate into short path
  ShortcutFilePathToOpen = GetExistedFileShortPath(ShortcutFilePathAbs)
End If

Dim objSC : Set objSC = GetShortcut(ShortcutFilePathToOpen)

' read TargetPath unconditionally

ShortcutTarget = GetShortcutProperty("TargetPath")

Do ' empty `Do-Loop` to emulate `Break`
If Not ShortcutTargetObj Then
  If Len(ShortcutTarget) > 1 And Left(ShortcutTarget, 1) = Chr(34) And Right(ShortcutTarget, 1) = Chr(34) Then
    ShortcutTargetUnquoted = Mid(ShortcutTarget, 2, Len(ShortcutTarget) - 2)
  Else
    ShortcutTargetUnquoted = ShortcutTarget
  End If

  ' auto detect the object string
  ShortcutTargetObj = IsWin32NamespaceObjectPath(ShortcutTargetUnquoted)

  If Not ShortcutTargetObj Then
    Dim ShortcutTargetDirExist : ShortcutTargetDirExist = False

    If Len(ShortcutTargetUnquoted) > 0 Then
      If FileExists(ShortcutTargetUnquoted) Then
        ShortcutTargetExist = True
      ElseIf FolderExists(ShortcutTargetUnquoted) Then
        ShortcutTargetDirExist = True
        ShortcutTargetExist = True
      End If
    Else
      ShortcutTargetEmpty = True
    End If

    If AlwaysQuote And InStr(ShortcutTargetUnquoted, Chr(34)) = 0 Then
      ShortcutTarget = Chr(34) & ShortcutTargetUnquoted & Chr(34)
    End If
  End If
End If
Loop While False

' read WorkingDirectory unconditionally

ShortcutWorkingDirectory = GetShortcutProperty("WorkingDirectory")

If Len(ShortcutWorkingDirectory) > 1 And Left(ShortcutWorkingDirectory, 1) = Chr(34) And Right(ShortcutWorkingDirectory, 1) = Chr(34) Then
  ShortcutWorkingDirectoryUnquoted = Mid(ShortcutWorkingDirectory, 2, Len(ShortcutWorkingDirectory) - 2)
Else
  ShortcutWorkingDirectoryUnquoted = ShortcutWorkingDirectory
End If

If Len(ShortcutWorkingDirectoryUnquoted) > 0 Then
  If FolderExists(ShortcutWorkingDirectoryUnquoted) Then
    ShortcutWorkingDirectoryExist = True
  End If
Else
  ShortcutWorkingDirectoryEmpty = True
End If

' read Description conditionally

If ResetTargetPathFromDesc Or AllowAutoRecover Then
  ShortcutDesc = GetShortcutProperty("Description")

  If Len(ShortcutDesc) > 1 And Left(ShortcutDesc, 1) = Chr(34) And Right(ShortcutDesc, 1) = Chr(34) Then
    ShortcutDescUnquoted = Mid(ShortcutDesc, 2, Len(ShortcutDesc) - 2)
  Else
    ShortcutDescUnquoted = ShortcutDesc
  End If

  ' auto detect the object string
  ShortcutDescObj = IsWin32NamespaceObjectPath(ShortcutDescUnquoted)

  If Len(ShortcutDescUnquoted) > 0 Then
    If Not ShortcutDescObj Then
      If FileExists(ShortcutDescUnquoted) Then
        ShortcutDescExist = True
      ElseIf FolderExists(ShortcutDescUnquoted) Then
        ShortcutDescExist = True
      End If
    End If
  Else
    ShortcutDescEmpty = True
  End If
End If

' 1

If (Not ShortcutTargetObj) And ResetWorkingDirFromTargetPath Then
  ' NOTE:
  '   Shortcut target must not be an existed DIRECTORY path, otherwise WorkingDirectory must be not empty, otherwise - ignore.
  '   Meaning:
  '     A directory shortcut basically does not use the WorkingDirectory property, but if does, then
  '     the WorkingDirectory property must be not empty to initiate a change.
  '     If a directory does not exist by the target path, then the target path is treated as a file path and
  '     the target parent directory is used for assignment.
  '
  If Not ShortcutTargetEmpty Then
    If (Not ShortcutTargetDirExist) Or (Not ShortcutWorkingDirectoryEmpty) Then
      If Not ShortcutTargetDirExist Then
        ShortcutWorkingDirectoryToAssign = GetParentFolderName(ShortcutTargetUnquoted)
      Else
        ShortcutWorkingDirectoryToAssign = ShortcutTargetUnquoted ' use the whole path
      End If

      If Not IgnoreUnexist Then
        ShortcutWorkingDirectoryToAssignExist = FolderExists(ShortcutWorkingDirectoryToAssign)

        If Not ShortcutWorkingDirectoryToAssignExist Then
          PrintOrEchoErrorLine _
            WScript.ScriptName & ": error: shortcut working directory to assign does not exist:" & vbCrLf & _
            WScript.ScriptName & ": info: WorkingDirectory=`" & ShortcutWorkingDirectoryToAssign & "`"
          WScript.Quit 21
        End If
      End If

      ShortcutWorkingDirectoryAssigned = True
    Else
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": warning: <WorkingDirectory> reset is skipped because is empty and <TargetPath> does exist:" & vbCrLf & _
        WScript.ScriptName & ": info: TargetPath=`" & ShortcutTargetUnquoted & "`"
    End If
  Else
    PrintOrEchoErrorLine WScript.ScriptName & ": error: <TargetPath> is empty."
    WScript.Quit 10
  End If
End If

' 2

If (Not ShortcutTargetObj) And ResetTargetPathFromWorkingDir Then
  If ShortcutTargetEmpty Then
    PrintOrEchoErrorLine WScript.ScriptName & ": error: <TargetPath> is empty."
    WScript.Quit 10
  End If

  If ShortcutWorkingDirectoryEmpty Then
    PrintOrEchoErrorLine WScript.ScriptName & ": error: <WorkingDirectory> is empty."
    WScript.Quit 11
  End If

  If Not ShortcutTargetEmpty Then
    ShortcutTargetToAssign = ShortcutWorkingDirectoryUnquoted & "\" & objFS.GetFileName(ShortcutTargetUnquoted)

    If Not IgnoreUnexist Then
      ShortcutTargetToAssignExist = FileExists(ShortcutTargetToAssign)

      If Not ShortcutTargetToAssignExist Then
        PrintOrEchoErrorLine _
          WScript.ScriptName & ": error: shortcut target path to assign does not exist:" & vbCrLf & _
          WScript.ScriptName & ": info: TargetPath=`" & ShortcutTargetToAssign & "`"
        WScript.Quit 20
      End If
    End If

    ShortcutTargetAssigned = True
  End If
End If

' 3

If ResetTargetPathFromDesc And (Not ShortcutTargetAssigned) Then
  If (Not ShortcutDescEmpty) And (ShortcutDescObj Or ShortcutDescExist) Then
    ShortcutTargetToAssign = ShortcutDescUnquoted

    If (Not ShortcutDescObj) And (Not IgnoreUnexist) Then
      ShortcutTargetToAssignExist = FileExists(ShortcutTargetToAssign)

      If Not ShortcutTargetToAssignExist Then
        PrintOrEchoErrorLine _
          WScript.ScriptName & ": error: shortcut description as path to assign does not exist:" & vbCrLf & _
          WScript.ScriptName & ": info: TargetPath=`" & ShortcutTargetToAssign & "`"
        WScript.Quit 20
      End If
    End If

    ShortcutTargetAssigned = True
  Else
    PrintOrEchoErrorLine _
      WScript.ScriptName & ": error: <Description> is empty or not exist:" & vbCrLf & _
      WScript.ScriptName & ": info: Description=`" & ShortcutDescUnquoted & "`"
    WScript.Quit 13
  End If
End If

' 4

Dim ShortcutTargetExt
Dim ShortcutTargetExtLen

If (Not ShortcutTargetObj) And ResetTargetNameFromFilePath Then
  If Not ShortcutTargetAssigned Then
    ShortcutTargetToAssign = GetParentFolderName(ShortcutTargetUnquoted) & "\" & objFS.GetFileName(ShortcutFilePath)
    ShortcutTargetAssigned = True
  Else
    ShortcutTargetToAssign = GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)
  End If

  ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
  ShortcutTargetExtLen = Len(ShortcutTargetExt)
  If ShortcutTargetExtLen > 0 Then
    ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
  End If
End If

' 5

If (Not ShortcutTargetObj) And ResetTargetDriveFromFilePath Then
  If Not ShortcutTargetAssigned Then
    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetUnquoted, 3)
    ShortcutTargetAssigned = True
  Else
    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetUnquoted, 3)
  End If
End If

If (Not ShortcutTargetObj) And AllowAutoRecover Then
  ' 1+5
  If (Not ShortcutWorkingDirectoryAssigned) And (Not ShortcutTargetEmpty) Then
    If (Not ShortcutTargetDirExist) Or (Not ShortcutWorkingDirectoryEmpty) Then
      If Not ShortcutTargetDirExist Then
        ShortcutWorkingDirectoryToAssign = GetParentFolderName(ShortcutTargetUnquoted)
      Else
        ShortcutWorkingDirectoryToAssign = ShortcutTargetUnquoted ' use the whole path
      End If

      ShortcutWorkingDirectoryToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutWorkingDirectoryToAssign, 3)

      ShortcutWorkingDirectoryToAssignExist = FolderExists(ShortcutWorkingDirectoryToAssign)

      If ShortcutWorkingDirectoryToAssignExist Then
        ShortcutWorkingDirectoryAssigned = True
      End If
    End If
  End If

  ' 2+4

  If (Not ShortcutTargetAssigned) And (Not ShortcutTargetEmpty) And (Not ShortcutWorkingDirectoryEmpty) Then
    ShortcutTargetToAssign = ShortcutWorkingDirectoryUnquoted & "\" & objFS.GetFileName(ShortcutTargetUnquoted)

    ShortcutTargetToAssign = GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)

    ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
    ShortcutTargetExtLen = Len(ShortcutTargetExt)
    If ShortcutTargetExtLen > 0 Then
      ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
    End If

    ShortcutTargetToAssignExist = FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      ShortcutTargetAssigned = True
    End If
  End If

  ' 2+5

  If (Not ShortcutTargetAssigned) And (Not ShortcutTargetEmpty) And (Not ShortcutWorkingDirectoryEmpty) Then
    ShortcutTargetToAssign = ShortcutWorkingDirectoryUnquoted & "\" & objFS.GetFileName(ShortcutTargetUnquoted)

    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetToAssign, 3)

    ShortcutTargetToAssignExist = FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      ShortcutTargetAssigned = True
    End If
  End If

  ' 3+4

  If (Not ShortcutTargetAssigned) And (Not ShortcutTargetEmpty) And (Not ShortcutDescEmpty) And ShortcutDescExist Then
    ShortcutTargetToAssign = ShortcutDescUnquoted

    ShortcutTargetToAssign = GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)

    ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
    ShortcutTargetExtLen = Len(ShortcutTargetExt)
    If ShortcutTargetExtLen > 0 Then
      ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
    End If

    ShortcutTargetToAssignExist = FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      ShortcutTargetAssigned = True
    End If
  End If

  ' 3+5

  If (Not ShortcutTargetAssigned) And (Not ShortcutTargetEmpty) And (Not ShortcutDescEmpty) And ShortcutDescExist Then
    ShortcutTargetToAssign = ShortcutDescUnquoted

    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetToAssign, 3)

    ShortcutTargetToAssignExist = FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      ShortcutTargetAssigned = True
    End If
  End If

  ' 2+4+5

  If (Not ShortcutTargetAssigned) And (Not ShortcutTargetEmpty) And (Not ShortcutWorkingDirectoryEmpty) Then
    ShortcutTargetToAssign = ShortcutWorkingDirectoryUnquoted & "\" & objFS.GetFileName(ShortcutTargetUnquoted)

    ShortcutTargetToAssign = GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)

    ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
    ShortcutTargetExtLen = Len(ShortcutTargetExt)
    If ShortcutTargetExtLen > 0 Then
      ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
    End If

    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetToAssign, 3)

    ShortcutTargetToAssignExist = FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      ShortcutTargetAssigned = True
    End If
  End If

  ' 3+4+5

  If (Not ShortcutTargetAssigned) And (Not ShortcutTargetEmpty) And (Not ShortcutDescEmpty) And ShortcutDescExist Then
    ShortcutTargetToAssign = ShortcutDescUnquoted

    ShortcutTargetToAssign = GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)

    ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
    ShortcutTargetExtLen = Len(ShortcutTargetExt)
    If ShortcutTargetExtLen > 0 Then
      ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
    End If

    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetToAssign, 3)

    ShortcutTargetToAssignExist = FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      ShortcutTargetAssigned = True
    End If
  End If
End If

If ShortcutTargetAssigned Then
  If PrintAssign Then
    PrintOrEchoLine GetShortcutPropertyNameToPrint("TargetPath") & "=" & ShortcutTargetToAssign
  End If

  If AlwaysQuote And InStr(ShortcutTargetToAssign, Chr(34)) = 0 Then
    ShortcutTargetToAssign = Chr(34) & ShortcutTargetToAssign & Chr(34)
  End If

  SetShortcutProperty "TargetPath", ShortcutTargetToAssign

  ' reread `TargetPath`
  ShortcutTarget = GetShortcutProperty("TargetPath")

  If PrintAssigned Then
    PrintOrEchoLine GetShortcutPropertyNameToPrint("TargetPath") & "(assigned)=" & ShortcutTarget
  End If
ElseIf AllowTargetPathReassign Then
  If ShortcutTargetObj Or IgnoreUnexist Or ShortcutTargetExist Then
    If PrintAssign Then
      PrintOrEchoLine GetShortcutPropertyNameToPrint("TargetPath") & "(reassign)=" & ShortcutTarget
    End If

    SetShortcutProperty "TargetPath", ShortcutTarget ' reassign
    ShortcutTargetAssigned = True

    ' reread `TargetPath`
    ShortcutTarget = GetShortcutProperty("TargetPath")

    If PrintAssigned Then
      PrintOrEchoLine GetShortcutPropertyNameToPrint("TargetPath") & "(reassigned)=" & ShortcutTarget
    End If
  End If
End If

If (Not ShortcutTargetObj) And ShortcutTargetAssigned And AllowDOSTargetPath Then
  Dim ShortcutTargetAbs : ShortcutTargetAbs = objFS.GetAbsolutePathName(ShortcutTarget)

  Dim ShortcutTargetShortPath : ShortcutTargetShortPath = ""

  If Not IsPathExistsNoPrefix(ShortcutTargetAbs) Then
    ShortcutTargetShortPath = GetShortPath(ShortcutTargetAbs)
  End If

  If Len(ShortcutTargetShortPath) > 0 Then
    If PrintAssign Then
      PrintOrEchoLine GetShortcutPropertyNameToPrint("TargetPath") & "(short)=" & ShortcutTargetShortPath
    End If

    SetShortcutProperty "TargetPath", ShortcutTargetShortPath

    ' reread `TargetPath`
    ShortcutTarget = GetShortcutProperty("TargetPath")

    If PrintAssigned Then
      PrintOrEchoLine GetShortcutPropertyNameToPrint("TargetPath") & "(assigned)=" & ShortcutTarget
    End If
  End If
End If

If ShortcutWorkingDirectoryAssigned Then
  If PrintAssign Then
    PrintOrEchoLine GetShortcutPropertyNameToPrint("WorkingDirectory") & "=" & ShortcutWorkingDirectoryToAssign
  End If

  SetShortcutProperty "WorkingDirectory", ShortcutWorkingDirectoryToAssign

  ' reread `WorkingDirectory`
  ShortcutWorkingDirectory = GetShortcutProperty("WorkingDirectory")

  If PrintAssigned Then
    PrintOrEchoLine GetShortcutPropertyNameToPrint("WorkingDirectory") & "(assigned)=" & ShortcutWorkingDirectory
  End If

  If AllowDOSWorkingDirectory Then
    Dim ShortcutWorkingDirectoryAbs : ShortcutWorkingDirectoryAbs = objFS.GetAbsolutePathName(ShortcutWorkingDirectory)

    Dim ShortcutWorkingDirectoryShortPath : ShortcutWorkingDirectoryShortPath = ""

    If Not FolderExistsNoPrefix(ShortcutWorkingDirectory) Then
      ShortcutWorkingDirectoryShortPath = GetFolderShortPath(ShortcutWorkingDirectory)
    End If

    If Len(ShortcutWorkingDirectoryShortPath) > 0 Then
      If PrintAssign Then
        PrintOrEchoLine GetShortcutPropertyNameToPrint("WorkingDirectory") & "(short)=" & ShortcutWorkingDirectoryShortPath
      End If

      SetShortcutProperty "WorkingDirectory", ShortcutWorkingDirectoryShortPath

      ' reread `WorkingDirectory`
      ShortcutWorkingDirectory = GetShortcutProperty("WorkingDirectory")

      If PrintAssigned Then
        PrintOrEchoLine GetShortcutPropertyNameToPrint("WorkingDirectory") & "(assigned)=" & ShortcutWorkingDirectory
      End If
    End If
  End If
End If

objSC.Save
