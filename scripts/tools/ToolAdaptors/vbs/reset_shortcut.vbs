''' Resets the Windows shortcut file using inner value(s).

''' USAGE:
'''   reset_shortcut.vbs
'''     [-CD <CurrentDirectoryPath>]
'''     [-no-backup] [-backup-dir]
'''     [-no-restore-mdate]
'''     [-obj] [-ignore-unexist]
'''     [-reset-wd[-from-target-path]]
'''     [-reset-target-path-from-wd]
'''     [-reset-target-path-from-desc]
'''     [-reset-target-name-from-file-path]
'''     [-reset-target-drive-from-file-path]
'''     [-allow-auto-recover]
'''     [-allow-target-type-change] [-allow-target-path-reassign]
'''     [-allow-dos-current-dir] [-allow-dos-target-path] [-allow-dos-wd] [-allow-dos-paths]
'''     [-use-getlink | -g] [-print-remapped-names | -k]
'''     [-p[rint-assign]] [-print-assigned | -pd]
'''     [-q]
'''     [--]
'''       <ShortcutFilePath>

''' CAUTION:
'''   WScript.Shell can not handle all Unicode characters in path properties,
'''   including characters in the path to a shortcut file.
'''   Details: https://stackoverflow.com/questions/39365489/how-do-you-keep-diacritics-in-shortcut-paths

''' CAUTION:
'''   The Windows Shell COM component does not handle unlinked or unexisted
'''   `TargetPath` or `LinkTarget` property correctly. To ensure it does read
'''   the property, you have to resolve or replicate the path on the file
'''   system before read the property!
'''   To be able to do it, you can read the `WorkingDirectory` property (it is
'''   accessible irrespective to the target path property) and use it to
'''   resolve/replicate the target path before read the target path property.

''' DESCRIPTION:
'''   Does save shortcut to let the Windows Shell component to validate all
'''   properties and rewrite the shortcut file even if nothing is changed
'''   reducing the shortcut content.
'''
'''   Does apply only if required to avoid a shortcut accident corruption by
'''   the Windows Shell component internal guess logic (see `-ignore-unexist`
'''   option description).
'''
'''   The save does not apply until at least one property is changed.
'''   A path property assign does not apply if a path property does not exist
'''   and `-ignore-unexist` option is not used or a new not empty path property
'''   value already equal case insensitively to an old path property value.
'''
'''   If the save applies, then by default backups a shortcut before the save.
'''
'''   By default the File Modification timestamp does restore after the save to
'''   to retain a shortcut sort order by the date in a folder.
'''
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''
'''   -CD <CurrentDirectoryPath>
'''     Changes current directory to <CurrentDirectoryPath> before the
'''     execution.
'''
'''   -no-backup
'''     Disables a shortcut backup.
'''     Backup generates a directory with a backup file in the directory with
'''     the shortcut in form:
'''     `YYYY'MM'DD.backup/HH'mm'ss''NNN-<ShortcutName>`
'''     This form will reduce quantity of generated directories per each backup
'''     file and in the same time does backup each shortcut in each call.
'''
'''   -backup-dir
'''     Path to the directory to store backed up shortcuts. Used instead of
'''     generated one, for example, in case of an external script call from a
'''     loop.
'''     Has no effect if directory does not exist.
'''
'''   -no-restore-mdate
'''     Disable a shortcut file modification date restore.
'''
'''   -obj
'''     By default the target path does used as a file path. Use this flag to
'''     handle it as an object string and reduce (but not avoid) path functions
'''     call on it.
'''     Can not be used together with `-q` flag.
'''     Has no effect in case of `-reset-*` or `-allow-auto-recover` flags.
'''
'''   -ignore-unexist
'''     By default TargetPath and WorkingDirectory does check on existence
'''     before assign. Use this flag to skip the check.
'''     Can not be used together with `-allow-auto-recover` flag.
'''     Has no effect for TargetPath if `-obj` flag is defined.
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
'''     Has effect if `-obj` flag is used.
'''
'''   -reset-target-path-from-wd
'''     Reset TargetPath from WorkingDirectory leaving the file name as is.
'''     Does not apply if WorkingDirectory or TargetPath is empty.
'''     Has effect if `-obj` flag is used.
'''
'''   -reset-target-path-from-desc
'''     Reset TargetPath from Description.
'''     Does not apply if Description is empty or not a path.
'''     Has no effect if TargetPath is already resetted.
'''     Has effect if `-obj` flag is used.
'''
'''   -reset-target-name-from-file-path
'''     Reset TargetPath name from shortcut file name without `.lnk` extension.
'''
'''   -reset-target-drive-from-file-path
'''     Reset TargetPath drive from shortcut file drive.
'''
'''   -allow-auto-recover
'''     Allow auto recover by using the guess logic applying in this order:
'''     1. Reset WorkingDirectory from TargetPath.
'''        Has no effect if TargetPath is empty.
'''        Has no effect if resulted WorkingDirectory does not exist.
'''     2. Reset TargetPath from WorkingDirectory leaving the file name as is.
'''        Has no effect if WorkingDirectory or TargetPath is empty.
'''        Has no effect if resulted TargetPath does not exist.
'''     3. Reset TargetPath from Description.
'''        Has no effect if Description is empty or not a path.
'''        Has no effect if resulted TargetPath does not exist.
'''     4. Reset TargetPath name from shortcut file name without `.lnk`
'''        extension.
'''        Has no effect if resulted TargetPath does not exist.
'''     5. Reset TargetPath/WorkingDirectory drive from shortcut file drive.
'''        Has no effect if resulted TargetPath/WorkingDirectory does not
'''        exist.
'''     6. The rest combinations of above steps 1-5 with the order preserving:
'''        1+5, 2+4, 2+5, 3+4, 3+5, 2+4+5, 3+4+5
'''     Can not be used together with `-ignore-unexist` flag.
'''
'''   -allow-target-type-change
'''     Allow the target property type change on assignment.
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
'''
'''   -allow-dos-target-path
'''     Rereads target path after assign and if it does not exist, then
'''     reassigns it by a reduced DOS path version.
'''     It is useful when you want to create not truncated shortcut target file
'''     path to open it by an old version application which does not support
'''     long paths or Win32 Namespace paths, but supports open target paths by
'''     a shortcut file.
'''     Has no effect if path does not exist.
'''     Has no effect if `-obj` flag is used.
'''
'''   -allow-dos-wd
'''     Rereads working directory after assign and if it does not exist, then
'''     reassign it by a reduced DOS path version.
'''     Has no effect if path does not exist.
'''
'''   -allow-dos-paths
'''     Implies all `-allow-dos-*` flags.
'''
'''   -use-getlink | -g
'''     Use `GetLink` property instead of `CreateShortcut` method.
'''     Alternative interface to assign path properties with Unicode
'''     characters.
'''
'''   -print-remapped-names | -k
'''     Print remapped key names instead of `CreateShortcut` method object
'''     names.
'''     Has no effect if `-use-getlink` flag is not used.
'''
'''   -p[rint-assign]
'''     Print property assign before assign.
'''
'''   -print-assigned | -pd
'''     Rereads property after assign and prints it.
'''
'''   -q
'''     Always quote target path argument if has no quote characters.
'''     Can not be used together with  `-obj` flag.

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

