''' Updates existing Windows shortcut file.

''' CAUTION:
'''   WScript.Shell can not handle all Unicode characters in path properties, including characters in the path to a shortcut file.
'''   Details: https://stackoverflow.com/questions/39365489/how-do-you-keep-diacritics-in-shortcut-paths
'''

''' USAGE:
'''   update_shortcut.vbs
'''     [-CD <CurrentDirectoryPath>]
'''     [-showas <ShowWindowAsNumber>]
'''     [-no-backup] [-ignore-unexist]
'''     [-allow-target-path-reassign] [-allow-wd-reassign]
'''     [-allow-dos-current-dir] [-allow-dos-target-path] [-allow-dos-wd] [-allow-dos-paths]
'''     [-p[rint-assing]]
'''     [-u] [-q]
'''     [-E[0 | t | a | wd]]
'''     [-t <ShortcutTarget>]
'''     [-t-suffix <ShortcutTargetSuffix>]
'''     [-args <ShortcutTargetArgs>]
'''     [-wd <ShortcutWorkingDirectory>]
'''     [--]
'''     <ShortcutFilePath>

''' DESCRIPTION:
'''   Script to update a shortcut with a property value.
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
'''   -showas <ShowWindowAsNumber>
''''     Handles a child process window show state.
'''
'''      CreateProcess or ShellExecute
'''        0 = SW_HIDE
'''          Don't show window.
'''        1 = SW_SHOWNORMAL
'''          Activates and displays a window. If the window is minimized or
'''          maximized, the system restores it to its original size and
'''          position. An application should specify this flag when displaying
'''          the window for the first time.
'''        2 = SW_SHOWMINIMIZED
'''          Activates the window and displays it as a minimized window.
'''        3 = SW_SHOWMAXIMIZED
'''          Activates the window and displays it as a maximized window.
'''        4 = SW_SHOWNOACTIVATE
'''          Displays a window in its most recent size and position. This value
'''          is similar to SW_SHOWNORMAL, except that the window is not
'''          activated.
'''        5 = SW_SHOW
'''          Activates the window and displays it in its current size and
'''          position.
'''        6 = SW_MINIMIZE
'''          Minimizes the specified window and activates the next top-level
'''          window in the Z order.
'''        7 = SW_SHOWMINNOACTIVE
'''          Displays the window as a minimized window. This value is similar
'''          to SW_SHOWMINIMIZED, except the window is not activated.
'''        8 = SW_SHOWNA
'''          Displays the window in its current size and position. This value
'''          is similar to SW_SHOW, except that the window is not activated.
'''        9 = SW_RESTORE
'''          Activates and displays the window. If the window is minimized or
'''          maximized, the system restores it to its original size and
'''          position. An application should specify this flag when restoring
'''          a minimized window.
'''        11 = SW_FORCEMINIMIZE
'''          Minimizes a window, even if the thread that owns the window is not
'''          responding. This flag should only be used when minimizing windows
'''          from a different thread.
'''
'''      The flags that specify how an application is to be displayed when it
'''      is opened. If the first argument of <CommandLine> specifies a document
'''      file, the flag is simply passed to the associated application. It is
'''      up to the application to decide how to handle it.
'''
'''      See detailed documentation in MSDN for the function `ShowWindow`.
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
'''   -allow-target-path-reassign
'''     Allow TargetPath reassign if path is case insensitively equal.
'''     Has no effect if path does not exist and `-ignore-unexist` is not used.
'''   -allow-wd-reassign
'''     Allow WorkingDirectory reassign if path is case insensitively equal.
'''     Has no effect if path does not exist and `-ignore-unexist` is not used.
'''
'''   -allow-dos-current-dir
'''     Allow long path conversion into DOS path for the current directory.
'''     Has effect only if path does exist.
'''   -allow-dos-target-path
'''     Reread target path after assign and if it does not exist, then reassign
'''     it by a reduced DOS path version.
'''     It is useful when you want to create not truncated shortcut target file
'''     path to open it by an old version application which does not support
'''     long paths or Win32 Namespace paths, but supports open target paths by
'''     a shortcut file.
'''     Has effect only if path does exist.
'''   -allow-dos-wd
'''     Reread working directory after assign and if it does not exist, then
'''     reassign it by a reduced DOS path version.
'''     Has effect only if path does exist.
'''   -allow-dos-paths
'''     Implies all `-allow-dos-*` flags.
'''
'''   -p[rint-assign]
'''     Print assign.
'''   -u
'''     Unescape %xx or %uxxxx sequences.
'''   -q
'''     Always quote target path argument if has no quote characters.
'''   -E
'''     Expand environment variables in all shortcut arguments.
'''   -E0
'''     Expand environment variables only in the first argument.
'''   -Et
'''     Expand environment variables only in the shortcut target path argument.
'''   -Ea
'''     Expand environment variables only in the shortcut target object
'''     arguments.
'''   -Ewd
'''     Expand environment variables only in the shortcut working directory
'''     argument.
'''
'''   -t <ShortcutTarget>
'''     Shortcut target value to assign.
'''   -t-suffix <ShortcutTargetSuffix>
'''     Shortcut target suffix value to append if <ShortcutTarget> does not
'''     exist. Has no effect if `-ignore-unexist` is used.
'''   -args <ShortcutTargetArgs>
'''     Shortcut arguments value to assign.
'''   -wd <ShortcutWorkingDirectory>
'''     Working directory value to assign.

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

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim PrintAssign : PrintAssign = False

Dim BackupShortcut : BackupShortcut = True

Dim IgnoreUnexist : IgnoreUnexist = False

Dim UnescapeAllArgs : UnescapeAllArgs = False

Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim ChangeCurrentDirectoryExist : ChangeCurrentDirectoryExist = False

Dim ShortcutTarget : ShortcutTarget = ""
Dim ShortcutTargetUnquoted : ShortcutTargetUnquoted = ""
Dim ShortcutTargetExist : ShortcutTargetExist = False

Dim ShortcutTargetSuffix : ShortcutTargetSuffix = ""

Dim ShortcutTargetArgs : ShortcutTargetArgs = ""
Dim ShortcutTargetArgsExist : ShortcutTargetArgsExist = False

Dim ShortcutWorkingDirectory : ShortcutWorkingDirectory = ""
Dim ShortcutWorkingDirectoryUnquoted : ShortcutWorkingDirectoryUnquoted = ""
Dim ShortcutWorkingDirectoryExist : ShortcutWorkingDirectoryExist = False

Dim ShowAs : ShowAs = 1
Dim ShowAsExist : ShowAsExist = False

Dim ExpandAllArgs : ExpandAllArgs = False
Dim ExpandArg0 : ExpandArg0 = False
Dim ExpandShortcutTarget : ExpandShortcutTarget = False
Dim ExpandShortcutTargetArgs : ExpandShortcutTargetArgs = False
Dim ExpandShortcutWorkingDirectory : ExpandShortcutWorkingDirectory = False

Dim AlwaysQuote : AlwaysQuote = False

Dim AllowTargetPathReassign : AllowTargetPathReassign = False
Dim AllowWorkingDirectoryReassign : AllowWorkingDirectoryReassign = False

Dim AllowDOSCurrentDirectory : AllowDOSCurrentDirectory = False
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
      ElseIf arg = "-print-assign" Or arg = "-p" Then ' Print assign
        PrintAssign = True
      ElseIf arg = "-u" Then ' Unescape %xx or %uxxxx
        UnescapeAllArgs = True
      ElseIf arg = "-t" Then ' Shortcut target path
        i = i + 1
        ShortcutTarget = WScript.Arguments(i)
        ShortcutTargetExist = True
      ElseIf arg = "-t-suffix" Then ' Shortcut target object suffix
        i = i + 1
        ShortcutTargetSuffix = WScript.Arguments(i)
      ElseIf arg = "-args" Then ' Shortcut target object arguments
        i = i + 1
        ShortcutTargetArgs = WScript.Arguments(i)
        ShortcutTargetArgsExist = True
      ElseIf arg = "-wd" Then ' Shortcut working directory
        i = i + 1
        ShortcutWorkingDirectory = WScript.Arguments(i)
        ShortcutWorkingDirectoryExist = True
      ElseIf arg = "-showas" Then ' Show window as
        i = i + 1
        ShowAs = CInt(WScript.Arguments(i))
        ShowAsExist = True
      ElseIf arg = "-q" Then ' Always quote target path argument if has no quote characters
        AlwaysQuote = True
      ElseIf arg = "-E" Then ' Expand environment variables in all arguments
        ExpandAllArgs = True
      ElseIf arg = "-E0" Then ' Expand environment variables only in the first argument
        ExpandArg0 = True
      ElseIf arg = "-Et" Then ' Expand environment variables only in the shortcut target path argument
        ExpandShortcutTarget = True
      ElseIf arg = "-Ea" Then ' Expand environment variables only in the shortcut target object arguments
        ExpandShortcutTargetArgs = True
      ElseIf arg = "-Ewd" Then ' Expand environment variables only in the shortcut working directory argument
        ExpandShortcutWorkingDirectory = True
      ElseIf arg = "-allow-target-path-reassign" Then ' Allow target path reassign
        AllowTargetPathReassign = True
      ElseIf arg = "-allow-wd-reassign" Then ' Allow working directory path reassign
        AllowWorkingDirectoryReassign = True
      ElseIf arg = "-allow-dos-current-dir" Then ' Allow long path conversion into DOS path for the current directory
        AllowDOSCurrentDirectory = True
      ElseIf arg = "-allow-dos-target-path" Then ' Allow target path reset by a reduced DOS path version
        AllowDOSTargetPath = True
      ElseIf arg = "-allow-dos-wd" Then ' Allow working directory reset by a reduced DOS path version
        AllowDOSWorkingDirectory = True
      ElseIf arg = "-allow-dos-paths" Then ' Allow a property reset by a reduced DOS path version
        AllowDOSPaths = True
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
    If UnescapeAllArgs Then
      arg = Unescape(arg)
    End If

    If ExpandAllArgs Then
      arg = objShell.ExpandEnvironmentStrings(arg)
    ElseIf ExpandArg0 And j = 0 Then
      arg = objShell.ExpandEnvironmentStrings(arg)
    ElseIf ExpandShortcutTarget And j = 1 Then
      arg = objShell.ExpandEnvironmentStrings(arg)
    ElseIf ExpandShortcutTargetArgs And j = 2 Then
      arg = objShell.ExpandEnvironmentStrings(arg)
    End If

    cmd_args(j) = arg

    j = j + 1
  End If
Loop While False : Next

ReDim Preserve cmd_args(j - 1)

' MsgBox Join(cmd_args, " ")

Dim cmd_args_ubound : cmd_args_ubound = UBound(cmd_args)

If cmd_args_ubound < 0 Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <ShortcutFilePath> argument is not defined."
  WScript.Quit 255
End If

If AllowDOSPaths Then
  AllowDOSCurrentDirectory = AllowDOSPaths
  AllowDOSTargetPath = AllowDOSPaths
  AllowDOSWorkingDirectory = AllowDOSPaths
End If

' functions

Function GetFileShortPath(FilePathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  Dim File : Set File = objFS.GetFile("\\?\" & FilePathAbs)
  GetFileShortPath = File.ShortPath
  If Left(GetFileShortPath, 4) = "\\?\" Then
    GetFileShortPath = Mid(GetFileShortPath, 5)
  End If
End Function

Function GetFolderShortPath(FolderPathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  Dim Folder : Set Folder = objFS.GetFolder("\\?\" & FolderPathAbs & "\")
  GetFolderShortPath = Folder.ShortPath
  If Left(GetFolderShortPath, 4) = "\\?\" Then
    GetFolderShortPath = Mid(GetFolderShortPath, 5)
  End If
End Function

Function GetShortPath(PathAbs)
  If objFS.FileExists("\\?\" & PathAbs) Then
    GetShortPath = GetFileShortPath(PathAbs)
  ElseIf objFS.FolderExists("\\?\" & PathAbs) Then
    GetShortPath = GetFolderShortPath(PathAbs)
  End If
End Function

Function IsPathExists(Path)
  If objFS.FileExists(Path) Or objFS.FolderExists(Path) Then
    IsPathExists = True
  Else
    IsPathExists = False
  End If
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
  Dim IsCurrentDirectoryExist : IsCurrentDirectoryExist = objFS.FileExists("\\?\" & ChangeCurrentDirectoryAbs)
  If IsCurrentDirectoryExist Then
    PrintOrEchoErrorLine _
      WScript.ScriptName & ": error: could not change current directory:" & vbCrLf & _
      WScript.ScriptName & ": info: CurrentDirectory=`" & ChangeCurrentDirectoryAbs & "`"
    WScript.Quit 1
  End If

  ' test on long path existence
  If (Not AllowDOSCurrentDirectory) Or objFS.FolderExists(ChangeCurrentDirectoryAbs) Then
    ' is not long path
    objShell.CurrentDirectory = ChangeCurrentDirectoryAbs
  ElseIf AllowDOSCurrentDirectory Then
    ' translate into short path
    objShell.CurrentDirectory = GetFolderShortPath(ChangeCurrentDirectoryAbs)
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

' ShortcutTarget

Dim ShortcutTargetUnquotedAbs
Dim IsShortcutTargetPathExist

' tests any absolute path without Win32 Namespace prefix
Function IsShortcutTargetPathExistWithUpdateFunc()
  IsShortcutTargetPathExistWithUpdateFunc = IsPathExists("\\?\" & ShortcutTargetUnquotedAbs)

  If (Not IsShortcutTargetPathExistWithUpdateFunc) And Len(ShortcutTargetSuffix) > 0 Then
    ShortcutTargetUnquotedAbs = ShortcutTargetUnquotedAbs & ShortcutTargetSuffix

    IsShortcutTargetPathExistWithUpdateFunc = IsPathExists("\\?\" & ShortcutTargetUnquotedAbs)
  End If
End Function

If ShortcutTargetExist Then
  If ExpandAllArgs Or ExpandShortcutTarget Then
    ShortcutTarget = objShell.ExpandEnvironmentStrings(ShortcutTarget)
  End If

  If UnescapeAllArgs Then
    ShortcutTarget = Unescape(ShortcutTarget)
  End If

  If Len(ShortcutTarget) > 1 And Left(ShortcutTarget, 1) = Chr(34) And Right(ShortcutTarget, 1) = Chr(34) Then
    ShortcutTargetUnquoted = Mid(ShortcutTarget, 2, Len(ShortcutTarget) - 2)
  Else
    ShortcutTargetUnquoted = ShortcutTarget
  End If

  ShortcutTargetUnquotedAbs = objFS.GetAbsolutePathName(ShortcutTargetUnquoted) ' CAUTION: can alter a path character case if path exists

  ' remove `\\?\` prefix
  If Left(ShortcutTargetUnquotedAbs, 4) = "\\?\" Then
    ShortcutTargetUnquotedAbs = Mid(ShortcutTargetUnquotedAbs, 5)
  End If

  If Not IgnoreUnexist Then
    ' test on path existence including long path
    IsShortcutTargetPathExist = IsShortcutTargetPathExistWithUpdateFunc()

    If Not IsShortcutTargetPathExist Then
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": error: shortcut target path does not exist:" & vbCrLf & _
        WScript.ScriptName & ": info: ShortcutTarget=`" & ShortcutTargetUnquotedAbs & "`"
      WScript.Quit 30
    End If
  End If

  If Not AlwaysQuote Then
    ShortcutTarget = ShortcutTargetUnquotedAbs
  Else
    ShortcutTarget = Chr(34) & ShortcutTargetUnquotedAbs & Chr(34)
  End If
End If

' ShortcutWorkingDirectory

Dim ShortcutWorkingDirectoryAbs
Dim IsShortcutWorkingDirectoryExist

If ShortcutWorkingDirectoryExist Then
  If ExpandAllArgs Or ExpandShortcutWorkingDirectory Then
    ShortcutWorkingDirectory = objShell.ExpandEnvironmentStrings(ShortcutWorkingDirectory)
  End If

  If UnescapeAllArgs Then
    ShortcutWorkingDirectory = Unescape(ShortcutWorkingDirectory)
  End If

  ShortcutWorkingDirectoryAbs = objFS.GetAbsolutePathName(ShortcutWorkingDirectory) ' CAUTION: can alter a path character case if path exists

  ' remove `\\?\` prefix
  If Left(ShortcutWorkingDirectoryAbs, 4) = "\\?\" Then
    ShortcutWorkingDirectoryAbs = Mid(ShortcutWorkingDirectoryAbs, 5)
  End If

  If Not IgnoreUnexist Then
    IsShortcutWorkingDirectoryExist = objFS.FolderExists("\\?\" & ShortcutWorkingDirectoryAbs)
    If Not IsShortcutWorkingDirectoryExist Then
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": error: shortcut working directory does not exist:" & vbCrLf & _
        WScript.ScriptName & ": info: ShortcutWorkingDirectory=`" & ShortcutWorkingDirectoryAbs & "`"
      WScript.Quit 20
    End If
  End If
End If

Dim ShortcutFilePathToOpen

' test on long path existence
If objFS.FileExists(ShortcutFilePathAbs) Then
  ' is not long path
  ShortcutFilePathToOpen = ShortcutFilePathAbs
Else
  ' translate into short path
  ShortcutFilePathToOpen = GetFileShortPath(ShortcutFilePathAbs)
End If

Dim objSC : Set objSC = objShell.CreateShortcut(ShortcutFilePathToOpen)

Dim ShortcutUpdated : ShortcutUpdated = False
Dim ShortcutWorkingDirectoryUpdated : ShortcutWorkingDirectoryUpdated = False

' ShortcutTarget

If ShortcutTargetExist Then
Do ' empty `Do-Loop` to emulate `Break`
  Dim ShortcutTargetUnquotedAbsLCase
  Dim ShortcutTargetShortPath

  If (Not AllowTargetPathReassign) Or AllowDOSTargetPath Then
    ShortcutTargetUnquotedAbsLCase = LCase(ShortcutTargetUnquotedAbs)
  End If

  If Not AllowTargetPathReassign Then
    ' WORKAROUND:
    '   Because objSC.TargetPath can contain a mixed path (half short and half long), then
    '   we have to convert it too.
    Dim IsShortcutPrevTargetPathExists : IsShortcutPrevTargetPathExists = IsPathExists(objSC.TargetPath)
    Dim ShortcutPrevTargetShortPath

    If IsShortcutPrevTargetPathExists Then
      ShortcutPrevTargetShortPath = GetShortPath(objSC.TargetPath)

      If LCase(ShortcutPrevTargetShortPath) = ShortcutTargetUnquotedAbsLCase Then
        Exit Do
      End If
    Else
      If LCase(objSC.TargetPath) = ShortcutTargetUnquotedAbsLCase Then
        Exit Do
      End If
    End If

    ' check on short path case insensitive equality
    If AllowDOSTargetPath Then
      If IsEmpty(IsShortcutTargetPathExist) Then
        ' test on path existence including long path
        IsShortcutTargetPathExist = IsShortcutTargetPathExistWithUpdateFunc()
      End If

      ' test on long path existence
      If IsShortcutTargetPathExist And Not IsPathExists(ShortcutTargetUnquotedAbs) Then
        ' an existen long path, check on short path case insensitive equality
        ShortcutTargetShortPath = GetShortPath(ShortcutTargetUnquotedAbs)

        ' WORKAROUND:
        '   Because objSC.TargetPath can contain a mixed path (half short and half long), then
        '   we have to convert it too.
        If IsShortcutPrevTargetPathExists Then
          If LCase(ShortcutPrevTargetShortPath) = LCase(ShortcutTargetShortPath) Then
            Exit Do
          End If
        Else
          If LCase(objSC.TargetPath) = LCase(ShortcutTargetShortPath) Then
            Exit Do
          End If
        End If
      End If
    End If
  End If

  If PrintAssign Then
    PrintOrEchoLine "TargetPath=" & ShortcutTargetUnquotedAbs
  End If

  objSC.TargetPath = ShortcutTarget
  ShortcutUpdated = True

  If AllowDOSTargetPath Then
    If Not LCase(objSC.TargetPath) = ShortcutTargetUnquotedAbsLCase Then
      If IsEmpty(ShortcutTargetShortPath) Then
        ShortcutTargetShortPath = GetShortPath(ShortcutTargetUnquotedAbs)
      End If

      If PrintAssign Then
        PrintOrEchoLine "TargetPath(short)=" & ShortcutTargetShortPath
      End If

      If Not AlwaysQuote Then
        ShortcutTarget = ShortcutTargetShortPath
      Else
        ShortcutTarget = Chr(34) & ShortcutTargetShortPath & Chr(34)
      End If

      objSC.TargetPath = ShortcutTarget
    End If
  End If
Loop While False
End If

' ShortcutTargetArgs

If ShortcutTargetArgsExist Then
  If ExpandAllArgs Or ExpandShortcutTargetArgs Then
    ShortcutTargetArgs = objShell.ExpandEnvironmentStrings(ShortcutTargetArgs)
  End If

  If UnescapeAllArgs Then
    ShortcutTargetArgs = Unescape(ShortcutTargetArgs)
  End If

  objSC.Arguments = ShortcutTargetArgs
  ShortcutUpdated = True
End If

' ShortcutWorkingDirectory

Dim ShortcutWorkingDirectoryAbsLCase
Dim ShortcutWorkingDirectoryShortPath

If ShortcutWorkingDirectoryExist Then
Do ' empty `Do-Loop` to emulate `Break`
  If (Not AllowWorkingDirectoryReassign) Or AllowDOSWorkingDirectory Then
    ShortcutWorkingDirectoryAbsLCase = LCase(ShortcutWorkingDirectoryAbs)
  End If

  If Not AllowWorkingDirectoryReassign Then
    If LCase(objSC.WorkingDirectory) = ShortcutWorkingDirectoryAbsLCase Then
      Exit Do
    End If

    ' check on short path case insensitive equality
    If AllowDOSWorkingDirectory Then
      If IsEmpty(IsShortcutWorkingDirectoryExist) Then
        ' test on path existence including long path
        IsShortcutWorkingDirectoryExist = objFS.FolderExists("\\?\" & ShortcutWorkingDirectoryAbs)
      End If

      ' test on long path existence
      If IsShortcutWorkingDirectoryExist And Not objFS.FolderExists(ShortcutWorkingDirectoryAbs) Then
        ' an existen long path, check on short path case insensitive equality
        ShortcutWorkingDirectoryShortPath = GetFolderShortPath(ShortcutWorkingDirectoryAbs)

        If LCase(objSC.WorkingDirectory) = LCase(ShortcutWorkingDirectoryShortPath) Then
          Exit Do
        End If
      End If
    End If
  End If

  If PrintAssign Then
    PrintOrEchoLine "WorkingDirectory=" & ShortcutWorkingDirectoryAbs
  End If

  objSC.WorkingDirectory = ShortcutWorkingDirectoryAbs
  ShortcutWorkingDirectoryUpdated = True
  ShortcutUpdated = True
Loop While False
End If

If ShowAsExist Then
  objSC.WindowStyle = CInt(ShowAs)
  ShortcutUpdated = True
End If

If ShortcutUpdated Then
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
        from_file_path_abs = GetFileShortPath(from_file_path_abs)
      End If

      ' test on long path existence
      If Not objFS.FolderExists(to_file_parent_dir_path_abs) Then
        ' translate into short path
        to_file_parent_dir_path_abs = GetFolderShortPath(to_file_parent_dir_path_abs)
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

  If ShortcutWorkingDirectoryUpdated Then
    ' WORKAROUND:
    '   WorkingDirectory does truncate after the save and close, so we must fix it after the shortcut reopen.
    '   Side effects:
    '     Removes machine name and other parameters from the shortcut.
    '
    If AllowDOSWorkingDirectory Then
      ' Set objSC = Nothing
      Set objSC = objShell.CreateShortcut(ShortcutFilePathToOpen)

      If Not LCase(objSC.WorkingDirectory) = ShortcutWorkingDirectoryAbsLCase Then
        If IsEmpty(ShortcutWorkingDirectoryShortPath) Then
          ShortcutWorkingDirectoryShortPath = GetFolderShortPath(ShortcutWorkingDirectoryAbs)
        End If

        If PrintAssign Then
          PrintOrEchoLine "WorkingDirectory(short)=" & ShortcutWorkingDirectoryShortPath
        End If

        objSC.WorkingDirectory = ShortcutWorkingDirectoryShortPath

        objSC.Save
      End If
    End If
  End If
End If
