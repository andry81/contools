''' Updates the Windows shortcut file.

''' CAUTION:
'''   WScript.Shell can not handle all Unicode characters in path properties, including characters in the path to a shortcut file.
'''   Details: https://stackoverflow.com/questions/39365489/how-do-you-keep-diacritics-in-shortcut-paths
'''

''' USAGE:
'''   update_shortcut.vbs [-CD <CurrentDirectoryPath>]
'''     [-WD <ShortcutWorkingDirectory>] [-showas <ShowWindowAsNumber>]
'''     [-ignore-unexist] [-allow-auto-recover] [-p[rint-assing]] [-u] [-q]
'''     [-E[0 | t | a]] [-allow-dos-target-path]
'''     [-t <ShortcutTarget>] [-args <ShortcutArgs>] [--]
'''     <ShortcutFilePath>

''' DESCRIPTION:
'''   By default resaves shortcut which does trigger the Windows Shell
'''   component to validate the path and rewrites the shortcut file even if
'''   nothing is changed reducing the shortcut content.
'''   Does not apply if TargetPath does not exist and `-ignore-unexist`
'''   option is not used, to avoid a shortcut accident corruption by the
'''   Windows Shell component internal guess logic (see `-ignore-unexist`
'''   option description).
'''
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''   -CD <CurrentDirectoryPath>
'''     Changes current directory to <CurrentDirectoryPath> before the
'''     execution.
'''   -WD <ShortcutWorkingDirectory>
'''     Working directory in the shortcut file.
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
'''         shortcut with old path save into Description property.
'''       - Shortcut can be completely rewritten losing other properties and
'''         data.
'''
'''     Use this option with the caution.
'''
'''   -p[rint-assign]
'''     Print assign.
'''   -u
'''     Unescape %xx or %uxxxx sequences.
'''   -q
'''     Always quote target path argument if has no quote characters.
'''   -E
'''     Expand environment variables in all arguments.
'''   -E0
'''     Expand environment variables only in the first argument.
'''   -Et
'''     Expand environment variables only in the shortcut target object.
'''   -Ea
'''     Expand environment variables only in the shortcut arguments.
'''
'''   -allow-dos-target-path
'''     Reread target path and if it is truncated, then reset it by a reduced
'''     DOS path version.
'''     It is useful when you want to create not truncated shortcut target file
'''     path to open it by an old version application which does not support
'''     long paths or UNC paths, but supports open target paths by a shortcut
'''     file.
'''
'''   -t <ShortcutTarget>
'''     Shortcut target value to assign.
'''   -args <ShortcutArgs>
'''     Shortcut arguments value to assign.

''' Note:
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
''' Note:
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

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim PrintAssign : PrintAssign = False

Dim IgnoreUnexist : IgnoreUnexist = False

Dim UnescapeAllArgs : UnescapeAllArgs = False

Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim ChangeCurrentDirectoryExist : ChangeCurrentDirectoryExist = False

Dim ShortcutFilePath : ShortcutFilePath = ""

Dim ShortcutTarget : ShortcutTarget = ""
Dim ShortcutTargetUnquoted : ShortcutTargetUnquoted = ""
Dim ShortcutTargetExist : ShortcutTargetExist = False

Dim ShortcutArgs : ShortcutArgs = ""
Dim ShortcutArgsExist : ShortcutArgstExist = False

Dim ShortcutWorkingDirectory : ShortcutWorkingDirectory = ""
Dim ShortcutWorkingDirectoryUnquoted : ShortcutWorkingDirectoryUnquoted = ""
Dim ShortcutWorkingDirectoryExist : ShortcutWorkingDirectoryExist = False

Dim ShowAs : ShowAs = 1
Dim ShowAsExist : ShowAsExist = False

Dim ExpandAllArgs : ExpandAllArgs = False
Dim ExpandArg0 : ExpandArg0 = False
Dim ExpandShortcutTarget : ExpandShortcutTarget = False
Dim ExpandShortcutArgs : ExpandShortcutArgs = False
Dim AlwaysQuote : AlwaysQuote = False

Dim AllowDOSTargetPath : AllowDOSTargetPath = False

Dim objShell : Set objShell = WScript.CreateObject("WScript.Shell")

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Left(arg, 1) = "-" Then
      If arg = "-ignore-unexist" Then
       IgnoreUnexist = True
      ElseIf arg = "-print-assign" Or arg = "-p" Then ' Print assign
        PrintAssign = True
      ElseIf arg = "-u" Then ' Unescape %xx or %uxxxx
        UnescapeAllArgs = True
      ElseIf arg = "-CD" Then ' Change current directory
        i = i + 1
        ChangeCurrentDirectory = WScript.Arguments(i)
        ChangeCurrentDirectoryExist = True
      ElseIf arg = "-WD" Then ' Shortcut working directory
        i = i + 1
        ShortcutWorkingDirectory = WScript.Arguments(i)
        ShortcutWorkingDirectoryExist = True
      ElseIf arg = "-t" Then ' Shortcut target object
        i = i + 1
        ShortcutTarget = WScript.Arguments(i)
        ShortcutTargetExist = True
      ElseIf arg = "-args" Then ' Shortcut target object arguments
        i = i + 1
        ShortcutArgs = WScript.Arguments(i)
        ShortcutArgsExist = True
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
      ElseIf arg = "-Et" Then ' Expand environment variables only in the shortcut target object
        ExpandShortcutTarget = True
      ElseIf arg = "-Ea" Then ' Expand environment variables only in the shortcut arguments
        ExpandShortcutArgs = True
      ElseIf arg = "-allow-dos-target-path" Then ' Allow target path reset by a reduced DOS path version
        AllowDOSTargetPath = True
      Else
        WScript.Echo WScript.ScriptName & ": error: unknown flag: `" & arg & "`"
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
    End If

    cmd_args(j) = arg

    j = j + 1
  End If
