''' Creates the Windows shortcut file.

''' USAGE:
'''   make_shortcut.vbs [-CD <CurrentDirectoryPath>] [-WD <ShortcutWorkingDirectory>] [-showas <ShowWindowAsNumber>] [-reassign-target-path] [-u] [-q] [-E[0 | t | a]] [-u] [--] <ShortcutFilePath> <ShortcutTarget> <ShortcutArgs>
'''
''' DESCRIPTION:
'''   --
'''     Separator between flags and positional arguments to explicitly stop the flags parser.
'''   -D <CurrentDirectoryPath>
'''     Changes current directory to <CurrentDirectoryPath> before the execution.
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
'''   -reassign-target-path
'''     Reassign target path property which does trigger the shell to validate
'''     the path and rewrite the shortcut file even if nothing is changed
'''     reducing the shortcut content.
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
'''
''' Note:
'''   1. Creation of a shortcut under ealier version of the Windows makes shortcut
'''      cleaner. For example, do use Windows XP instead of the Windows 7 and
'''      x86 instead of x64 to make a cleaner shortcut without redundant data.
'''   2. Creation of a shortcut to the `cmd.exe` with the current directory in
'''      the "%SYSTEMROOT%\system32" directory avoids generation of redundant
'''      path prefixes (offset) in the shortcut file internals.
'''   3. Update of a shortcut immediately after it's creation does cleanup shortcut
'''      from redundant data.

''' CAUTION:
'''   You should remove shortcut file BEFORE creation otherwise the shortcut
'''   would be updated instead of recreated.

''' Example to create a minimalistic and clean version of a shortcut:
'''   >
'''   del /F /Q cmd_system32.lnk
'''   make_shortcut.bat -CD "%WINDIR%\System32" -q cmd_system32.lnk ^%SystemRoot^%\System32\cmd.exe
'''   update_shortcut.bat -CD "%WINDIR%\System32" -q cmd_system32.lnk
''' Or
'''   >
'''   del /F /Q cmd_system32.lnk
'''   make_shortcut.bat -CD "%WINDIR%\System32" -u cmd_system32.lnk "%22%25SystemRoot%25\System32\cmd.exe%22"
'''   update_shortcut.bat -CD "%WINDIR%\System32" -q cmd_system32.lnk

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
''' , where the `\\?\usb#vid_0e8d&pid_201d&mi_00#7&1084e14&0&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}` might be different for each device

''' CAUTION:
'''   The list of issues around a shortcut (.lnk) file:
'''
'''   PROS:
'''     * If you want to run a process elevated, then you can raise the `Run as Administrator` flag in the shortcut.
'''       You don't need a localized version of Administrator account name like for the runas executable.
'''
'''   CONS:
'''     * If create a shortcut to the Windows command interpreter (cmd.exe) with `Run as Administrator` flag raised, then you will run
'''       elevated only the cmd.exe process. To start any other process you have to either run it from the `cmd.exe` script, or create
'''       another standalone shortcut with the `Run as Administrator` flag raised.
'''     * Run from shortcut file (.lnk) in the Windows XP (but not in the Windows 7) brings truncated command line down to ~260 characters.
'''     * Run from shortcut file (.lnk) loads console windows parameters (font, windows size, buffer size, etc) from the shortcut at first
'''       and from the registry (HKCU\Console) at second. If try to change and save parameters, then it will be saved ONLY into the shortcut,
'''       which brings the shortcut file overwrite.

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim ReassignTargetPath : ReassignTargetPath = False

Dim UnescapeAllArgs : UnescapeAllArgs = False

Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim ChangeCurrentDirectoryExist : ChangeCurrentDirectoryExist = False

Dim ShortcutWorkingDirectory : ShortcutWorkingDirectory = ""
Dim ShortcutWorkingDirectoryExist : ShortcutWorkingDirectoryExist = False

Dim ShortcutTarget : ShortcutTarget = ""
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
    If arg <> "--" And Mid(arg, 1, 1) = "-" Then
      If arg = "-reassign-target-path" Then
        ReassignTargetPath = True
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
    ElseIf ExpandShortcutTarget And j = 1 Then
      arg = objShell.ExpandEnvironmentStrings(arg)
    ElseIf ExpandShortcutArgs And j = 2 Then
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
  WScript.Echo WScript.ScriptName & ": error: FILE_NAME argument is not defined."
  WScript.Quit 1
End If

If cmd_args_ubound >= 1 Then
  ShortcutTarget = cmd_args(1)
  ShortcutTargetExist = True
End If

If cmd_args_ubound >= 2 Then
  ShortcutArgs = cmd_args(2)
  ShortcutArgsExist = True
End If

If ChangeCurrentDirectoryExist Then
  objShell.CurrentDirectory = ChangeCurrentDirectory
End If

Set objSC = objShell.CreateShortcut(cmd_args(0))

If ShortcutTargetExist Then
  If AlwaysQuote And InStr(ShortcutTarget, Chr(34)) = 0 Then
    ShortcutTarget = Chr(34) & ShortcutTarget & Chr(34)
  End If
ElseIf ReassignTargetPath Then
  ShortcutTarget = objSC.TargetPath
  ShortcutTargetExist = True
End If

If ShortcutTargetExist Then
  objSC.TargetPath = ShortcutTarget
End If

If ShortcutArgsExist Then
  objSC.Arguments = ShortcutArgs
End If

If ShortcutWorkingDirectoryExist Then
  If UnescapeAllArgs Then
    ShortcutWorkingDirectory = Unescape(ShortcutWorkingDirectory)
  End If

  objSC.WorkingDirectory = ShortcutWorkingDirectory
End If

If ShowAsExist Then
  objSC.WindowStyle = CInt(ShowAs)
End If

objSC.Save