''' CAUTION:
'''   The `WScript.std[out|err].WriteLine STR` functions has issue with the
'''   last line desynchronization between streams.
'''   To workaround use `WScript.std[out|err].Write STR & vbCrLf` instead.

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
  WScript.stdout.Write str & vbCrLf
  If err = 5 Then ' Access is denied
    WScript.stdout.Write FixStrToPrint(str) & vbCrLf
  ElseIf err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

Sub PrintOrEchoErrorLine(str)
  On Error Resume Next
  WScript.stderr.Write str & vbCrLf
  If err = 5 Then ' Access is denied
    WScript.stderr.Write FixStrToPrint(str) & vbCrLf
  ElseIf err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim PrintAssign : PrintAssign = False
Dim PrintAssigned : PrintAssigned = False

Dim BackupShortcut : BackupShortcut = True
Dim BackupDir : BackupDir = ""
Dim RestoreShortcutFileMDate : RestoreShortcutFileMDate = True

Dim IgnoreUnexist : IgnoreUnexist = False

Dim ResetWorkingDirFromTargetPath : ResetWorkingDirFromTargetPath = False
Dim ResetTargetPathFromWorkingDir : ResetTargetPathFromWorkingDir = False
Dim ResetTargetPathFromDesc : ResetTargetPathFromDesc = False
Dim ResetTargetNameFromFilePath : ResetTargetNameFromFilePath = False
Dim ResetTargetDriveFromFilePath : ResetTargetDriveFromFilePath = False