Loop While False : Next

ReDim Preserve cmd_args(j - 1)

' MsgBox Join(cmd_args, " ")

Dim cmd_args_ubound : cmd_args_ubound = UBound(cmd_args)

If cmd_args_ubound < 0 Then
  WScript.Echo WScript.ScriptName & ": error: <ShortcutFilePath> argument is not defined."
  WScript.Quit 255
End If

ShortcutFilePath = cmd_args(0)

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

Dim IsShortcutFileExist : IsShortcutFileExist = objFS.FileExists(ShortcutFilePath)
If Not IsShortcutFileExist Then
  WScript.Echo WScript.ScriptName & ": error: shortcut path does not exist:"
  WScript.Echo WScript.ScriptName & ": info: ShortcutFilePath=`" & ShortcutFilePath & "`"
  WScript.Quit 1
End If

If ChangeCurrentDirectoryExist Then
  objShell.CurrentDirectory = ChangeCurrentDirectory
End If

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

  If Not IgnoreUnexist Then
    Dim IsShortcutTargetPathExist : IsShortcutTargetPathExist = False

    If objFS.FileExists(ShortcutTargetUnquoted) Then
      IsShortcutTargetPathExist = True
    ElseIf objFS.FolderExists(ShortcutTargetUnquoted) Then
      IsShortcutTargetPathExist = True
    End If

    If Not IsShortcutTargetPathExist Then
      WScript.Echo WScript.ScriptName & ": error: shortcut target path does not exist:"
      WScript.Echo WScript.ScriptName & ": info: TargetPath=`" & ShortcutTargetUnquoted & "`"
      WScript.Quit 10
    End If
  End If

  If AlwaysQuote And InStr(ShortcutTargetUnquoted, Chr(34)) = 0 Then
    ShortcutTarget = Chr(34) & ShortcutTargetUnquoted & Chr(34)
  End If
End If

Dim objSC : Set objSC = objShell.CreateShortcut(ShortcutFilePath)

If ShortcutTargetExist Then
  ' MsgBox "TargetPath=" & ShortcutTarget
  If PrintAssign Then
    WScript.Echo "TargetPath=" & ShortcutTarget
  End If

  objSC.TargetPath = ShortcutTarget

  If AllowDOSTargetPath Then
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
End If

If ShortcutArgsExist Then
  If ExpandAllArgs Or ExpandShortcutArgs Then
    ShortcutArgs = objShell.ExpandEnvironmentStrings(ShortcutArgs)
  End If

  If UnescapeAllArgs Then
    ShortcutArgs = Unescape(ShortcutArgs)
  End If

  objSC.Arguments = ShortcutArgs
End If

If ShortcutWorkingDirectoryExist Then
  If UnescapeAllArgs Then
    ShortcutWorkingDirectory = Unescape(ShortcutWorkingDirectory)
  End If

  If Len(ShortcutWorkingDirectory) > 1 And Left(ShortcutWorkingDirectory, 1) = Chr(34) And Right(ShortcutWorkingDirectory, 1) = Chr(34) Then
    ShortcutWorkingDirectoryUnquoted = Mid(ShortcutWorkingDirectory, 2, Len(ShortcutWorkingDirectory) - 2)
  Else
    ShortcutWorkingDirectoryUnquoted = ShortcutWorkingDirectory
  End If

  ' MsgBox "WorkingDirectory=" & ShortcutWorkingDirectory
  If PrintAssign Then
    WScript.Echo "WorkingDirectory=" & ShortcutWorkingDirectory
  End If

  If Not IgnoreUnexist Then
    Dim IsShortcutWorkingDirectoryExistedDir : IsShortcutWorkingDirectoryExistedDir = objFS.FolderExists(ShortcutWorkingDirectoryUnquoted)
    If Not IsShortcutWorkingDirectoryExistedDir Then
      WScript.Echo WScript.ScriptName & ": error: shortcut working directory does not exist:"
      WScript.Echo WScript.ScriptName & ": info: WorkingDirectory=`" & ShortcutWorkingDirectoryUnquoted & "`"
      WScript.Quit 20
    End If
  End If

  objSC.WorkingDirectory = ShortcutWorkingDirectory
End If

If ShowAsExist Then
  objSC.WindowStyle = CInt(ShowAs)
End If

objSC.Save
