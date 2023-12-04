''' Creates new Windows shortcut file.

''' CAUTION:
'''   WScript.Shell can not handle all Unicode characters in path properties, including characters in the path to a shortcut file.
'''   Details: https://stackoverflow.com/questions/39365489/how-do-you-keep-diacritics-in-shortcut-paths
'''

''' USAGE:
'''   make_shortcut.vbs
'''     [-CD <CurrentDirectoryPath>]
'''     [-showas <ShowWindowAsNumber>]
'''     [-allow-dos-target-path] [-allow-dos-wd] [-allow-dos-paths]
'''     [-u] [-q]
'''     [-E[0 | t | a | wd]]
'''     [-wd <ShortcutWorkingDirectory>]
'''     [--]
'''     <ShortcutFilePath> <ShortcutTarget> [<ShortcutTargetArgs>]

''' DESCRIPTION:
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
'''   -wd <ShortcutWorkingDirectory>
'''     Working directory value to assign.
'''
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

Dim UnescapeAllArgs : UnescapeAllArgs = False

Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim ChangeCurrentDirectoryExist : ChangeCurrentDirectoryExist = False

Dim ShortcutFilePath : ShortcutFilePath = ""

Dim ShortcutTarget : ShortcutTarget = ""
Dim ShortcutTargetUnquoted : ShortcutTargetUnquoted = ""

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
      ElseIf arg = "-u" Then ' Unescape %xx or %uxxxx
        UnescapeAllArgs = True
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

If cmd_args_ubound < 1 Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <ShortcutTarget> argument is not defined."
  WScript.Quit 255
End If

' change current directory before any file system request because of relative paths
If ChangeCurrentDirectoryExist Then
  objShell.CurrentDirectory = ChangeCurrentDirectory
End If

ShortcutFilePath = cmd_args(0)

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

Dim ShortcutFilePathAbs : ShortcutFilePathAbs = objFS.GetAbsolutePathName(ShortcutFilePath) ' CAUTION: can alter a path character case if path exists

' remove `\\?\` prefix
If Left(ShortcutFilePathAbs, 4) = "\\?\" Then
  ShortcutFilePathAbs = Mid(ShortcutFilePathAbs, 5)
End If

' test on path existence including long path
Dim IsShortcutFileExist : IsShortcutFileExist = objFS.FileExists("\\?\" & ShortcutFilePathAbs)
If IsShortcutFileExist Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: shortcut file must not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: ShortcutFilePath=`" & ShortcutFilePathAbs & "`"
  WScript.Quit 1
End If

Dim ShortcutFileDir : ShortcutFileDir = objFS.GetParentFolderName(ShortcutFilePathAbs)
Dim IsShortcutFileDirExist : IsShortcutFileDirExist = objFS.FolderExists("\\?\" & ShortcutFileDir & "\")
If Not IsShortcutFileDirExist Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: shortcut file directory must exist:" & vbCrLf & _
    WScript.ScriptName & ": info: ShortcutFileDir=`" & ShortcutFileDir & "`"
  WScript.Quit 2
End If

ShortcutTarget = cmd_args(1)

If cmd_args_ubound >= 2 Then
  ShortcutTargetArgs = cmd_args(2)
  ShortcutTargetArgsExist = True
End If

If AllowDOSPaths Then
  AllowDOSTargetPath = AllowDOSPaths
  AllowDOSWorkingDirectory = AllowDOSPaths
End If

' ShortcutTarget

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

Dim ShortcutTargetUnquotedAbs : ShortcutTargetUnquotedAbs = objFS.GetAbsolutePathName(ShortcutTargetUnquoted) ' CAUTION: can alter a path character case if path exists

' remove `\\?\` prefix
If Left(ShortcutTargetUnquotedAbs, 4) = "\\?\" Then
  ShortcutTargetUnquotedAbs = Mid(ShortcutTargetUnquotedAbs, 5)
End If

Dim IsShortcutTargetPathExist : IsShortcutTargetPathExist = False

' test on path existence including long path
If objFS.FileExists("\\?\" & ShortcutTargetUnquotedAbs) Then
  IsShortcutTargetPathExist = True
ElseIf objFS.FolderExists("\\?\" & ShortcutTargetUnquotedAbs) Then
  IsShortcutTargetPathExist = True
End If

If Not IsShortcutTargetPathExist Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: shortcut target path does not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: ShortcutTarget=`" & ShortcutTargetUnquotedAbs & "`"
  WScript.Quit 10
End If

If Not AlwaysQuote Then
  ShortcutTarget = ShortcutTargetUnquotedAbs
Else
  ShortcutTarget = Chr(34) & ShortcutTargetUnquotedAbs & Chr(34)
End If

Dim ShortcutFilePathToOpen

' test on long path existence by temporary empty text file
Dim ShortcutEmptyFile : Set ShortcutEmptyFile = objFS.CreateTextFile("\\?\" & ShortcutFilePathAbs)
' close handle immediately to be able to delete the file later
ShortcutEmptyFile.Close()
Set ShortcutEmptyFile = Nothing

If objFS.FileExists(ShortcutFilePathAbs) Then
  ' is not long path
  objFS.DeleteFile("\\?\" & ShortcutFilePathAbs)
  ShortcutFilePathToOpen = ShortcutFilePathAbs
Else
  ' translate into short path

  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  Dim ShortcutFile : Set ShortcutFile = objFS.GetFile("\\?\" & ShortcutFilePathAbs)
  Dim ShortcutFileShortPath : ShortcutFileShortPath = ShortcutFile.ShortPath
  If Left(ShortcutFileShortPath, 4) = "\\?\" Then
    ShortcutFileShortPath = Mid(ShortcutFileShortPath, 5)
  End If

  objFS.DeleteFile("\\?\" & ShortcutFilePathAbs)

  ' construct path from short path parent directory and long path file name
  ShortcutFilePathToOpen = objFS.GetParentFolderName(ShortcutFileShortPath) & "\" & objFS.GetFileName(ShortcutFilePathAbs)
End If

Dim objSC : Set objSC = objShell.CreateShortcut(ShortcutFilePathToOpen)

objSC.TargetPath = ShortcutTarget

If AllowDOSTargetPath Then
  If Not LCase(objSC.TargetPath) = LCase(ShortcutTargetUnquotedAbs) Then
    ' WORKAROUND:
    '   We use `\\?\` to bypass `GetFile` error: `File not found`.
    Dim ShortcutTargetFile : Set ShortcutTargetFile = objFS.GetFile("\\?\" & ShortcutTargetUnquotedAbs)
    Dim ShortcutTargetShortPath : ShortcutTargetShortPath = ShortcutTargetFile.ShortPath
    If Left(ShortcutTargetShortPath, 4) = "\\?\" Then
      ShortcutTargetShortPath = Mid(ShortcutTargetShortPath, 5)
    End If

    objSC.TargetPath = ShortcutTargetShortPath
  End If
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
End If

' ShortcutWorkingDirectory

If ShortcutWorkingDirectoryExist Then
  If ExpandAllArgs Or ExpandShortcutWorkingDirectory Then
    ShortcutWorkingDirectory = objShell.ExpandEnvironmentStrings(ShortcutWorkingDirectory)
  End If

  If UnescapeAllArgs Then
    ShortcutWorkingDirectory = Unescape(ShortcutWorkingDirectory)
  End If

  Dim ShortcutWorkingDirectoryAbs : ShortcutWorkingDirectoryAbs = objFS.GetAbsolutePathName(ShortcutWorkingDirectory) ' CAUTION: can alter a path character case if path exists

  ' remove `\\?\` prefix
  If Left(ShortcutWorkingDirectoryAbs, 4) = "\\?\" Then
    ShortcutWorkingDirectoryAbs = Mid(ShortcutWorkingDirectoryAbs, 5)
  End If

  Dim IsShortcutWorkingDirectoryExist : IsShortcutWorkingDirectoryExist = False

  ' test on path existence including long path
  If objFS.FolderExists("\\?\" & ShortcutWorkingDirectoryAbs) Then
    IsShortcutWorkingDirectoryExist = True
  End If

  If Not IsShortcutWorkingDirectoryExist Then
    PrintOrEchoErrorLine _
      WScript.ScriptName & ": error: shortcut working directory does not exist:" & vbCrLf & _
      WScript.ScriptName & ": info: ShortcutWorkingDirectory=`" & ShortcutWorkingDirectoryAbs & "`"
    WScript.Quit 20
  End If

  objSC.WorkingDirectory = ShortcutWorkingDirectoryAbs
End If

If ShowAsExist Then
  objSC.WindowStyle = CInt(ShowAs)
End If

objSC.Save

' WORKAROUND:
'   WorkingDirectory does truncate after the save and close, so we must fix it after the shortcut reopen.
'   Side effects:
'     Removes machine name and other parameters from the shortcut.
'
If AllowDOSWorkingDirectory Then
  ' Set objSC = Nothing
  Set objSC = objShell.CreateShortcut(ShortcutFilePathToOpen)

  If Not LCase(objSC.WorkingDirectory) = LCase(ShortcutWorkingDirectoryAbs) Then
    ' WORKAROUND:
    '   We use `\\?\` to bypass `GetFolder` error: `Path not found`.
    Dim ShortcutWorkingDirectoryFolder : Set ShortcutWorkingDirectoryFolder = objFS.GetFolder("\\?\" & ShortcutWorkingDirectoryAbs & "\")
    Dim ShortcutWorkingDirectoryShortPath : ShortcutWorkingDirectoryShortPath = ShortcutWorkingDirectoryFolder.ShortPath
    If Left(ShortcutWorkingDirectoryShortPath, 4) = "\\?\" Then
      ShortcutWorkingDirectoryShortPath = Mid(ShortcutWorkingDirectoryShortPath, 5)
    End If

    objSC.WorkingDirectory = ShortcutWorkingDirectoryShortPath

    objSC.Save
  End If
End If