Dim AllowAutoRecover : AllowAutoRecover = False
Dim AllowTargetTypeChange : AllowTargetTypeChange = False
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
      ElseIf arg = "-no-backup" Then
        BackupShortcut = False
      ElseIf arg = "-backup-dir" Then
        i = i + 1
        BackupDir = WScript.Arguments(i)
      ElseIf arg = "-no-restore-mdate" Then
       RestoreShortcutFileMDate = False
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
      ElseIf arg = "-allow-target-type-change" Then
        AllowTargetTypeChange = True
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
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <ShortcutFilePath> argument is not defined."
  WScript.Quit 255
End If

If AllowDOSPaths Then
  AllowDOSCurrentDirectory = AllowDOSPaths
  AllowDOSTargetPath = AllowDOSPaths
  AllowDOSWorkingDirectory = AllowDOSPaths
End If

' functions

Function GetShortcut(ShortcutFilePathToOpen)
  If Not UseGetLink Then
    ' CAUTION:
    '   Base `CreateShortcut` method does not support all Unicode characters.
    '   Use `GetLink` property (`-use-getlink` flag) instead to workaround that.
    '
    Set GetShortcut = objShell.CreateShortcut(ShortcutFilePathToOpen)
  Else
    Dim objShellApp : Set objShellApp = CreateObject("Shell.Application")
    Dim ShortcutParentPath : ShortcutParentPath = objFS.GetParentFolderName(ShortcutFilePathToOpen)
    Dim objNamespace, objFile
    If Len(ShortcutParentPath) > 0 Then
      Set objNamespace = objShellApp.Namespace(ShortcutParentPath)
      Set objFile = objNamespace.ParseName(objFS.GetFileName(ShortcutFilePathToOpen))
    Else
      Set objNamespace = objShellApp.Namespace(ShortcutFilePathToOpen)
      Set objFile = objNamespace.Self
    End if

    If IsNothing(objFile) Then
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": error: path is not parsed." & vbCrLf & _
        WScript.ScriptName & ": info: Path=`" & ShortcutFilePathToOpen & "`"
      WScript.Quit 128
    End If

    If objFile.IsLink Then
      Set GetShortcut = objFile.GetLink
    Else
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": error: file is not a shortcut." & vbCrLf & _
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

