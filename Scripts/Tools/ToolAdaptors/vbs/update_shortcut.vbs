''' Updates the Windows shortcut file.

''' CAUTION:
'''   WScript.Shell can not handle all Unicode characters in path properties, including characters in the path to a shortcut file.
'''   Details: https://stackoverflow.com/questions/39365489/how-do-you-keep-diacritics-in-shortcut-paths
'''

''' USAGE:
'''   update_shortcut.vbs [-CD <CurrentDirectoryPath>] [-WD <ShortcutWorkingDirectory>] [-showas <ShowWindowAsNumber>] [-reassign-target-path] [-ignore-unexist] [-reset-wd[-from-target-path]] [-p[rint-assing]] [-u] [-q] [-E[0 | t | a]] [-t <ShortcutTarget>] [-args <ShortcutArgs>] [--] <ShortcutFilePath>

''' DESCRIPTION:
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''   -D <CurrentDirectoryPath>
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
'''     By default TargetPath and WorkingDirectory does check on existence.
'''     Use this flag to skip the check.
'''   -reassign-target-path
'''     Reassign target path property which does trigger the shell to validate
'''     the path and rewrite the shortcut file even if nothing is changed
'''     reducing the shortcut content.
'''   -reset-wd[-from-target-path]
'''     Reset WorkingDirectory from TargetPath.
'''   -p[rint-assign]
''      Print assign.
'''   -u
'''     Unescape %xx or %uxxxx sequences.
'''   -q
'''     Always quote CMD argument (if has no quote characters).
'''   -E
'''     Expand environment variables in all arguments.
'''   -E0
'''     Expand environment variables only in the first argument.
'''   -Et
'''     Expand environment variables only in the shortcut target object.
'''   -Ea
'''     Expand environment variables only in the shortcut arguments.

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

''' CAUTION:
'''   You should remove shortcut file BEFORE creation otherwise the shortcut
'''   would be updated instead of recreated.

