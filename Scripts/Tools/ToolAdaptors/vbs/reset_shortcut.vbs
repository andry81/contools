''' Resets existing Windows shortcut file.

''' CAUTION:
'''   WScript.Shell can not handle all Unicode characters in path properties, including characters in the path to a shortcut file.
'''   Details: https://stackoverflow.com/questions/39365489/how-do-you-keep-diacritics-in-shortcut-paths
'''

''' USAGE:
'''   reset_shortcut.vbs
'''     [-CD <CurrentDirectoryPath>]
'''     [-no-backup] [-ignore-unexist]
'''     [-reset-wd[-from-target-path]]
'''     [-reset-target-path-from-wd]
'''     [-reset-target-path-from-desc]
'''     [-reset-target-name-from-file-path]
'''     [-reset-target-drive-from-file-path]
'''     [-reset-target-path-by-rebase-to <BasePath>]
'''     [-allow-auto-recover]
'''     [-allow-auto-recover-by-rebase-to <BasePath>]
'''     [-allow-target-path-reassign] [-allow-wd-reassign]
'''     [-allow-dos-target-path] [-allow-dos-wd] [-allow-dos-paths]
'''     [-p[rint-assing]]
'''     [-q]
'''     [--]
'''     <ShortcutFilePath>

''' DESCRIPTION:
'''   Script to reset a shortcut without any standalone property value.
'''
'''   To specifically update a shortcut property field with a value do use
'''   `update_shortcut.*` script instead.
'''
'''   By default without any flags does NOT save a shortcut to avoid trigger
'''   the Windows Shell component to validate all properties and rewrites the
'''   shortcut file even if nothing is changed reducing the shortcut content.
'''   This additionally avoids a shortcut accident corruption by the Windows
'''   Shell component internal guess logic (see `-ignore-unexist` option
'''   description).
'''
'''   The save does not apply until at least one property is changed.
'''   A path property assign does not apply if a path property does not exist
'''   and `-ignore-unexist` option is not used or a new not empty path property
'''   value already equal case insensitively to an old path property value.
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
'''     Disables a shortcut backup as by default.
'''     Backup generates a directory with a backup file in the directory with
'''     the shortcut in form:
'''     `YYYY'MM'DD.backup/HH'mm'ss''NNN-<ShortcutName>`
'''     This form will reduce quantity of generated directories per each backup
'''     file and in the same time does backup of each shortcut for each call.
'''
'''   -ignore-unexist
'''     By default TargetPath and WorkingDirectory does check on existence
'''     before assign. Use this flag to skip the check.
'''
'''     CAUTION:
'''       The Windows Shell component does use a guess logic to restore
'''       unexisted or invalid target path or/and working directory properties.
'''       In some cases or OS versions it may lead to a path property
'''       corruption or even an entire shortcut corruption.
'''
'''       Details:
'''         https://learn.microsoft.com/en-us/windows/win32/shell/links#link-resolution
'''         https://github.com/libyal/liblnk/tree/HEAD/documentation/Windows%20Shortcut%20File%20(LNK)%20format.asciidoc#8-corruption-scenarios
'''         https://stackoverflow.com/questions/22382010/what-options-are-available-for-shell32-folder-getdetailsof/37061433#37061433
'''
'''       In the wild has been catched several cases of a shortcut corruption:
'''       - Shortcut path can change length from long path to short DOS path.
'''       - Shortcut path can change language characters localization from
'''         Unicode to ANSI with wrong code page.
'''       - Shortcut path can be vandalized like path end truncation or even
'''         the space characters replacement by the underscore character.
'''       - Shortcut can change type from a file shortcut to a directory
'''         shortcut with or without old path save into Description property.
'''       - Shortcut can be completely rewritten losing other properties and
'''         data.
'''
'''     Use this option with the caution.
'''
'''   -reset-target-drive-from-file-path
'''     Resets TargetPath drive from shortcut file drive.
'''     Has no effect if TargetPath is already resetted.
'''     Has no effect if TargetPath is empty.
'''     Has no effect if resulted TargetPath does not exist and
'''     `-ignore-unexist` is not used.
'''   -reset-wd-drive-from-file-path
'''     Resets WorkingDirectory drive from shortcut file drive.
'''     Has no effect if WorkingDirectory is already resetted.
'''     Has no effect if WorkingDirectory is empty.
'''     Has no effect if resulted WorkingDirectory does not exist and
'''     `-ignore-unexist` is not used.
'''   -reset-target-path-from-desc
'''     Resets TargetPath from Description.
'''     Has no effect if TargetPath is already resetted.
'''     Has no effect if Description is empty or not a path.
'''     Has no effect if resulted TargetPath does not exist and
'''     `-ignore-unexist` is not used.
'''   -reset-target-name-from-file-path
'''     Resets TargetPath name from shortcut file name without `.lnk`
'''     extension, plus without `<suffix>` in `<name>.ext<suffix>.lnk`,
'''     where `<suffix>` is in one of regexp forms:
'''       * ` - \w`
'''       * ` - \w \(\d+\)`
'''       * ` \(\d+\)`
'''     Has no effect if TargetPath is already resetted.
'''     Has no effect if resulted TargetPath is empty.
'''     Has no effect if resulted TargetPath does not exist and
'''     `-ignore-unexist` is not used.
'''   -reset-wd[-from-target-path]
'''     Resets WorkingDirectory from TargetPath.
'''     Has no effect if WorkingDirectory is already resetted.
'''     Has no effect if TargetPath is empty.
'''     Has no effect if resulted WorkingDirectory does not exist and 
'''     `-ignore-unexist` is not used.
'''   -reset-target-path-from-wd
'''     Resets TargetPath from WorkingDirectory leaving the file name as is.
'''     Has no effect if TargetPath is already resetted.
'''     Has no effect if WorkingDirectory or TargetPath is empty.
'''     Has no effect if resulted TargetPath does not exist and
'''     `-ignore-unexist` is not used.
'''   -reset-target-path-by-rebase-to <BasePath>
'''     Resets TargetPath by rebase to <BasePath>.
'''     Has no effect if TargetPath is already resetted.
'''     Has no effect if resulted TargetPath does not exist.
'''     Does not affect by `-ignore-unexist` flag.
'''
'''   -allow-auto-recover
'''     Allow auto recover by using the guess logic consisted of these steps:
'''     1. (ID=1) Use `-reset-target-drive-from-file-path` flag logic.
'''     2. (ID=2) Use `-reset-wd-drive-from-file-path` flag logic.
'''     3. (ID=3) Use `-reset-target-path-from-desc` flag logic.
'''     4. (ID=4) Use `-reset-target-name-from-file-path` flag logic.
'''     5. (ID=5) Use `-reset-wd[-from-target-path]` flag logic.
'''     6. (ID=6) Use `-reset-target-path-from-wd` flag logic.
'''
'''     The default order and combinations of above steps is:
'''       1, 2, 3, 4, 5, 6, 3+1+5, 3+1+4+5, 3+4+5, 2+6+4
'''
'''     The guess logic with steps combination has an altered conditions:
'''     * A step combination with TargetPath has no effect and get skipped if
'''       TargetPath is already resetted.
'''     * A step combination with WorkingDirectory does not skip if
'''       WorkingDirectory is already resetted
'''       Example:
'''         If WorkingDirectory did reset in combination of `5`, then it does
'''         not mean it should not reset in the next combination of `3+1+5`.
'''''''''''''''
'''     A step in a combination is skipped if a step property previous path does exist.
'''     Has no effect if a step property destination and source path are equal.
'''     Can not be used together with `-ignore-unexist` flag.
'''
'''     The guess logic stops when all properties declared to reset is
'''     resetted:
'''       TargetPath: 1, 3, 4, 6
'''       WorkingDirectory: 2, 5
'''
'''   -allow-auto-recover-by-rebase-to <BasePath>
'''     Allow auto recover by using the guess logic consisted of these steps:
'''     1. (ID=10) Use `-reset-target-path-by-rebase-to <BasePath>` option
'''        logic.
'''
'''     The default order and combinations of above steps is:
'''       10+5, 10+4+5
'''
'''     A step combination has no effect and get skipped if TargetPath is
'''     already resetted.
'''     Has no effect if destination previous path does exist.
'''     Has no effect if destination and source path are equal.
'''     Does not affect by `-ignore-unexist` flag.
'''
'''     The guess logic stops when TargetPath is resetted.
'''
'''   -allow-target-path-reassign
'''     Allow TargetPath reassign if path is case insensitively equal.
'''     Has no effect if TargetPath is already resetted.
'''     Has no effect if path does not exist and `-ignore-unexist` is not used.
'''     Implies TargetPath self reassign if has not been reset.
'''     CAUTION:
'''       This flag will trigger a shortcut save at any case.
'''   -allow-wd-reassign
'''     Allow WorkingDirectory reassign if path is case insensitively equal.
'''     Has no effect if WorkingDirectory is already resetted.
'''     Has no effect if path does not exist and `-ignore-unexist` is not used.
'''     Implies WorkingDirectory self reassign if has not been reset.
'''     CAUTION:
'''       This flag will trigger a shortcut save at any case.
'''
'''   -allow-dos-target-path
'''     Reread target path after assign and if it does not exist, then reassign
'''     it by a reduced DOS path version.
'''     It is useful when you want to create not truncated shortcut target file
'''     path to open it by an old version application which does not support
'''     long paths or Win32 Namespace paths, but supports open target paths by
'''     a shortcut file.
'''   -allow-dos-wd
'''     Reread working directory after assign and if it does not exist, then
'''     reassign it by a reduced DOS path version.
'''   -allow-dos-paths
'''     Reread a property with a path after assign and if it does not exist,
'''     then reassign it by a reduced DOS path version.
'''
'''   -p[rint-assign]
'''     Print assign.
'''   -q
'''     Always quote target path argument if has no quote characters.

''' CAUTION:
'''   The `-reset-*` implementation does not check previous path existence
'''   before assign.
'''   The `-reset-*` implementation does check new path existence before assign
'''   if `-ignore-unexist` flag is not defined.
'''   The `-allow-auto-recover*` implementation does check previous path
'''   existence before assign and does not assign if it is already existed.
'''   The `-allow-auto-recover*` implementation does check new path existence
'''   before assign and does not assign if it is not existed.

''' CAUTION:
'''   The `-allow-auto-recover*` does recover a path by check it's existence.
'''   This could lead to a path corruption through replace one existen path by
'''   another. For example, if TargetPath points existen path on drive `C` and
'''   WorkingDirectory points existen path on drive `D`, then depending on
'''   flags and options order then after a recover, TargetPath may point a path
'''   on drive `D` or WorkingDirectory may point a path on drive `C`.
'''   To avoid that kind of path corruption the `-allow-auto-recover*`
'''   implementation always checks previous path on existence before it's
'''   recover. But the `-reset-*` flags does not check a previous path on
'''   existence and always apply the reset.

''' NOTE: 
'''   The script by default does backup a shortcut, see `-no-backup` flag.

''' CAUTION:
'''   All `-reset-*` and `-allow-auto-recover*` flags and options forms a
'''   sequence and the order of these flags and options are important.

''' NOTE:
'''   1. Creation of a shortcut under ealier version of the Windows makes
'''      shortcut cleaner. For example, do use Windows XP instead of the
'''      Windows 7 and x86 instead of x64 to make a cleaner shortcut without
'''      redundant data.
'''   2. Creation of a shortcut to the `cmd.exe` with the current directory in
'''      the "%SYSTEMROOT%\system32" directory avoids generation of redundant
'''      path prefixes (offset) in the shortcut file internals.
'''   3. Update of a shortcut immediately after it's creation does cleanup
'''      shortcut from redundant data.

''' Example to create a minimalistic and clean version of a shortcut:
'''   >
'''   del /F /Q "%WINDIR%\System32\cmd_system32.lnk"
'''   make_shortcut.bat -CD "%WINDIR%\System32" -q cmd_system32.lnk ^%SystemRoot^%\System32\cmd.exe
'''   reset_shortcut.bat -CD "%WINDIR%\System32" -allow-target-path-reassign -q cmd_system32.lnk
''' Or
'''   >
'''   del /F /Q "%WINDIR%\System32\cmd_system32.lnk"
'''   make_shortcut.bat -CD "%WINDIR%\System32" -u cmd_system32.lnk "%22%25SystemRoot%25\System32\cmd.exe%22"
'''   reset_shortcut.bat -CD "%WINDIR%\System32" -allow-target-path-reassign -q cmd_system32.lnk
'''
''' NOTE:
'''   A difference in above examples between call to `make_shortcut.vbs` and
'''   call to `make_shortcut.vbs`+`reset_shortcut.vbs` has first found in the
'''   `Windows XP x64 Pro SP2` and `Windows XP x86 Pro SP3`.
'''   The single call in above example to `make_shortcut.vbs` instead of
'''   `make_shortcut.vbs`+`reset_shortcut.vbs` can generate a cleaner shortcut,
'''   but in other cases is vice versa.

''' Example to create MyComputer shortcut:
'''   >
'''   del /F /Q mycomputer.lnk
'''   make_shortcut.bat mycomputer.lnk
''' Or
'''   >
'''   del /F /Q mycomputer.lnk
'''   make_shortcut.bat mycomputer.lnk "shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"

''' Example to create MTP device folder shortcut:
'''   >
'''   del /F /Q mycomputer.lnk
'''   make_shortcut.bat mycomputer.lnk "shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\\\?\usb#vid_0e8d&pid_201d&mi_00#7&1084e14&0&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}"
'''
'''   , where the `\\?\usb#vid_0e8d&pid_201d&mi_00#7&1084e14&0&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}` might be different for each device
'''
'''   See details: https://stackoverflow.com/questions/39397348/open-folder-on-portable-device-with-batch-file/65997169#65997169

''' Example to create the Master Control Panel link or directory on the Desktop
'''   >
'''   make_shortcut.bat "%USERPROFILE%\Desktop\GodMode.lnk" "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}"
''' Or
'''   >
'''   mkdir "%USERPROFILE%\Desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
'''
''' Example to open the Master Control Panel from Taskbar pinned shortcut
'''   >
'''   explorer "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}"
'''
'''   See details: https://en.wikipedia.org/wiki/Windows_Master_Control_Panel_shortcut

''' CAUTION:
'''   The list of issues around a shortcut (.lnk) file:
'''
'''   PROS:
'''     * If you want to run a process elevated, then you can raise the
'''       `Run as Administrator` flag in the shortcut.
'''       You don't need a localized version of Administrator account name like
'''       for the runas executable.
'''
'''   CONS:
'''     * If create a shortcut to the Windows command interpreter (cmd.exe)
'''       with `Run as Administrator` flag raised, then you will run elevated
'''       only the cmd.exe process. To start any other process you have to
'''       either run it from the `cmd.exe` script, or create another standalone
'''       shortcut with the `Run as Administrator` flag raised.
'''     * Run from shortcut file (.lnk) in the Windows XP (but not in the
'''       Windows 7) brings truncated command line down to ~260 characters.
'''     * Run from shortcut file (.lnk) loads console windows parameters (font,
'''       windows size, buffer size, etc) from the shortcut at first and from
'''       the registry (HKCU\Console) at second. If try to change and save
'''       parameters, then it will be saved ONLY into the shortcut, which
'''       brings the shortcut file overwrite.

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

Sub GrowArr(arr, size)
  Dim reserve : reserve = UBound(arr) + 1
  If reserve < size Then
    Do
      If reserve <> 0 Then
        reserve = reserve * 2
      Else
        reserve = 16
      End If
    Loop While reserve < size
    ReDim Preserve arr(reserve - 1) ' upper bound instead of reserve size
  End If
End Sub

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim PrintAssign : PrintAssign = False

Dim BackupShortcut : BackupShortcut = True
Dim IgnoreUnexist : IgnoreUnexist = False

Dim CommandNameArr
Dim CommandArg0Arr
Dim CommandNameArrSize : CommandNameArrSize = 0

Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim ChangeCurrentDirectoryExist : ChangeCurrentDirectoryExist = False

Dim ShortcutFilePath : ShortcutFilePath = ""

Dim ShortcutTargetCache : ShortcutTargetCache = Null
Dim ShortcutTarget : ShortcutTarget = Null ' read and processed once
Dim IsShortcutTargetResetted : IsShortcutTargetResetted = False
Dim ShortcutTargetPrevResetted : ShortcutTargetPrevResetted = "*" ' initially must be not equal to the current value and not a path
Dim ShortcutTargetCurrResetted : ShortcutTargetCurrResetted = ""
Dim ShortcutTargetCurrExist : ShortcutTargetCurrExist = False ' not empty and exists
Dim ShortcutTargetCurrDirExist : ShortcutTargetCurrDirExist = False ' not empty and exists as a directory

Dim ShortcutWorkingCache : ShortcutWorkingCache = Null
Dim ShortcutWorkingDirectory : ShortcutWorkingDirectory = Null ' read and processed once
Dim IsShortcutWorkingDirectoryResetted : IsShortcutWorkingDirectoryResetted = False
Dim ShortcutWorkingDirectoryPrevResetted : ShortcutWorkingDirectoryPrevResetted = "*" ' initially must be not equal to the current value and not a path
Dim ShortcutWorkingDirectoryCurrResetted : ShortcutWorkingDirectoryCurrResetted = ""
Dim ShortcutWorkingDirectoryCurrExist : ShortcutWorkingDirectoryCurrExist = False ' not empty and exists

Dim ShortcutDescriptionCache : ShortcutDescriptionCache = Null
Dim ShortcutDescription : ShortcutDescription = Null ' read and processed once
Dim ShortcutDescriptionExist : ShortcutDescriptionExist = False ' not empty and exists

Dim AlwaysQuote : AlwaysQuote = False

Dim AllowTargetPathReassign : AllowTargetPathReassign = False
Dim AllowWorkingDirectoryReassign : AllowWorkingDirectoryReassign = False

Dim AllowDOSTargetPath : AllowDOSTargetPath = False
Dim AllowDOSWorkingDirectory : AllowDOSWorkingDirectory = False
Dim AllowDOSPaths : AllowDOSPaths = False

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
      ElseIf arg = "-ignore-unexist" Then
       IgnoreUnexist = True
      ElseIf arg = "-reset-target-drive-from-file-path" Then
        CommandNameArrSize = CommandNameArrSize + 1
        GrowArr CommandNameArr, CommandNameArrSize
        GrowArr CommandArg0Arr, CommandNameArrSize
        CommandNameArr(CommandNameArrSize - 1) = "reset-target-drive-from-file-path"
        CommandArg0Arr(CommandArg0ArrSize - 1) = Null
      ElseIf arg = "-reset-wd-drive-from-file-path" Then
        CommandNameArrSize = CommandNameArrSize + 1
        GrowArr CommandNameArr, CommandNameArrSize
        GrowArr CommandArg0Arr, CommandNameArrSize
        CommandNameArr(CommandNameArrSize - 1) = "reset-wd-drive-from-file-path"
        CommandArg0Arr(CommandArg0ArrSize - 1) = Null
      ElseIf arg = "-reset-target-path-from-desc" Then
        CommandNameArrSize = CommandNameArrSize + 1
        GrowArr CommandNameArr, CommandNameArrSize
        GrowArr CommandArg0Arr, CommandNameArrSize
        CommandNameArr(CommandNameArrSize - 1) = "reset-target-path-from-desc"
        CommandArg0Arr(CommandArg0ArrSize - 1) = Null
      ElseIf arg = "-reset-target-name-from-file-path" Then
        CommandNameArrSize = CommandNameArrSize + 1
        GrowArr CommandNameArr, CommandNameArrSize
        GrowArr CommandArg0Arr, CommandNameArrSize
        CommandNameArr(CommandNameArrSize - 1) = "reset-target-name-from-file-path"
        CommandArg0Arr(CommandArg0ArrSize - 1) = Null
      ElseIf arg = "-reset-wd-from-target-path" Or arg = "-reset-wd" Then
        CommandNameArrSize = CommandNameArrSize + 1
        GrowArr CommandNameArr, CommandNameArrSize
        GrowArr CommandArg0Arr, CommandNameArrSize
        CommandNameArr(CommandNameArrSize - 1) = "reset-wd-from-target-path"
        CommandArg0Arr(CommandArg0ArrSize - 1) = Null
      ElseIf arg = "-reset-target-path-from-wd" Then
        CommandNameArrSize = CommandNameArrSize + 1
        GrowArr CommandNameArr, CommandNameArrSize
        GrowArr CommandArg0Arr, CommandNameArrSize
        CommandNameArr(CommandNameArrSize - 1) = "reset-target-path-from-wd"
        CommandArg0Arr(CommandArg0ArrSize - 1) = Null
      ElseIf arg = "-reset-target-path-by-rebase-to" Then
        i = i + 1
        CommandNameArrSize = CommandNameArrSize + 1
        GrowArr CommandNameArr, CommandNameArrSize
        GrowArr CommandArg0Arr, CommandNameArrSize
        CommandNameArr(CommandNameArrSize - 1) = "reset-target-path-by-rebase"
        CommandArg0Arr(CommandArg0ArrSize - 1) = WScript.Arguments(i)
      ElseIf arg = "-allow-auto-recover" Then
        CommandNameArrSize = CommandNameArrSize + 1
        GrowArr CommandNameArr, CommandNameArrSize
        GrowArr CommandArg0Arr, CommandNameArrSize
        CommandNameArr(CommandNameArrSize - 1) = "allow-auto-recover"
        CommandArg0Arr(CommandArg0ArrSize - 1) = Null
      ElseIf arg = "-allow-auto-recover-by-rebase-to" Then
        i = i + 1
        CommandNameArrSize = CommandNameArrSize + 1
        GrowArr CommandNameArr, CommandNameArrSize
        GrowArr CommandArg0Arr, CommandNameArrSize
        CommandNameArr(CommandNameArrSize - 1) = "allow-auto-recover-by-rebase"
        CommandArg0Arr(CommandArg0ArrSize - 1) = WScript.Arguments(i)
      ElseIf arg = "-allow-target-path-reassign" Then ' Allow target path reassign
        AllowTargetPathReassign = True
      ElseIf arg = "-allow-wd-reassign" Then ' Allow working directory path reassign
        AllowWorkingDirectoryReassign = True
      ElseIf arg = "-allow-dos-target-path" Then ' Allow target path reset by a reduced DOS path version
        AllowDOSTargetPath = True
      ElseIf arg = "-allow-dos-wd" Then ' Allow working directory reset by a reduced DOS path version
        AllowDOSWorkingDirectory = True
      ElseIf arg = "-allow-dos-paths" Then ' Allow a property reset by a reduced DOS path version
        AllowDOSPaths = True
      ElseIf arg = "-print-assign" Or arg = "-p" Then ' Print assign
        PrintAssign = True
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

' upper bound instead of reserve size
ReDim Preserve cmd_args(j - 1)
ReDim Preserve CommandNameArr(CommandNameArrSize - 1)
ReDim Preserve CommandArg0Arr(CommandNameArrSize - 1)

' MsgBox Join(cmd_args, " ")

Dim cmd_args_ubound : cmd_args_ubound = UBound(cmd_args)

If cmd_args_ubound < 0 Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <ShortcutFilePath> argument is not defined."
  WScript.Quit 255
End If

If IgnoreUnexist And AllowAutoRecover Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: flags is mixed: -ignore-unexist <-> -allow-auto-recover"
  WScript.Quit 255
End If

' change current directory before any file system request because of relative paths
If ChangeCurrentDirectoryExist Then
  objShell.CurrentDirectory = ChangeCurrentDirectory
End If

ShortcutFilePath = cmd_args(0)

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

Dim ShortcutFilePathAbs : ShortcutFilePathAbs = objFS.GetAbsolutePathName(ShortcutFilePath)

' remove `\\?\` prefix
If Left(ShortcutFilePathAbs, 4) = "\\?\" Then
  ShortcutFilePathAbs = Mid(ShortcutFilePathAbs, 5)
End If

' test on path existence including long path
Dim IsShortcutFileExist : IsShortcutFileExist = objFS.FileExists("\\?\" & ShortcutFilePathAbs)
If Not IsShortcutFileExist Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: shortcut file does not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: ShortcutFilePathAbs=`" & ShortcutFilePathAbs & "`"
  WScript.Quit 1
End If

If AllowDOSPaths Then
  AllowDOSTargetPath = AllowDOSPaths
  AllowDOSWorkingDirectory = AllowDOSPaths
End If

' validate command arguments

Dim CommandName
Dim CommandArg0

Dim CommandNameArrUBound : CommandNameArrUBound = UBound(CommandNameArr)
For i = 0 To CommandNameArrUBound
  CommandName = CommandNameArr(i)
  CommandArg0 = CommandArg0Arr(i)

  If CommandName = "reset-target-path-by-rebase" Then
    Dim ResetTargetPathByRebaseToDir : ResetTargetPathByRebaseToDir = CommandArg0
    Dim ResetTargetPathByRebaseToDirExist : ResetTargetPathByRebaseToDirExist = False

    If Len(ResetTargetPathByRebaseToDir) > 0 Then
      ResetTargetPathByRebaseToDirExist = objFS.FolderExists(ResetTargetPathByRebaseToDir)
      ResetTargetPathByRebaseToDir = objFS.GetAbsolutePathName(ResetTargetPathByRebaseToDir)
    End If

    If Not ResetTargetPathByRebaseToDirExist Then
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": error: path option is not used, empty or not exist: `-reset-target-path-by-rebase-to <BasePath>`" & vbCrLf & _
        WScript.ScriptName & ": info: BasePath=`" & ResetTargetPathByRebaseToDir & "`"
      WScript.Quit 2
    End If

    CommandArg0Arr(i) = ResetTargetPathByRebaseToDir
  Else CommandName = "allow-auto-recover-by-rebase" Then
    Dim AllowAutoRecoverByRebaseToDir : AllowAutoRecoverByRebaseToDir = CommandArg0
    Dim AllowAutoRecoverByRebaseToDirExist : AllowAutoRecoverByRebaseToDirExist = False

    If Len(AllowAutoRecoverByRebaseToDir) > 0 Then
      AllowAutoRecoverByRebaseToDirExist = objFS.FolderExists(AllowAutoRecoverByRebaseToDir)
      AllowAutoRecoverByRebaseToDir = objFS.GetAbsolutePathName(AllowAutoRecoverByRebaseToDir)
    End If

    If Not AllowAutoRecoverByRebaseToDirExist Then
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": error: path option is not used, empty or not exist: `-allow-target-path-rebase-to <BasePath>`" & vbCrLf & _
        WScript.ScriptName & ": info: BasePath=`" & AllowAutoRecoverByRebaseToDir & "`"
      WScript.Quit 3
    End If

    CommandArg0Arr(i) = AllowAutoRecoverByRebaseToDir
  End If
Next

Function GetFilePathWithoutExt(path)
  ShortcutTargetExt = objFS.GetExtensionName(path)
  ShortcutTargetExtLen = Len(ShortcutTargetExt)
  If ShortcutTargetExtLen > 0 Then
    GetFilePathWithoutExt = Mid(path, 1, Len(path) - ShortcutTargetExtLen - 1)
  Else
    GetFilePathWithoutExt = path
  End If
End Function

Function GetFileNameWithoutExt(path)
  GetFileNameWithoutExt = objFS.GetFileName(GetFilePathWithoutExt(path))
End Function

Dim objSC : Set objSC = objShell.CreateShortcut(ShortcutFilePathAbs)

' read TargetPath

Sub ReadShortcutTargetPath()
  If IsNull(ShortcutTargetCache) Then
    ShortcutTargetCache = objSC.TargetPath
  End If
End Sub

Function GetTargetPath()
  Dim ShortcutTargetToUpdate

  If Not IsNull(ShortcutTarget) Then
    ShortcutTargetToUpdate = ShortcutTarget
  Else
    ReadShortcutTargetPath()

    ShortcutTargetToUpdate = ShortcutTargetCache

    If Len(ShortcutTargetToUpdate) > 1 And Left(ShortcutTargetToUpdate, 1) = Chr(34) And Right(ShortcutTargetToUpdate, 1) = Chr(34) Then
      ShortcutTargetToUpdate = Mid(ShortcutTargetToUpdate, 2, Len(ShortcutTargetToUpdate) - 2)
    End If
  End If

  GetTargetPath = ShortcutTargetToUpdate
End Function

Sub UpdateShortcutTarget()
''''''''''''
  If Not IsShortcutTargetResetted Then
    ShortcutTargetPrevResetted = ShortcutTargetCurrResetted
    ShortcutTargetCurrResetted = GetTargetPath()
  ElseIf Not ShortcutTargetCurrResetted = ShortcutTargetPrevResetted
    ShortcutTargetPrevResetted = ShortcutTargetCurrResetted
    ShortcutTargetCurrResetted = ShortcutTargetCurrResetted
    
  Else
    Exit Sub
  End If

  ShortcutTargetCurrDirExist = False
  ShortcutTargetCurrExist = False

  If Len(ShortcutTargetToUpdate) > 0 Then
    If objFS.FileExists(ShortcutTargetToUpdate) Then
      ShortcutTargetCurrExist = True
    ElseIf objFS.FolderExists(ShortcutTargetToUpdate) Then
      ShortcutTargetCurrDirExist = True
      ShortcutTargetCurrExist = True
    End If
  End If
End Sub

' read WorkingDirectory

Sub ReadShortcutWorkingDirectory()
  If IsNull(ShortcutWorkingDirectoryCache) Then
    ShortcutWorkingDirectoryCache = objSC.WorkingDirectory
  End If
End Sub

Function GetWorkingDirectory()
  Dim ShortcutWorkingDirectoryToUpdate

  If Not IsNull(ShortcutWorkingDirectory) Then
    ShortcutWorkingDirectoryToUpdate = ShortcutWorkingDirectory
  Else
    ReadShortcutWorkingDirectory()

    ShortcutWorkingDirectoryToUpdate = ShortcutWorkingDirectoryCache

    If Len(ShortcutWorkingDirectoryToUpdate) > 1 And Left(ShortcutWorkingDirectoryToUpdate, 1) = Chr(34) And Right(ShortcutWorkingDirectoryToUpdate, 1) = Chr(34) Then
      ShortcutWorkingDirectoryToUpdate = Mid(ShortcutWorkingDirectoryToUpdate, 2, Len(ShortcutWorkingDirectoryToUpdate) - 2)
    End If
  End If

  GetWorkingDirectory = ShortcutWorkingDirectoryToUpdate
End Function

Sub UpdateShortcutWorkingDirectory()
  Dim ShortcutWorkingDirectoryToUpdate

  If Not ShortcutWorkingDirectoryAssign Then
    ShortcutWorkingDirectoryToUpdate = GetWorkingDirectory()
  ElseIf Not ShortcutWorkingDirectoryCurrResetted = ShortcutWorkingDirectoryPrevResetted
    ShortcutWorkingDirectoryToUpdate = ShortcutWorkingDirectoryCurrResetted
    ShortcutWorkingDirectoryPrevResetted = ShortcutWorkingDirectoryCurrResetted
  Else
    Exit Sub
  End If

  ShortcutWorkingDirectoryCurrExist = False

  If Len(ShortcutWorkingDirectoryToUpdate) > 0 Then
    If objFS.FolderExists(ShortcutWorkingDirectoryToUpdate) Then
      ShortcutWorkingDirectoryCurrExist = True
    End If
  End If
End If

' read Description

Sub ReadShortcutDescription()
  If IsNull(ShortcutDescriptionCache) Then
    ShortcutDescriptionCache = objSC.Description
  End If
End Sub

Function GetDescription()
  Dim ShortcutDescriptionToUpdate

  If Not IsNull(ShortcutDescription) Then
    ShortcutDescriptionToUpdate = ShortcutDescription
  Else
    ReadShortcutDescription()

    ShortcutDescriptionToUpdate = ShortcutDescriptionCache

    If Len(ShortcutDescriptionToUpdate) > 1 And Left(ShortcutDescriptionToUpdate, 1) = Chr(34) And Right(ShortcutDescriptionToUpdate, 1) = Chr(34) Then
      ShortcutDescriptionToUpdate = Mid(ShortcutDescriptionToUpdate, 2, Len(ShortcutDescriptionToUpdate) - 2)
    End If
  End If

  GetDescription = ShortcutDescriptionToUpdate
End Function

Sub UpdateShortcutDescription()
  If IsNull(ShortcutDescription) Then
    ShortcutDescription = GetDescription()

    ShortcutDescriptionExist = False

    If Len(ShortcutDescription) > 0 Then
      If objFS.FileExists(ShortcutDescription) Then
        ShortcutDescriptionExist = True
      ElseIf objFS.FolderExists(ShortcutDescription) Then
        ShortcutDescriptionExist = True
      End If
    End If
  End If
End If

' 1

''''' in_call_chain ?
Function AssignWorkingDirFromTargetPath(arg0, if_dest_prev_path_not_exist, if_dest_not_equal_to_src, if_dest_next_path_exist, in_call_chain, skip_errors)
  If IsShortcutWorkingDirectoryResetted Then
    AssignWorkingDirFromTargetPath = False
    Exit Function
  End If

  UpdateShortcutWorkingDirectory()

  If if_dest_prev_path_not_exist Then
    If ShortcutWorkingDirectoryCurrExist Then
      AssignWorkingDirFromTargetPath = False
      Exit Function
    End If
  End If

  UpdateShortcutTarget()

  Dim ShortcutTargetToUpdatePrev
  Dim ShortcutWorkingDirectoryToUpdatePrev
  Dim ShortcutWorkingDirectoryToUpdateNext
  Dim ShortcutWorkingDirectoryToUpdateNextExist

  If Not IsShortcutTargetResetted Then
    ShortcutTargetToUpdatePrev = ShortcutTarget
  Else
    ShortcutTargetToUpdatePrev = ShortcutTargetCurrResetted
  End If

  If Not (Len(ShortcutTargetToUpdatePrev) > 0) Then
    If Not skip_errors Then
      PrintOrEchoErrorLine WScript.ScriptName & ": error: shortcut target path is empty."
      WScript.Quit 10
    Else
      AssignWorkingDirFromTargetPath = False
      Exit Function
    End If
  End If

  If Not IsShortcutWorkingDirectoryResetted Then
    ShortcutWorkingDirectoryToUpdatePrev = ShortcutWorkingDirectory
  Else
    ShortcutWorkingDirectoryToUpdatePrev = ShortcutWorkingDirectoryCurrResetted
  End If

  ' NOTE:
  '   Shortcut target must not be an existed DIRECTORY path, otherwise WorkingDirectory must be not empty, otherwise - ignore.
  '   Meaning:
  '     A directory shortcut basically does not use the WorkingDirectory property, but if does, then
  '     the WorkingDirectory property must be not empty to initiate a change.
  '     If a directory does not exist by the target path, then the target path is treated as a file path and
  '     the target parent directory is used for assignment.
  '
  If ShortcutTargetCurrDirExist And Not (Len(ShortcutWorkingDirectoryToUpdatePrev) > 0) Then
    If Not skip_errors Then
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": warning: WorkingDirectory reset is skipped because WorkingDirectory is empty and TargetPath is existed directory path:" & vbCrLf & _
        WScript.ScriptName & ": info: [TargetPath -> WorkingDirectory] TargetPath=`" & ShortcutTargetToUpdatePrev & "`"
    Else
      AssignWorkingDirFromTargetPath = False
      Exit Function
    End If
  End If

  If Not ShortcutTargetCurrDirExist Then
    ShortcutWorkingDirectoryToUpdateNext = objFS.GetParentFolderName(ShortcutTargetToUpdatePrev)
  Else
    ShortcutWorkingDirectoryToUpdateNext = ShortcutTargetToUpdatePrev ' use the whole path
    ShortcutWorkingDirectoryToUpdateNextExist = ShortcutTargetCurrExist
  End If

  If if_dest_not_equal_to_src And Len(ShortcutWorkingDirectoryToUpdatePrev) > 0 Then
    If objFS.GetAbsolutePathName(ShortcutWorkingDirectoryToUpdatePrev) = objFS.GetAbsolutePathName(ShortcutWorkingDirectoryToUpdateNext) Then
      AssignWorkingDirFromTargetPath = False
      Exit Function
    End If
  End If

  If if_dest_next_path_exist Or Not IgnoreUnexist Then
    If Not ShortcutTargetCurrDirExist Then
      ShortcutWorkingDirectoryToUpdateNextExist = objFS.FolderExists(ShortcutWorkingDirectoryToUpdateNext)
    End If

    If Not ShortcutWorkingDirectoryToUpdateNextExist Then
      If Not skip_errors Then
        PrintOrEchoErrorLine _
          WScript.ScriptName & ": error: shortcut working directory to assign does not exist:" & vbCrLf & _
          WScript.ScriptName & ": info: [TargetPath -> WorkingDirectory] WorkingDirectory=`" & ShortcutWorkingDirectoryToUpdateNext & "`"
        WScript.Quit 21
      Else
        AssignWorkingDirFromTargetPath = False
        Exit Function
      End If
    End If

    If Not ShortcutTargetCurrDirExist Then
      ShortcutWorkingDirectoryCurrExist = ShortcutWorkingDirectoryToUpdateNextExist

      ' update optimization, skip next time update
      ShortcutWorkingDirectoryPrevResetted = ShortcutWorkingDirectoryToUpdateNext
    End If
  End If

  If ShortcutTargetCurrDirExist Then
    ShortcutWorkingDirectoryCurrExist = ShortcutWorkingDirectoryToUpdateNextExist

    ' update optimization, skip next time update
    ShortcutWorkingDirectoryPrevResetted = ShortcutWorkingDirectoryToUpdateNext
  End If

  ShortcutWorkingDirectoryCurrResetted = ShortcutWorkingDirectoryToUpdateNext
  IsShortcutWorkingDirectoryResetted = True

  AssignWorkingDirFromTargetPath = True
End Function

' 2

Function AssignTargetPathFromWorkingDir(arg0, if_dest_prev_path_not_exist, if_dest_not_equal_to_src, if_dest_next_path_exist, skip_errors)
  If IsShortcutTargetResetted Then
    AssignTargetPathFromWorkingDir = False
    Exit Function
  End If

  UpdateShortcutTarget()

  If if_dest_prev_path_not_exist Then
    If ShortcutTargetCurrExist Then
      AssignTargetPathFromWorkingDir = False
      Exit Function
    End If
  End If

  Dim ShortcutTargetToUpdatePrev
  Dim ShortcutTargetToUpdateNext
  Dim ShortcutTargetToUpdateNextExist
  Dim ShortcutTargetToUpdateNextDirExist
  Dim ShortcutWorkingDirectoryToUpdatePrev

  If Not IsShortcutTargetResetted Then
    ShortcutTargetToUpdatePrev = ShortcutTarget
  Else
    ShortcutTargetToUpdatePrev = ShortcutTargetCurrResetted
  End If

  If Not (Len(ShortcutTargetToUpdatePrev) > 0) Then
    'If Not skip_errors Then
    '  PrintOrEchoErrorLine WScript.ScriptName & ": error: shortcut target path is empty."
    '  WScript.Quit 10
    'Else
      AssignTargetPathFromWorkingDir = False
      Exit Function
    End If
  End If

  UpdateShortcutWorkingDirectory()

  If Not IsShortcutWorkingDirectoryResetted Then
    ShortcutWorkingDirectoryToUpdatePrev = ShortcutWorkingDirectory
  Else
    ShortcutWorkingDirectoryToUpdatePrev = ShortcutWorkingDirectoryCurrResetted
  End If

  If Not (Len(ShortcutWorkingDirectoryToUpdatePrev) > 0) Then
    If Not skip_errors Then
      PrintOrEchoErrorLine WScript.ScriptName & ": error: shortcut working directory path is empty."
      WScript.Quit 11
    Else
      AssignTargetPathFromWorkingDir = False
      Exit Function
    End If
  End If

  ShortcutTargetToUpdateNext = ShortcutWorkingDirectoryToUpdatePrev & "\" & objFS.GetFileName(ShortcutTargetToUpdatePrev)

  If if_dest_not_equal_to_src Then
    If objFS.GetAbsolutePathName(ShortcutWorkingDirectoryToUpdatePrev) = objFS.GetAbsolutePathName(ShortcutTargetToUpdateNext) Then
      AssignTargetPathFromWorkingDir = False
      Exit Function
    End If
  End If

  If if_dest_next_path_exist Or Not IgnoreUnexist Then
    ShortcutTargetToUpdateNextDirExist = False
    ShortcutTargetToUpdateNextExist = False

    If objFS.FileExists(ShortcutTargetToUpdateNext) Then
      ShortcutTargetToUpdateNextExist = True
    ElseIf objFS.FolderExists(ShortcutTargetToUpdateNext) Then
      ShortcutTargetToUpdateNextDirExist = True
      ShortcutTargetToUpdateNextExist = True
    End If

    If Not ShortcutTargetToUpdateNextExist Then
      If Not skip_errors Then
        PrintOrEchoErrorLine _
          WScript.ScriptName & ": error: shortcut target path to assign does not exist:" & vbCrLf & _
          WScript.ScriptName & ": info: [WorkingDirectory -> TargetPath] TargetPath=`" & ShortcutTargetToUpdateNext & "`"
        WScript.Quit 20
      Else
        AssignTargetPathFromWorkingDir = False
        Exit Function
      End If
    End If

    ShortcutTargetCurrExist = ShortcutTargetToUpdateNextExist
    ShortcutTargetCurrDirExist = ShortcutTargetToUpdateNextDirExist

    ' update optimization, skip next time update
    ShortcutTargetPrevResetted = ShortcutTargetToUpdateNext
  End If

  ShortcutTargetCurrResetted = ShortcutTargetToUpdateNext
  IsShortcutTargetResetted = True

  AssignTargetPathFromWorkingDir = True
End Function

' 3

Function AssignTargetPathFromDescription(arg0, if_dest_prev_path_not_exist, if_dest_not_equal_to_src, if_dest_next_path_exist, skip_errors)
  If IsShortcutTargetResetted Then
    AssignTargetPathFromDescription = False
    Exit Function
  End If

  UpdateShortcutTarget()

  If if_dest_prev_path_not_exist Then
    If ShortcutTargetCurrExist Then
      AssignTargetPathFromDescription = False
      Exit Function
    End If
  End If

  Dim ShortcutTargetToUpdatePrev
  Dim ShortcutTargetToUpdateNext
  Dim ShortcutTargetToUpdateNextExist
  Dim ShortcutTargetToUpdateNextDirExist
  Dim ShortcutDescriptionToUpdatePrev

  If Not IsShortcutTargetResetted Then
    ShortcutTargetToUpdatePrev = ShortcutTarget
  Else
    ShortcutTargetToUpdatePrev = ShortcutTargetCurrResetted
  End If

  If Not (Len(ShortcutTargetToUpdatePrev) > 0) Then
    If Not skip_errors Then
      PrintOrEchoErrorLine WScript.ScriptName & ": error: shortcut target path is empty."
      WScript.Quit 10
    Else
      AssignTargetPathFromDescription = False
      Exit Function
    End If
  End If

  UpdateShortcutDescription()

  If Not ShortcutDescriptionAssigned Then
    ShortcutDescriptionToUpdatePrev = ShortcutDescription
  Else
    ShortcutDescriptionToUpdatePrev = ShortcutDescriptionToAssignNext
  End If

  If Not (Len(ShortcutDescriptionToUpdatePrev) > 0) Then
    If Not skip_errors Then
      PrintOrEchoErrorLine WScript.ScriptName & ": error: shortcut description as path is empty."
      WScript.Quit 12
    Else
      AssignTargetPathFromDescription = False
      Exit Function
    End If
  End If

  ShortcutTargetToUpdateNext = ShortcutDescriptionToUpdatePrev

  If if_dest_not_equal_to_src Then
    If objFS.GetAbsolutePathName(ShortcutDescriptionToUpdatePrev) = objFS.GetAbsolutePathName(ShortcutTargetToUpdateNext) Then
      AssignTargetPathFromDescription = False
      Exit Function
    End If
  End If

  If if_dest_next_path_exist Or Not IgnoreUnexist Then
    ShortcutTargetToUpdateNextDirExist = False
    ShortcutTargetToUpdateNextExist = False

    If objFS.FileExists(ShortcutTargetToUpdateNext) Then
      ShortcutTargetToUpdateNextExist = True
    ElseIf objFS.FolderExists(ShortcutTargetToUpdateNext) Then
      ShortcutTargetToUpdateNextDirExist = True
      ShortcutTargetToUpdateNextExist = True
    End If

    If Not ShortcutTargetToUpdateNextExist Then
      If Not skip_errors Then
        PrintOrEchoErrorLine _
          WScript.ScriptName & ": error: shortcut target path to assign does not exist:" & vbCrLf & _
          WScript.ScriptName & ": info: [Description -> TargetPath] TargetPath=`" & ShortcutTargetToUpdateNext & "`"
        WScript.Quit 20
      Else
        AssignTargetPathFromDescription = False
        Exit Function
      End If
    End If

    ShortcutTargetCurrExist = ShortcutTargetToUpdateNextExist
    ShortcutTargetCurrDirExist = ShortcutTargetToUpdateNextDirExist

    ' update optimization, skip next time update
    ShortcutTargetPrevResetted = ShortcutTargetToUpdateNext
  End If

  ShortcutTargetCurrResetted = ShortcutTargetToUpdateNext
  IsShortcutTargetResetted = True

  AssignTargetPathFromDescription = True
End Function

' 4

Function AssignTargetNameFromFilePath(arg0, if_dest_prev_path_not_exist, if_dest_not_equal_to_src, if_dest_next_path_exist, skip_errors)
  If IsShortcutTargetResetted Then
    AssignTargetNameFromFilePath = False
    Exit Function
  End If

  UpdateShortcutTarget()

  If if_dest_prev_path_not_exist Then
    If ShortcutTargetCurrExist Then
      AssignTargetNameFromFilePath = False
      Exit Function
    End If
  End If

  Dim ShortcutTargetToUpdatePrev
  Dim ShortcutTargetToUpdateNext
  Dim ShortcutTargetToUpdateNextExist
  Dim ShortcutTargetToUpdateNextDirExist

  If Not IsShortcutTargetResetted Then
    ShortcutTargetToUpdatePrev = ShortcutTarget
  Else
    ShortcutTargetToUpdatePrev = ShortcutTargetCurrResetted
  End If

  If Not (Len(ShortcutTargetToUpdatePrev) > 0) Then
    If Not skip_errors Then
      PrintOrEchoErrorLine WScript.ScriptName & ": error: shortcut target path is empty."
      WScript.Quit 10
    Else
      AssignTargetNameFromFilePath = False
      Exit Function
    End If
  End If

  ShortcutTargetToUpdateNext = GetFilePathWithoutExt(objFS.GetParentFolderName(ShortcutTargetToUpdatePrev) & "\" & objFS.GetFileName(ShortcutFilePath))

  If if_dest_not_equal_to_src Then
    If objFS.GetAbsolutePathName(ShortcutTargetToUpdatePrev) = objFS.GetAbsolutePathName(ShortcutTargetToUpdateNext) Then
      AssignTargetNameFromFilePath = False
      Exit Function
    End If
  End If

  If if_dest_next_path_exist Or Not IgnoreUnexist Then
    ShortcutTargetToUpdateNextDirExist = False
    ShortcutTargetToUpdateNextExist = False

    If objFS.FileExists(ShortcutTargetToUpdateNext) Then
      ShortcutTargetToUpdateNextExist = True
    ElseIf objFS.FolderExists(ShortcutTargetToUpdateNext) Then
      ShortcutTargetToUpdateNextDirExist = True
      ShortcutTargetToUpdateNextExist = True
    End If

    If Not ShortcutTargetToUpdateNextExist Then
      If Not skip_errors Then
        PrintOrEchoErrorLines _
          WScript.ScriptName & ": error: shortcut target path to assign does not exist:" & vbCrLf & _
          WScript.ScriptName & ": info: [<ShortcutFileName> -> TargetPath] TargetPath=`" & ShortcutTargetToUpdateNext & "`"
        WScript.Quit 20
      Else
        AssignTargetNameFromFilePath = False
        Exit Function
      End If
    End If

    ShortcutTargetCurrExist = ShortcutTargetToUpdateNextExist
    ShortcutTargetCurrDirExist = ShortcutTargetToUpdateNextDirExist

    ' update optimization, skip next time update
    ShortcutTargetPrevResetted = ShortcutTargetToUpdateNext
  End If

  ShortcutTargetCurrResetted = ShortcutTargetToUpdateNext
  IsShortcutTargetResetted = True

  AssignTargetNameFromFilePath = True
End Function

' 5

Function AssignTargetDriveFromFilePath(arg0, if_dest_prev_path_not_exist, if_dest_not_equal_to_src, if_dest_next_path_exist, skip_errors)
  If IsShortcutTargetResetted Then
    AssignTargetNameFromFilePath = False
    Exit Function
  End If

  UpdateShortcutTarget()

  If if_dest_prev_path_not_exist Then
    If ShortcutTargetCurrExist Then
      AssignTargetNameFromFilePath = False
      Exit Function
    End If
  End If

  Dim ShortcutTargetToUpdatePrev
  Dim ShortcutTargetToUpdateNext
  Dim ShortcutTargetToUpdateNextExist
  Dim ShortcutTargetToUpdateNextDirExist

  If Not IsShortcutTargetResetted Then
    ShortcutTargetToUpdatePrev = ShortcutTarget
  Else
    ShortcutTargetToUpdatePrev = ShortcutTargetCurrResetted
  End If

  If Not (Len(ShortcutTargetToUpdatePrev) > 0) Then
    If Not skip_errors Then
      PrintOrEchoErrorLine WScript.ScriptName & ": error: shortcut target path is empty."
      WScript.Quit 10
    Else
      AssignTargetNameFromFilePath = False
      Exit Function
    End If
  End If

  ShortcutTargetToUpdateNext = GetFilePathWithoutExt(objFS.GetParentFolderName(ShortcutTargetToUpdatePrev) & "\" & objFS.GetFileName(ShortcutFilePath))

  If if_dest_not_equal_to_src Then
    If objFS.GetAbsolutePathName(ShortcutTargetToUpdatePrev) = objFS.GetAbsolutePathName(ShortcutTargetToUpdateNext) Then
      AssignTargetNameFromFilePath = False
      Exit Function
    End If
  End If

  If if_dest_next_path_exist Or Not IgnoreUnexist Then
    ShortcutTargetToUpdateNextDirExist = False
    ShortcutTargetToUpdateNextExist = False

    If objFS.FileExists(ShortcutTargetToUpdateNext) Then
      ShortcutTargetToUpdateNextExist = True
    ElseIf objFS.FolderExists(ShortcutTargetToUpdateNext) Then
      ShortcutTargetToUpdateNextDirExist = True
      ShortcutTargetToUpdateNextExist = True
    End If

    If Not ShortcutTargetToUpdateNextExist Then
      If Not skip_errors Then
        PrintOrEchoErrorLine _
          WScript.ScriptName & ": error: shortcut target path to assign does not exist:" & vbCrLf & _
          WScript.ScriptName & ": info: [<Drive> -> TargetPath] TargetPath=`" & ShortcutTargetToUpdateNext & "`"
        WScript.Quit 20
      Else
        AssignTargetNameFromFilePath = False
        Exit Function
      End If
    End If

    ShortcutTargetCurrExist = ShortcutTargetToUpdateNextExist
    ShortcutTargetCurrDirExist = ShortcutTargetToUpdateNextDirExist

    ' update optimization, skip next time update
    ShortcutTargetPrevResetted = ShortcutTargetToUpdateNext
  End If

  ShortcutTargetCurrResetted = ShortcutTargetToUpdateNext
  IsShortcutTargetResetted = True

  AssignTargetDriveFromFilePath = True
End Funtion

'''''''
  If Mid(ShortcutTargetToAssign, 2, 1) = ":" Then
    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetToAssign, 4)
    IsShortcutTargetResetted = True
  End If
End If

If AllowAutoRecover Then
  ' 1+5
  If (Not IsShortcutWorkingDirectoryResetted) And (Not ShortcutTargetEmpty) And Mid(ShortcutTarget, 2, 1) = ":" Then
    If (Not ShortcutTargetDirExist) Or (Not ShortcutWorkingDirectoryEmpty) Then
      If Not ShortcutTargetDirExist Then
        ShortcutWorkingDirectoryToAssign = objFS.GetParentFolderName(ShortcutTarget)
      Else
        ShortcutWorkingDirectoryToAssign = ShortcutTarget ' use the whole path
      End If

      ShortcutWorkingDirectoryToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutWorkingDirectoryToAssign, 4)

      Dim ShortcutWorkingDirectoryToAssignExist = objFS.FolderExists(ShortcutWorkingDirectoryToAssign)

      If ShortcutWorkingDirectoryToAssignExist Then
        IsShortcutWorkingDirectoryResetted = True
      End If
    End If
  End If

  ' 2+4

  If (Not IsShortcutTargetResetted) And (Not ShortcutTargetEmpty) And (Not ShortcutWorkingDirectoryEmpty) Then
    ShortcutTargetToAssign = ShortcutWorkingDirectory & "\" & objFS.GetFileName(ShortcutTarget)

    ShortcutTargetToAssign = objFS.GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)

    ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
    ShortcutTargetExtLen = Len(ShortcutTargetExt)
    If ShortcutTargetExtLen > 0 Then
      ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
    End If

    Dim ShortcutTargetToAssignExist : ShortcutTargetToAssignExist = False

    If objFS.FileExists(ShortcutTargetToAssign) Or objFS.FolderExists(ShortcutTargetToAssign) Then
      ShortcutTargetToAssignExist = True
    End If

    If ShortcutTargetToAssignExist Then
      IsShortcutTargetResetted = True
    End If
  End If

  ' 2+5

  If (Not IsShortcutTargetResetted) And (Not ShortcutTargetEmpty) And (Not ShortcutWorkingDirectoryEmpty) And Mid(ShortcutWorkingDirectory, 2, 1) = ":" Then
    ShortcutTargetToAssign = ShortcutWorkingDirectory & "\" & objFS.GetFileName(ShortcutTarget)

    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetToAssign, 4)

    Dim ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      IsShortcutTargetResetted = True
    End If
  End If

  ' 3+4

  If (Not IsShortcutTargetResetted) And (Not ShortcutTargetEmpty) And Len(ShortcutDesc) > 0 And ShortcutDescExist Then
    ShortcutTargetToAssign = ShortcutDesc

    ShortcutTargetToAssign = objFS.GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)

    ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
    ShortcutTargetExtLen = Len(ShortcutTargetExt)
    If ShortcutTargetExtLen > 0 Then
      ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
    End If

    Dim ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      IsShortcutTargetResetted = True
    End If
  End If
 
  ' 3+5

  If (Not IsShortcutTargetResetted) And (Not ShortcutTargetEmpty) And Len(ShortcutDesc) > 0 And ShortcutDescExist And Mid(ShortcutDesc, 2, 1) = ":" Then
    ShortcutTargetToAssign = ShortcutDesc

    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetToAssign, 4)

    Dim ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      IsShortcutTargetResetted = True
    End If
  End If

  ' 2+4+5

  If (Not IsShortcutTargetResetted) And (Not ShortcutTargetEmpty) And (Not ShortcutWorkingDirectoryEmpty) And Mid(ShortcutWorkingDirectory, 2, 1) = ":" Then
    ShortcutTargetToAssign = ShortcutWorkingDirectory & "\" & objFS.GetFileName(ShortcutTarget)

    ShortcutTargetToAssign = objFS.GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)

    ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
    ShortcutTargetExtLen = Len(ShortcutTargetExt)
    If ShortcutTargetExtLen > 0 Then
      ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
    End If
    
    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetToAssign, 4)

    Dim ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      IsShortcutTargetResetted = True
    End If
  End If

  ' 3+4+5

  If (Not IsShortcutTargetResetted) And (Not ShortcutTargetEmpty) And Len(ShortcutDesc) > 0 And ShortcutDescExist And Mid(ShortcutDesc, 2, 1) = ":" Then
    ShortcutTargetToAssign = ShortcutDesc

    ShortcutTargetToAssign = objFS.GetParentFolderName(ShortcutTargetToAssign) & "\" & objFS.GetFileName(ShortcutFilePath)

    ShortcutTargetExt = objFS.GetExtensionName(ShortcutTargetToAssign)
    ShortcutTargetExtLen = Len(ShortcutTargetExt)
    If ShortcutTargetExtLen > 0 Then
      ShortcutTargetToAssign = Mid(ShortcutTargetToAssign, 1, Len(ShortcutTargetToAssign) - ShortcutTargetExtLen - 1)
    End If
  
    ShortcutTargetToAssign = objFS.GetDriveName(objFS.GetAbsolutePathName(ShortcutFilePath)) & "\" & Mid(ShortcutTargetToAssign, 4)

    Dim ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

    If ShortcutTargetToAssignExist Then
      IsShortcutTargetResetted = True
    End If
  End If
End If

' 7

Dim ShortcutTargetPathArr
Dim ShortcutTargetPathArrUbound
Dim RebasedTargetPathToAssign
Dim TargetPathRebased

If ResetTargetPathByRebase Then
  TargetPathRebased = False
  If Not IsShortcutTargetResetted Then
    ShortcutTargetToAssign = ShortcutTarget
  End If
  If Mid(ShortcutTargetToAssign, 2, 1) = ":" Then
    ShortcutTargetPathArr = Split(Mid(ShortcutTargetToAssign, 4), "\", -1, vbTextCompare)
  End If
  ShortcutTargetPathArrUbound = UBound(ShortcutTargetPathArr)
  If ShortcutTargetPathArrUbound >= 0 Then
    For i = 0 To ShortcutTargetPathArrUbound
      RebasedTargetPathToAssign = ResetTargetPathByRebaseToDir
      For j = i To ShortcutTargetPathArrUbound
        RebasedTargetPathToAssign = RebasedTargetPathToAssign & "\" & ShortcutTargetPathArr(j)
      Next
      If objFS.FileExists(RebasedTargetPathToAssign) <> 0 Or objFS.FolderExists(RebasedTargetPathToAssign) <> 0 Then
        ShortcutTargetToAssign = RebasedTargetPathToAssign
        IsShortcutTargetResetted = True
        TargetPathRebased = True
        Exit For
      End If
    Next
  End If

  ''''''''''''
  If TargetPathRebased Then
    ResetWorkingDirFromTargetPath(True)
  End If
End If

If AllowAutoRecoverByRebase Then
  ' 7+4
End If

' Commands loop

For i = 0 To CommandNameArrUBound
  CommandName = CommandNameArr(i)
  CommandArg0 = CommandArg0Arr(i)

  If CommandName = "reset-wd-from-target-path" Then
    ResetWorkingDirFromTargetPath(CommandArg0, False)
  Else CommandName = "allow-auto-recover-by-rebase-to" Then
    AllowAutoRecoverByRebaseToDir(CommandArg0, True)
  End If
Next

Dim ResetTargetPathFromWorkingDir : ResetTargetPathFromWorkingDir = False
Dim ResetTargetPathFromDesc : ResetTargetPathFromDesc = False
Dim ResetTargetNameFromFilePath : ResetTargetNameFromFilePath = False
Dim ResetTargetDriveFromFilePath : ResetTargetDriveFromFilePath = False
Dim ResetTargetPathByRebase : ResetTargetPathByRebase = False
Dim ResetTargetPathByRebaseToDir : ResetTargetPathByRebaseToDir = ""

Dim AllowAutoRecover : AllowAutoRecover = False
Dim AllowAutoRecoverByRebase : AllowAutoRecoverByRebase = False

Dim ShortcutTargetAssigned : ShortcutTargetAssigned = False

If IsShortcutTargetResetted Then
  If PrintAssign Then
    PrintOrEchoLine "TargetPath=" & ShortcutTargetToAssign
  End If

  If AlwaysQuote Then
    ShortcutTargetToAssign = Chr(34) & ShortcutTargetToAssign & Chr(34)
  End If

  objSC.TargetPath = ShortcutTargetToAssign
  ShortcutTargetAssigned = True
ElseIf AllowTargetPathReassign Then
  UpdateShortcutTarget()

  If ShortcutTargetCurrExist Or IgnoreUnexist Then
    If PrintAssign Then
      PrintOrEchoLine "TargetPath=" & ShortcutTargetCache
    End If

    objSC.TargetPath = ShortcutTargetCache ' reassign
    ShortcutTargetAssigned = True
  End If
End If

If ShortcutTargetAssigned And AllowDOSTargetPath Then
  Dim ShortcutTargetAbs : ShortcutTargetAbs = objFS.GetAbsolutePathName(ShortcutTarget)

  If Not LCase(objSC.TargetPath) = LCase(ShortcutTargetAbs) Then
    ' WORKAROUND:
    '   We use `\\?\` to bypass `GetFile` error: `File not found`.
    Dim ShortcutTargetFile : Set ShortcutTargetFile = objFS.GetFile("\\?\" & ShortcutTargetAbs)
    Dim ShortcutTargetShortPath : ShortcutTargetShortPath = ShortcutTargetFile.ShortPath
    If Left(ShortcutTargetShortPath, 4) = "\\?\" Then
      ShortcutTargetShortPath = Mid(ShortcutTargetShortPath, 5)
    End If

    objSC.TargetPath = ShortcutTargetShortPath
  End If
End If

If IsShortcutWorkingDirectoryResetted Then
  If PrintAssign Then
    PrintOrEchoLine "WorkingDirectory=" & ShortcutWorkingDirectoryToAssign
  End If

  objSC.WorkingDirectory = ShortcutWorkingDirectoryToAssign
ElseIf AllowWorkingDirectoryReassign Then
  If WorkingDirectoryToUpdateExist Or IgnoreUnexist Then
    If PrintAssign Then
      PrintOrEchoLine "WorkingDirectory=" & ShortcutWorkingDirectory
    End If

    objSC.WorkingDirectory = ShortcutWorkingDirectory ' reassign
  End If
End If

If BackupShortcut Then
  Dim NowDateTime : NowDateTime = Now ' copy
  Dim t : t = Timer ' copy for milliseconds resolution

  Dim YYYY : YYYY = DatePart("yyyy", NowDateTime)
  Dim MM : MM = Right("0" & DatePart("m", NowDateTime), 2)
  Dim DD : DD = Right("0" & DatePart("d", NowDateTime), 2)

  Dim BackupDateName : BackupDateName = YYYY & "'" & MM & "'" & DD

  Dim HH : HH = Right("0" & DatePart("h", NowDateTime), 2)
  Dim mm_ : mm_ = Right("0" & DatePart("n", NowDateTime), 2)
  Dim ss : ss = Right("0" & DatePart("s", NowDateTime), 2)
  Dim ms : ms = Right("0" & Int((t - Int(t)) * 1000), 3)

  Dim BackupTimeName : BackupTimeName = HH & "'" & mm_ & "'" & ss & "''" & ms

  Dim ShortcutFileDir : ShortcutFileDir = objFS.GetParentFolderName(ShortcutFilePathToOpen)

  ' YYYY'MM'DD.backup
  Dim ShortcutFileBackupDir : ShortcutFileBackupDir = ShortcutFileDir & "\" & BackupDateName & ".backup"

  If Not objFS.FolderExists(ShortcutFileBackupDir) Then
    objFS.CreateFolder ShortcutFileBackupDir

    If (err <> 0) And err <> &h800A003A& Then ' File aready exists
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
    '   The `*Exists` methods will return False on a long path without `\\?\`
    '   prefix.
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
    End IF

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
    If Not objFS.FolderExists("\\?\" & to_file_parent_dir_path_abs & "\") Then
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": error: output parent directory path does not exist:" & vbCrLf & _
        WScript.ScriptName & ": info: OutputPath=`" & to_file_path_abs & "`"
      WScript.Quit 2
    End IF

    ' test on long path existence
    If Not objFS.FileExists(from_file_path_abs) Then
      ' translate into short path

      ' WORKAROUND:
      '   We use `\\?\` to bypass `GetFile` error: `File not found`.
      Dim from_file_obj : Set from_file_obj = objFS.GetFile("\\?\" & from_file_path_abs)
      from_file_path_abs = from_file_obj.ShortPath
      If Left(from_file_path_abs, 4) = "\\?\" Then
        from_file_path_abs = Mid(from_file_path_abs, 5)
      End If
    End If

    ' test on long path existence
    If Not objFS.FolderExists(to_file_parent_dir_path_abs & "\") Then
      ' translate into short path

      ' WORKAROUND:
      '   We use `\\?\` to bypass `GetFolder` error: `Path not found`.
      Dim to_file_parent_dir_obj : Set to_file_parent_dir_obj = objFS.GetFolder("\\?\" & to_file_parent_dir_path_abs & "\")
      to_file_parent_dir_path_abs = to_file_parent_dir_obj.ShortPath
      If Left(to_file_parent_dir_path_abs, 4) = "\\?\" Then
        to_file_parent_dir_path_abs = Mid(to_file_parent_dir_path_abs, 5)
      End If
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