Function GetExistedFileShortPath(FilePathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  Dim File : Set File = objFS.GetFile("\\?\" & FilePathAbs)
  GetExistedFileShortPath = File.ShortPath
  If Left(GetExistedFileShortPath, 4) = "\\?\" Then
    GetExistedFileShortPath = Mid(GetExistedFileShortPath, 5)
  End If
End Function

Function GetExistedFolderShortPath(FolderPathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  Dim Folder : Set Folder = objFS.GetFolder("\\?\" & FolderPathAbs & "\")
  GetExistedFolderShortPath = Folder.ShortPath
  If Left(GetExistedFolderShortPath, 4) = "\\?\" Then
    GetExistedFolderShortPath = Mid(GetExistedFolderShortPath, 5)
  End If
End Function

Function GetShortPath(PathAbs)
  If objFS.FileExists("\\?\" & PathAbs) Then
    GetShortPath = GetExistedFileShortPath(PathAbs)
  ElseIf objFS.FolderExists("\\?\" & PathAbs) Then
    GetShortPath = GetExistedFolderShortPath(PathAbs)
  Else
    GetShortPath = ""
  End If
End Function

Function GetFolderShortPath(PathAbs)
  If objFS.FolderExists("\\?\" & PathAbs) Then
    GetShortPath = GetExistedFolderShortPath(PathAbs)
  Else
    GetShortPath = ""
  End If
End Function

Function IsPathExists(Path)
  If objFS.FileExists(Path) Or objFS.FolderExists(Path) Then
    IsPathExists = True
  Else
    IsPathExists = False
  End If
End Function

Function GetFileModificationDate(Path)
  Dim objShellApp : Set objShellApp = CreateObject("Shell.Application")

  Dim ParentPath : ParentPath = objFS.GetParentFolderName(Path)
  Dim objNamespace, objFile

  If Len(ParentPath) > 0 Then
    Set objNamespace = objShellApp.Namespace(ParentPath)
    Set objFile = objNamespace.ParseName(objFS.GetFileName(Path))
  Else
    Set objNamespace = objShellApp.Namespace(Path)
    Set objFile = objNamespace.Self
  End if

  If IsNothing(objFile) Then
    GetFileModificationDate = ""
    Exit Function
  End If

  GetFileModificationDate = objFile.ModifyDate
End Function

Function SetFileModificationDate(Path, FileDate)
  Dim objShellApp : Set objShellApp = CreateObject("Shell.Application")

  Dim ParentPath : ParentPath = objFS.GetParentFolderName(Path)
  Dim objNamespace, objFile

  If Len(ParentPath) > 0 Then
    Set objNamespace = objShellApp.Namespace(ParentPath)
    Set objFile = objNamespace.ParseName(objFS.GetFileName(Path))
  Else
    Set objNamespace = objShellApp.Namespace(Path)
    Set objFile = objNamespace.Self
  End if

  If IsNothing(objFile) Then
    Exit Function
  End If

  objFile.ModifyDate = FileDate
End Function

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

' change current directory before any file system request because of relative paths
If ChangeCurrentDirectoryExist Then
  Dim ChangeCurrentDirectoryAbs : ChangeCurrentDirectoryAbs = objFS.GetAbsolutePathName(ChangeCurrentDirectory) ' CAUTION: can alter a path character case if path exists

  ' remove `\\?\` prefix
  If Left(ChangeCurrentDirectoryAbs, 4) = "\\?\" Then
    ChangeCurrentDirectoryAbs = Mid(ChangeCurrentDirectoryAbs, 5)
  End If

  ' test on path existence including long path
  Dim IsCurrentDirectoryExist : IsCurrentDirectoryExist = objFS.FolderExists("\\?\" & ChangeCurrentDirectoryAbs)
  If Not IsCurrentDirectoryExist Then
    PrintOrEchoErrorLine _
      WScript.ScriptName & ": error: could not change current directory:" & vbCrLf & _
      WScript.ScriptName & ": info: CurrentDirectory=`" & ChangeCurrentDirectoryAbs & "`"
    WScript.Quit 1
  End If

  ' test on long path existence
  If (Not AllowDOSCurrentDirectory) Or objFS.FolderExists(ChangeCurrentDirectoryAbs) Then
    ' doesn't care or is not long path
    objShell.CurrentDirectory = ChangeCurrentDirectoryAbs
  Else
    ' translate into short path unconditionally
    objShell.CurrentDirectory = GetExistedFolderShortPath(ChangeCurrentDirectoryAbs)
  End If
End If

Dim ShortcutFilePath : ShortcutFilePath = cmd_args(0)

Dim ShortcutFilePathAbs : ShortcutFilePathAbs = objFS.GetAbsolutePathName(ShortcutFilePath) ' CAUTION: can alter a path character case if path exists

' remove `\\?\` prefix
If Left(ShortcutFilePathAbs, 4) = "\\?\" Then
  ShortcutFilePathAbs = Mid(ShortcutFilePathAbs, 5)
End If

' test on path existence including long path
Dim IsShortcutFileExist : IsShortcutFileExist = objFS.FileExists("\\?\" & ShortcutFilePathAbs)
If Not IsShortcutFileExist Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: shortcut file does not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: ShortcutFilePath=`" & ShortcutFilePathAbs & "`"
  WScript.Quit 10
End If

Dim ShortcutFileModificationDate
Dim ShortcutFilePathToOpen

' test on long path existence
If objFS.FileExists(ShortcutFilePathAbs) Then
  ' is not long path
  ShortcutFilePathToOpen = ShortcutFilePathAbs
Else
  ' translate into short path
  ShortcutFilePathToOpen = GetExistedFileShortPath(ShortcutFilePathAbs)
End If

If RestoreShortcutFileMDate Then
  ' get shortcut file modification date before open it
  ShortcutFileModificationDate = GetFileModificationDate(ShortcutFilePathToOpen)
End If

Dim objSC : Set objSC = GetShortcut(ShortcutFilePathToOpen)

' read TargetPath unconditionally

ShortcutTarget = GetShortcutProperty("TargetPath")

If Len(ShortcutTarget) > 1 And Left(ShortcutTarget, 1) = Chr(34) And Right(ShortcutTarget, 1) = Chr(34) Then
  ShortcutTargetUnquoted = Mid(ShortcutTarget, 2, Len(ShortcutTarget) - 2)
Else
  ShortcutTargetUnquoted = ShortcutTarget
End If

Dim ShortcutTargetDirExist : ShortcutTargetDirExist = False

If Len(ShortcutTargetUnquoted) > 0 Then
  If objFS.FileExists(ShortcutTargetUnquoted) Then
    ShortcutTargetExist = True
  ElseIf objFS.FolderExists(ShortcutTargetUnquoted) Then
    ShortcutTargetDirExist = True
    ShortcutTargetExist = True
  End If
Else
  ShortcutTargetEmpty = True
End If

If AlwaysQuote And InStr(ShortcutTargetUnquoted, Chr(34)) = 0 Then
  ShortcutTarget = Chr(34) & ShortcutTargetUnquoted & Chr(34)
End If

' read WorkingDirectory unconditionally

ShortcutWorkingDirectory = GetShortcutProperty("WorkingDirectory")

If Len(ShortcutWorkingDirectory) > 1 And Left(ShortcutWorkingDirectory, 1) = Chr(34) And Right(ShortcutWorkingDirectory, 1) = Chr(34) Then
  ShortcutWorkingDirectoryUnquoted = Mid(ShortcutWorkingDirectory, 2, Len(ShortcutWorkingDirectory) - 2)
Else
  ShortcutWorkingDirectoryUnquoted = ShortcutWorkingDirectory
End If

If Len(ShortcutWorkingDirectoryUnquoted) > 0 Then
  If objFS.FolderExists(ShortcutWorkingDirectoryUnquoted) Then
    ShortcutWorkingDirectoryExist = True
  End If
Else
  ShortcutWorkingDirectoryEmpty = True
End If

' read Description conditionally

Dim ShortcutDescDirExist : ShortcutDescDirExist = False

If ResetTargetPathFromDesc Or AllowAutoRecover Then
  ShortcutDesc = GetShortcutProperty("Description")

  If Len(ShortcutDesc) > 1 And Left(ShortcutDesc, 1) = Chr(34) And Right(ShortcutDesc, 1) = Chr(34) Then
    ShortcutDescUnquoted = Mid(ShortcutDesc, 2, Len(ShortcutDesc) - 2)
  Else
    ShortcutDescUnquoted = ShortcutDesc
  End If

  If Len(ShortcutDescUnquoted) > 0 Then
    If objFS.FileExists(ShortcutDescUnquoted) Then
      ShortcutDescExist = True
    ElseIf objFS.FolderExists(ShortcutDescUnquoted) Then
      ShortcutDescDirExist = True
      ShortcutDescExist = True
    End If
  Else
    ShortcutDescEmpty = True
  End If
End If

' 1

If ResetWorkingDirFromTargetPath Then
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
        ShortcutWorkingDirectoryToAssign = objFS.GetParentFolderName(ShortcutTargetUnquoted)
      Else
        ShortcutWorkingDirectoryToAssign = ShortcutTargetUnquoted ' use the whole path
      End If

      If Not IgnoreUnexist Then
        ShortcutWorkingDirectoryToAssignExist = objFS.FolderExists(ShortcutWorkingDirectoryToAssign)

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
        WScript.ScriptName & ": warning: WorkingDirectory reset is skipped because WorkingDirectory is empty and TargetPath is existed directory path:" & vbCrLf & _
        WScript.ScriptName & ": info: TargetPath=`" & ShortcutTargetUnquoted & "`"
    End If
  Else
    PrintOrEchoErrorLine WScript.ScriptName & ": error: shortcut target path is empty."
    WScript.Quit 10
  End If
End If

' 2

If ResetTargetPathFromWorkingDir Then
  If ShortcutTargetEmpty And Not AllowTargetTypeChange Then
    PrintOrEchoErrorLine WScript.ScriptName & ": error: shortcut target path is empty."
    WScript.Quit 10
  End If

  If ShortcutWorkingDirectoryEmpty Then
    PrintOrEchoErrorLine WScript.ScriptName & ": error: shortcut working directory path is empty."
    WScript.Quit 11
  End If

  ShortcutTargetToAssign = ShortcutWorkingDirectoryUnquoted & "\" & objFS.GetFileName(ShortcutTargetUnquoted)

  If Not IgnoreUnexist Then
    ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

    If Not ShortcutTargetToAssignExist Then
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": error: shortcut target path to assign does not exist:" & vbCrLf & _
        WScript.ScriptName & ": info: TargetPath=`" & ShortcutTargetToAssign & "`"
      WScript.Quit 20
    End If
  End If

  ShortcutTargetAssigned = True
End If

' 3

If ResetTargetPathFromDesc And (Not ShortcutTargetAssigned) Then
  If (Not ShortcutDescEmpty) And ShortcutDescExist Then
    ShortcutTargetToAssign = ShortcutDescUnquoted

    If Not IgnoreUnexist Then
      ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

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
      WScript.ScriptName & ": error: shortcut description is empty or not exist:" & vbCrLf & _
      WScript.ScriptName & ": info: Description=`" & ShortcutDescUnquoted & "`"
    WScript.Quit 13
  End If
End If

' 4

Dim ShortcutTargetExt
Dim ShortcutTargetExtLen

If ResetTargetNameFromFilePath Then
  If Not ShortcutTargetAssigned Then
    ShortcutTargetToAssign = objFS.GetParentFolderName(ShortcutTargetUnquoted) & "\" & objFS.GetFileName(ShortcutFilePath)
    ShortcutTargetAssigned = True
  Else
    ShortcutTargetToAssign = objFS.GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)
  End If

  ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
  ShortcutTargetExtLen = Len(ShortcutTargetExt)
  If ShortcutTargetExtLen > 0 Then
    ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
  End If
End If

' 5

If ResetTargetDriveFromFilePath And Mid(ShortcutTargetUnquoted, 2, 1) = ":" Then
  If Not ShortcutTargetAssigned Then
    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetUnquoted, 3)
    ShortcutTargetAssigned = True
  Else
    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetUnquoted, 3)
  End If
End If

If AllowAutoRecover Then
  ' 1+5
  If (Not ShortcutWorkingDirectoryAssigned) And (Not ShortcutTargetEmpty) And Mid(ShortcutTargetUnquoted, 2, 1) = ":" Then
    If (Not ShortcutTargetDirExist) Or (Not ShortcutWorkingDirectoryEmpty) Then
      If Not ShortcutTargetDirExist Then
        ShortcutWorkingDirectoryToAssign = objFS.GetParentFolderName(ShortcutTargetUnquoted)
      Else
        ShortcutWorkingDirectoryToAssign = ShortcutTargetUnquoted ' use the whole path
      End If

      ShortcutWorkingDirectoryToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutWorkingDirectoryToAssign, 3)

      ShortcutWorkingDirectoryToAssignExist = objFS.FolderExists(ShortcutWorkingDirectoryToAssign)

      If ShortcutWorkingDirectoryToAssignExist Then
        ShortcutWorkingDirectoryAssigned = True
      End If
    End If
  End If

  ' 2+4

  If (Not ShortcutTargetAssigned) And (Not ShortcutTargetEmpty) And (Not ShortcutWorkingDirectoryEmpty) Then
    ShortcutTargetToAssign = ShortcutWorkingDirectoryUnquoted & "\" & objFS.GetFileName(ShortcutTargetUnquoted)

    ShortcutTargetToAssign = objFS.GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)

    ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
    ShortcutTargetExtLen = Len(ShortcutTargetExt)
    If ShortcutTargetExtLen > 0 Then
      ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
    End If

    ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      ShortcutTargetAssigned = True
    End If
  End If

  ' 2+5

  If (Not ShortcutTargetAssigned) And (Not ShortcutTargetEmpty) And (Not ShortcutWorkingDirectoryEmpty) And Mid(ShortcutWorkingDirectoryUnquoted, 2, 1) = ":" Then
    ShortcutTargetToAssign = ShortcutWorkingDirectoryUnquoted & "\" & objFS.GetFileName(ShortcutTargetUnquoted)

    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetToAssign, 3)

    ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      ShortcutTargetAssigned = True
    End If
  End If

  ' 3+4

  If (Not ShortcutTargetAssigned) And (Not ShortcutTargetEmpty) And (Not ShortcutDescEmpty) And ShortcutDescExist Then
    ShortcutTargetToAssign = ShortcutDescUnquoted

    ShortcutTargetToAssign = objFS.GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)

    ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
    ShortcutTargetExtLen = Len(ShortcutTargetExt)
    If ShortcutTargetExtLen > 0 Then
      ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
    End If

    ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      ShortcutTargetAssigned = True
    End If
  End If

  ' 3+5

  If (Not ShortcutTargetAssigned) And (Not ShortcutTargetEmpty) And (Not ShortcutDescEmpty) And ShortcutDescExist And Mid(ShortcutDescUnquoted, 2, 1) = ":" Then
    ShortcutTargetToAssign = ShortcutDescUnquoted

    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetToAssign, 3)

    ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      ShortcutTargetAssigned = True
    End If
  End If

  ' 2+4+5

  If (Not ShortcutTargetAssigned) And (Not ShortcutTargetEmpty) And (Not ShortcutWorkingDirectoryEmpty) And Mid(ShortcutWorkingDirectoryUnquoted, 2, 1) = ":" Then
    ShortcutTargetToAssign = ShortcutWorkingDirectoryUnquoted & "\" & objFS.GetFileName(ShortcutTargetUnquoted)

    ShortcutTargetToAssign = objFS.GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)

    ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
    ShortcutTargetExtLen = Len(ShortcutTargetExt)
    If ShortcutTargetExtLen > 0 Then
      ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
    End If

    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetToAssign, 3)

    ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      ShortcutTargetAssigned = True
    End If
  End If

  ' 3+4+5

  If (Not ShortcutTargetAssigned) And (Not ShortcutTargetEmpty) And (Not ShortcutDescEmpty) And ShortcutDescExist And Mid(ShortcutDescUnquoted, 2, 1) = ":" Then
    ShortcutTargetToAssign = ShortcutDescUnquoted

    ShortcutTargetToAssign = objFS.GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)

    ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
    ShortcutTargetExtLen = Len(ShortcutTargetExt)
    If ShortcutTargetExtLen > 0 Then
      ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
    End If

    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetToAssign, 3)

    ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      ShortcutTargetAssigned = True
    End If
  End If