''' Example to create a minimalistic and clean version of a shortcut:
'''   >
'''   del /F /Q "%WINDIR%\System32\cmd_system32.lnk"
'''   make_shortcut.bat -CD "%WINDIR%\System32" -q cmd_system32.lnk ^%SystemRoot^%\System32\cmd.exe
'''   update_shortcut.bat -CD "%WINDIR%\System32" -q cmd_system32.lnk
''' Or
'''   >
'''   del /F /Q "%WINDIR%\System32\cmd_system32.lnk"
'''   make_shortcut.bat -CD "%WINDIR%\System32" -u cmd_system32.lnk "%22%25SystemRoot%25\System32\cmd.exe%22"
'''   update_shortcut.bat -CD "%WINDIR%\System32" -q cmd_system32.lnk
'''
''' Note:
'''   A difference in above examples between call to `make_shortcut.vbs` and
'''   call to `make_shortcut.vbs`+`update_shortcut.vbs` has first found in the
'''   `Windows XP x64 Pro SP2` and `Windows XP x86 Pro SP3`.
'''
''' Note:
'''   The single call in above example to `make_shortcut.vbs` instead of
'''   `make_shortcut.vbs`+`update_shortcut.vbs` does generate a cleaner
''    shortcut, but in other cases is vice versa.

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

Dim ReassignTargetPath : ReassignTargetPath = False
Dim ResetWorkingDirFromTargetPath : ResetWorkingDirFromTargetPath = False

Dim UnescapeAllArgs : UnescapeAllArgs = False

Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim ChangeCurrentDirectoryExist : ChangeCurrentDirectoryExist = False

Dim ShortcutWorkingDirectory : ShortcutWorkingDirectory = ""
Dim ShortcutWorkingDirectoryUnquoted : ShortcutWorkingDirectoryUnquoted = ""
Dim ShortcutWorkingDirectoryExist : ShortcutWorkingDirectoryExist = False

Dim ShortcutTarget : ShortcutTarget = ""
Dim ShortcutTargetUnquoted : ShortcutTargetUnquoted = ""
Dim ShortcutTargetExist : ShortcutTargetExist = False

Dim ShortcutArgs : ShortcutArgs = ""
Dim ShortcutArgsExist : ShortcutArgstExist = False

Dim ShowAs : ShowAs = 1
Dim ShowAsExist : ShowAsExist = False

Dim ExpandAllArgs : ExpandAllArgs = False
Dim ExpandArg0 : ExpandArg0 = False
Dim ExpandShortcutTarget : ExpandShortcutTarget = False
Dim ExpandShortcutArgs : ExpandShortcutArgs = False
Dim AlwaysQuote : AlwaysQuote = False

Dim objShell : Set objShell = WScript.CreateObject("WScript.Shell")

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Left(arg, 1) = "-" Then
      If arg = "-ignore-unexist" Then
       IgnoreUnexist = True
      ElseIf arg = "-reassign-target-path" Then
        ReassignTargetPath = True
      ElseIf arg = "-reset-wd-from-target-path" Or arg = "-reset-wd" Then
        ResetWorkingDirFromTargetPath = True
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
      ElseIf arg = "-q" Then ' Always quote CMD argument (if has no quote characters)
        AlwaysQuote = True
      ElseIf arg = "-E" Then ' Expand environment variables in all arguments
        ExpandAllArgs = True
      ElseIf arg = "-E0" Then ' Expand environment variables only in the first argument
        ExpandArg0 = True
      ElseIf arg = "-Et" Then ' Expand environment variables only in the shortcut target object
        ExpandShortcutTarget = True
      ElseIf arg = "-Ea" Then ' Expand environment variables only in the shortcut arguments
        ExpandShortcutArgs = True
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

    If j > 0 And InStr(arg, Chr(34)) = 0 Then
      If AlwaysQuote Or Len(arg & "") = 0 Or InStr(arg, Space(1)) <> 0 Or InStr(arg, vbTab) <> 0 Then
        cmd_args(j) = Chr(34) & arg & Chr(34)
      Else
        cmd_args(j) = arg
      End If
    Else
      cmd_args(j) = arg
    End If

    j = j + 1
  End If
Loop While False : Next

ReDim Preserve cmd_args(j - 1)

' MsgBox Join(cmd_args, " ")

Dim cmd_args_ubound : cmd_args_ubound = UBound(cmd_args)

If cmd_args_ubound < 0 Then
  WScript.Echo WScript.ScriptName & ": error: <ShortcutFilePath> argument is not defined."
  WScript.Quit 1
End If

If ChangeCurrentDirectoryExist Then
  objShell.CurrentDirectory = ChangeCurrentDirectory
End If

Set objSC = objShell.CreateShortcut(cmd_args(0))

Dim objFS

If Not IgnoreUnexist Then
  Set objFS = CreateObject("Scripting.FileSystemObject")
End If

If ShortcutTargetExist Then
  If ExpandAllArgs Or ExpandShortcutTarget Then
    ShortcutTarget = objShell.ExpandEnvironmentStrings(ShortcutTarget)
  End If

  If UnescapeAllArgs Then
    ShortcutTarget = Unescape(ShortcutTarget)
  End If

  If AlwaysQuote And InStr(ShortcutTarget, Chr(34)) = 0 Then
    ShortcutTarget = Chr(34) & ShortcutTarget & Chr(34)
  End If
ElseIf ReassignTargetPath Or ResetWorkingDirFromTargetPath Then
  ShortcutTarget = objSC.TargetPath
  ShortcutTargetExist = True
End If

If ShortcutTargetExist Then
  If Len(ShortcutTarget) > 1 And Left(ShortcutTarget, 1) = Chr(34) And Right(ShortcutTarget, 1) = Chr(34) Then
    ShortcutTargetUnquoted = Mid(ShortcutTarget, 2, Len(ShortcutTarget) - 2)
  Else
    ShortcutTargetUnquoted = ShortcutTarget
  End If
End If

If ShortcutTargetExist Then
  If Not IgnoreUnexist Then
    Dim IsShortcutTargetExistedFile : IsShortcutTargetExistedFile = objFS.FileExists(ShortcutTargetUnquoted)
    If Not IsShortcutTargetExistedFile Then
      WScript.Echo WScript.ScriptName & ": error: shortcut target path does not exist: `" & ShortcutTargetUnquoted & "`"
      WScript.Quit 2
    End If
  End If

  ' MsgBox "TargetPath=" & ShortcutTarget
  If PrintAssign Then
    WScript.Echo "TargetPath=" & ShortcutTarget
  End If

  objSC.TargetPath = ShortcutTarget
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

' ignore shortcut working directory set on reset
If Not ResetWorkingDirFromTargetPath Then
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
        WScript.Echo WScript.ScriptName & ": error: shortcut working directory does not exist: `" & ShortcutWorkingDirectoryUnquoted & "`"
        WScript.Quit 3
      End If
    End If

    objSC.WorkingDirectory = ShortcutWorkingDirectory
  End If
Else
  If IsEmpty(objFS) Then
    Set objFS = CreateObject("Scripting.FileSystemObject")
  End If

  ' NOTE:
  '   Shortcut target must not be an existed directory path, otherwise WorkingDirectory must be not empty, otherwise - ignore.
  '   Meaning:
  '     A directory shortcut basically does not use the WorkingDirectory property, but if does, then
  '     the WorkingDirectory property must be not empty to initiate a change.
  '     If a directory does not exist by the target path, then the target path is treated as a file path.
  '
  Dim IsShortcutTargetExistedDir : IsShortcutTargetExistedDir = objFS.FolderExists(ShortcutTargetUnquoted)

  If (Not objFS.FolderExists(ShortcutTargetUnquoted)) Or Len(objSC.WorkingDirectory) > 0 Then
    Dim ShortcutParentDir : ShortcutParentDir = objFS.GetParentFolderName(ShortcutTargetUnquoted)

    If Len(ShortcutParentDir) > 0 Then
      ' MsgBox "WorkingDirectory=" & ShortcutParentDir
      If PrintAssign Then
        WScript.Echo "WorkingDirectory=" & ShortcutParentDir
      End If

      objSC.WorkingDirectory = ShortcutParentDir
    End If
  End If
End If

If ShowAsExist Then
  objSC.WindowStyle = CInt(ShowAs)
End If

objSC.Save