End If

If ShortcutTargetAssigned Then
  If AlwaysQuote And InStr(ShortcutTargetToAssign, Chr(34)) = 0 Then
    ShortcutTargetToAssign = Chr(34) & ShortcutTargetToAssign & Chr(34)
  End If

  If PrintAssign Then
    PrintOrEchoLine GetShortcutPropertyNameToPrint("TargetPath") & "=" & ShortcutTargetToAssign
  End If

  SetShortcutProperty "TargetPath", ShortcutTargetToAssign

  ' reread `TargetPath`
  ShortcutTarget = GetShortcutProperty("TargetPath")

  If PrintAssigned Then
    PrintOrEchoLine GetShortcutPropertyNameToPrint("TargetPath") & "(assigned)=" & ShortcutTarget
  End If
ElseIf AllowTargetPathReassign Then
  If Not ShortcutTargetObj Then
    If ShortcutTargetExist Or IgnoreUnexist Then
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
  Else
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

  If Not IsPathExists(ShortcutTargetAbs) Then
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

    If Not objFS.FolderExists(ShortcutWorkingDirectory) Then
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

If ShortcutTargetAssigned Or ShortcutWorkingDirectoryAssigned Then
  If BackupShortcut Then
    Dim NowDateTime : NowDateTime = Now ' copy
    Dim t : t = Timer ' copy for milliseconds resolution

    Dim HH : HH = Right("0" & DatePart("h", NowDateTime), 2)
    Dim mm_ : mm_ = Right("0" & DatePart("n", NowDateTime), 2)
    Dim ss : ss = Right("0" & DatePart("s", NowDateTime), 2)
    Dim ms : ms = Right("0" & Int((t - Int(t)) * 1000), 3)

    Dim BackupTimeName : BackupTimeName = HH & "'" & mm_ & "'" & ss & "''" & ms

    Dim ShortcutFileDir : ShortcutFileDir = objFS.GetParentFolderName(ShortcutFilePathToOpen)

    Dim ShortcutFileBackupDir
    Dim backup_dir_path_abs

    ' NOTE:
    '   The `*Exists` methods will return False on a long path without `\\?\` prefix.
    '

    If Len(BackupDir) > 0 Then
      ' remove `\\?\` prefix
      If Left(BackupDir, 4) = "\\?\" Then
        BackupDir = Mid(BackupDir, 5)
      End If

      If Len(BackupDir) > 0 Then
        ' check on absolute path
        If IsPathAbsolute(BackupDir) Then
          backup_dir_path_abs = objFS.GetAbsolutePathName(BackupDir)
        Else
          backup_dir_path_abs = objFS.GetAbsolutePathName(ShortcutFileDir & "\" & BackupDir)
        End If

        If objFS.FolderExists("\\?\" & backup_dir_path_abs) Then
          ShortcutFileBackupDir = backup_dir_path_abs
        End If
      End If
    End If

    If Not (Len(ShortcutFileBackupDir) > 0) Then
      ' YYYY'MM'DD.backup
      Dim YYYY : YYYY = DatePart("yyyy", NowDateTime)
      Dim MM : MM = Right("0" & DatePart("m", NowDateTime), 2)
      Dim DD : DD = Right("0" & DatePart("d", NowDateTime), 2)

      Dim BackupDateName : BackupDateName = YYYY & "'" & MM & "'" & DD

      ShortcutFileBackupDir = ShortcutFileDir & "\" & BackupDateName & ".backup"
    End If

    If Not objFS.FolderExists("\\?\" & ShortcutFileBackupDir) Then
      objFS.CreateFolder "\\?\" & ShortcutFileBackupDir

      If (err <> 0) And err <> &h800A003A& Then ' File already exists
        PrintOrEchoErrorLine _
          WScript.ScriptName & ": error: could not create a shortcut file backup directory:" & vbCrLf & _
          WScript.ScriptName & ": info: BackupFilePath=`" & ShortcutFileBackupDir & "`" & vbCrLf & _
          WScript.ScriptName & ": info: err=" & err
        WScript.Quit 100
      End If
    End If

    ' YYYY'MM'DD.backup/HH'mm'ss''NNN-<ShortcutName>
    Dim ShortcutBackupFilePath : ShortcutBackupFilePath = _
      ShortcutFileBackupDir & "\" & BackupTimeName & "-" & objFS.GetFileName(ShortcutFilePathAbs)

    ' a copy from `tacklelib` script: `vbs/tacklelib/tools/shell/copy_file.vbs`
    Sub CopyFile(from_file_str, to_file_str)
      Dim fs_obj : Set fs_obj = CreateObject("Scripting.FileSystemObject")

      Dim from_file_path_abs : from_file_path_abs = objFS.GetAbsolutePathName(from_file_str)
      Dim to_file_path_abs : to_file_path_abs = objFS.GetAbsolutePathName(to_file_str)

      ' NOTE:
      '   The `*Exists` methods will return False on a long path without `\\?\` prefix.
      '

      ' remove `\\?\` prefix
      If Left(from_file_path_abs, 4) = "\\?\" Then
        from_file_path_abs = Mid(from_file_path_abs, 5)
      End If

      If Not objFS.FileExists("\\?\" & from_file_path_abs) Then
        PrintOrEchoErrorLine _
          WScript.ScriptName & ": error: input file path does not exist:" & vbCrLf & _
          WScript.ScriptName & ": info: InputPath=`" & from_file_path_abs & "`"
        WScript.Quit 1
      End If

      ' remove `\\?\` prefix
      If Left(to_file_path_abs, 4) = "\\?\" Then
        to_file_path_abs = Mid(to_file_path_abs, 5)
      End If

      Dim to_file_path_abs_last_back_slash_offset : to_file_path_abs_last_back_slash_offset = InStrRev(to_file_path_abs, "\")

      Dim to_file_parent_dir_path_abs
      Dim to_file_name
      If to_file_path_abs_last_back_slash_offset > 0 Then
        to_file_parent_dir_path_abs = Left(to_file_path_abs, to_file_path_abs_last_back_slash_offset - 1)
        to_file_name = Mid(to_file_path_abs, to_file_path_abs_last_back_slash_offset + 1)
      Else
        to_file_parent_dir_path_abs = to_file_path_abs
        to_file_name = ""
      End If

      ' test on path existence including long path
      If Not objFS.FolderExists("\\?\" & to_file_parent_dir_path_abs) Then
        PrintOrEchoErrorLine _
          WScript.ScriptName & ": error: output parent directory path does not exist:" & vbCrLf & _
          WScript.ScriptName & ": info: OutputPath=`" & to_file_path_abs & "`"
        WScript.Quit 2
      End If

      ' test on long path existence
      If Not objFS.FileExists(from_file_path_abs) Then
        ' translate into short path
        from_file_path_abs = GetExistedFileShortPath(from_file_path_abs)
      End If

      ' test on long path existence
      If Not objFS.FolderExists(to_file_parent_dir_path_abs) Then
        ' translate into short path
        to_file_parent_dir_path_abs = GetExistedFolderShortPath(to_file_parent_dir_path_abs)
      End If

      to_file_path_abs = to_file_parent_dir_path_abs & "\" & to_file_name

      objFS.CopyFile from_file_path_abs, to_file_path_abs
    End Sub

    CopyFile ShortcutFilePathToOpen, ShortcutBackupFilePath

    If Err Then
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": error: could not backup a shortcut file:" & vbCrLf & _
        WScript.ScriptName & ": info: ShortcutFilePath=`" & ShortcutFilePathToOpen & "`" & vbCrLf & _
        WScript.ScriptName & ": info: BackupFilePath=`" & ShortcutBackupFilePath & "`" & vbCrLf & _
        WScript.ScriptName & ": info: err=" & err
      WScript.Quit 101
    End If
  End If

  objSC.Save

  Set objSC = Nothing ' close the reference

  If RestoreShortcutFileMDate And Len(ShortcutFileModificationDate) > 0 Then
    ' restore the file modification date
    SetFileModificationDate ShortcutFilePathToOpen, ShortcutFileModificationDate
  End If
Else
  WScript.Quit -1
End If