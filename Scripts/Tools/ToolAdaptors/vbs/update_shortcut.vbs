''' Updates existing Windows shortcut file.

''' CAUTION:
'''   WScript.Shell can not handle all Unicode characters in path properties, including characters in the path to a shortcut file.
'''   Details: https://stackoverflow.com/questions/39365489/how-do-you-keep-diacritics-in-shortcut-paths
'''

''' USAGE:
'''   update_shortcut.vbs
'''     [-CD <CurrentDirectoryPath>]
'''     [-showas <ShowWindowAsNumber>]
'''     [-no-backup] [-backup-dir] [-ignore-unexist]
'''     [-allow-target-path-reassign] [-allow-wd-reassign] [-allow-paths-reassign]
'''     [-allow-dos-current-dir] [-allow-dos-target-path] [-allow-dos-wd] [-allow-dos-paths]
'''     [-p[rint-assign]] [-print-assigned | -pd]
'''     [-u] [-q]
'''     [-E[0 | t | a | wd]]
'''     [-use-getlink | -g] [-print-remapped-names | -k]
'''     [-t <ShortcutTarget>]
'''     [-t-suffix <ShortcutTargetSuffix>]
'''     [-args <ShortcutTargetArgs>]
'''     [-wd <ShortcutWorkingDirectory>]
'''     [--]
'''       <ShortcutFilePath>

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
'''     file and in the same time does backup each shortcut in each call.
'''
'''   -backup-dir
'''     Path to the directory to store backed up shortcuts. Used instead of
'''     generated one, for example, in case of an external script call from a
'''     loop.
'''     Has no effect if directory does not exist.
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
'''   -allow-target-path-reassign
'''     Allows `TargetPath` property reassign if path is case insensitively
'''     equal.
'''     Has no effect if path does not exist.
'''   -allow-wd-reassign
'''     Allows `WorkingDirectory` property reassign if path is case
'''     insensitively equal.
'''     Has no effect if path does not exist.
'''   -allow-paths-reassign
'''     Implies all `-allow-*-reassign` flags.
'''
'''   -allow-dos-current-dir
'''     Allows long path conversion into a reduced DOS path version for the
'''     current directory.
'''     Has no effect if path does not exist.
'''   -allow-dos-target-path
'''     Rereads target path after assign and if is not changed, then reassigns
'''     it by a reduced DOS path version.
'''     It is useful when you want to create not truncated shortcut target file
'''     path to open it by an old version application which does not support
'''     long paths or Win32 Namespace paths, but supports open target paths by
'''     a shortcut file.
'''     Has no effect if path does not exist.
'''   -allow-dos-wd
'''     Rereads working directory after assign and if is not changed, then
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
'''   make_shortcut.bat -obj mycomputer.lnk
''' Or
'''   >
'''   del /F /Q mycomputer.lnk
'''   make_shortcut.bat -obj mycomputer.lnk "shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"

''' Example to create MTP device folder shortcut:
'''   >
'''   del /F /Q mycomputer.lnk
'''   make_shortcut.bat -obj mycomputer.lnk "shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\\\?\usb#vid_0e8d&pid_201d&mi_00#7&1084e14&0&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}"
'''
'''   , where the `\\?\usb#vid_0e8d&pid_201d&mi_00#7&1084e14&0&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}` might be different for each device
'''
'''   See details: https://stackoverflow.com/questions/39397348/open-folder-on-portable-device-with-batch-file/65997169#65997169

''' Example to create the Master Control Panel link or directory on the Desktop
'''   >
'''   make_shortcut.bat -obj "%USERPROFILE%\Desktop\GodMode.lnk" "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}"
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

''' Related resources:
'''   https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-shllink
'''   https://github.com/libyal/liblnk/blob/main/documentation/Windows%20Shortcut%20File%20(LNK)%20format.asciidoc

''' CAUTION:
'''   Base `CreateShortcut` method does not support all Unicode characters nor
'''   `search-ms` Windows Explorer moniker path for the filter field.
'''   Use `GetLink` property (`-use-getlink` flag) instead to workaround that.

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

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim PrintAssign : PrintAssign = False
Dim PrintAssigned : PrintAssigned = False

Dim BackupShortcut : BackupShortcut = True
Dim BackupDir : BackupDir = ""

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
Dim AllowPathsReassign : AllowPathsReassign = False

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
      ElseIf arg = "-ignore-unexist" Then
       IgnoreUnexist = True
      ElseIf arg = "-print-assign" Or arg = "-p" Then ' Print assign
        PrintAssign = True
      ElseIf arg = "-print-assigned" Or arg = "-pd" Then ' Print assigned
        PrintAssigned = True
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
      ElseIf arg = "-use-getlink" Or arg = "-g" Then
        UseGetLink = True
      ElseIf arg = "-print-remapped-names" Or arg = "-k" Then
        PrintRemappedNames = True
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
      ElseIf arg = "-allow-paths-reassign" Then ' Allow path properties reassign
        AllowPathsReassign = True
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

If IsEmptyArg(cmd_args, 0) Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <ShortcutFilePath> argument is not defined."
  WScript.Quit 255
End If

If AllowPathsReassign Then
  AllowTargetPathReassign = AllowPathsReassign
  AllowWorkingDirectoryReassign = AllowPathsReassign
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

Function GetShortcutPropertyName(PropertyName)
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

  GetShortcutPropertyName = PropertyName_
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

Function GetExistedShortPath(PathAbs, AsFile)
  If AsFile Then
    GetExistedShortPath = GetExistedFileShortPath(PathAbs)
  Else
    GetExistedShortPath = GetExistedFolderShortPath(PathAbs)
  End If
End Function

Function IsPathExists(Path)
  If objFS.FileExists(Path) Or objFS.FolderExists(Path) Then
    IsPathExists = True
  Else
    IsPathExists = False
  End If
End Function

Function IsPathAbsolute(Path)
  If Left(Path, 1) = "\" Or Mid(Path, 2, 2) = ":\" Then
    IsPathAbsolute = True
  Else
    IsPathAbsolute = False
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
  Dim IsCurrentDirectoryExist : IsCurrentDirectoryExist = objFS.FolderExists("\\?\" & ChangeCurrentDirectoryAbs)
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
  Else
    ' translate into short path
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

' ShortcutTarget validate

Dim ShortcutTargetUnquotedAbs
Dim IsShortcutTargetPathExist : IsShortcutTargetPathExist = False
Dim IsShortcutTargetPathExistAsFile : IsShortcutTargetPathExistAsFile = False

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

  If objFS.FileExists("\\?\" & ShortcutTargetUnquotedAbs) Then
    IsShortcutTargetPathExist = True
    IsShortcutTargetPathExistAsFile = True
  ElseIf (Len(ShortcutTargetSuffix) > 0) And objFS.FileExists("\\?\" & ShortcutTargetUnquotedAbs & ShortcutTargetSuffix) Then
    ShortcutTargetUnquotedAbs = ShortcutTargetUnquotedAbs & ShortcutTargetSuffix
    IsShortcutTargetPathExist = True
    IsShortcutTargetPathExistAsFile = True
  ElseIf objFS.FolderExists("\\?\" & ShortcutTargetUnquotedAbs) Then
    IsShortcutTargetPathExist = True
  ElseIf (Len(ShortcutTargetSuffix) > 0) And objFS.FolderExists("\\?\" & ShortcutTargetUnquotedAbs & ShortcutTargetSuffix) Then
    ShortcutTargetUnquotedAbs = ShortcutTargetUnquotedAbs & ShortcutTargetSuffix
    IsShortcutTargetPathExist = True
  End If

  If (Not IgnoreUnexist) And Not IsShortcutTargetPathExist Then
    PrintOrEchoErrorLine _
      WScript.ScriptName & ": error: shortcut target path does not exist:" & vbCrLf & _
      WScript.ScriptName & ": info: ShortcutTarget=`" & ShortcutTargetUnquotedAbs & "`"
    WScript.Quit 30
  End If

  If Not AlwaysQuote Then
    ShortcutTarget = ShortcutTargetUnquotedAbs
  Else
    ShortcutTarget = Chr(34) & ShortcutTargetUnquotedAbs & Chr(34)
  End If
End If

' ShortcutWorkingDirectory validate

Dim ShortcutWorkingDirectoryAbs
Dim IsShortcutWorkingDirectoryExist : IsShortcutWorkingDirectoryExist = False

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

  If objFS.FolderExists("\\?\" & ShortcutWorkingDirectoryAbs) Then
    IsShortcutWorkingDirectoryExist = True
  End If

  If (Not IgnoreUnexist) And Not IsShortcutWorkingDirectoryExist Then
    PrintOrEchoErrorLine _
      WScript.ScriptName & ": error: shortcut working directory does not exist:" & vbCrLf & _
      WScript.ScriptName & ": info: ShortcutWorkingDirectory=`" & ShortcutWorkingDirectoryAbs & "`"
    WScript.Quit 20
  End If
End If

Dim ShortcutFilePathToOpen

' test on long path existence
If objFS.FileExists(ShortcutFilePathAbs) Then
  ' is not long path
  ShortcutFilePathToOpen = ShortcutFilePathAbs
Else
  ' translate into short path
  ShortcutFilePathToOpen = GetExistedFileShortPath(ShortcutFilePathAbs)
End If

Dim objSC : Set objSC = GetShortcut(ShortcutFilePathToOpen)

Dim ShortcutUpdated : ShortcutUpdated = False
Dim ShortcutWorkingDirectoryUpdated : ShortcutWorkingDirectoryUpdated = False

' ShortcutTarget assign

Dim ShortcutTargetPrev : ShortcutTargetPrev = GetShortcutProperty("TargetPath")

If ShortcutTargetExist Then
Do ' empty `Do-Loop` to emulate `Break`
  Dim ShortcutTargetUnquotedAbsLCase : ShortcutTargetUnquotedAbsLCase = LCase(ShortcutTargetUnquotedAbs)

  If Not AllowTargetPathReassign Then
    If LCase(ShortcutTargetPrev) = ShortcutTargetUnquotedAbsLCase Then
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": warning: property `" & GetShortcutPropertyName("TargetPath") & "` has nocase equal path."
      Exit Do
    End If
  End If

  If PrintAssign Then
    PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "=" & ShortcutTargetUnquotedAbs
  End If

  SetShortcutProperty "TargetPath", ShortcutTarget
  ShortcutUpdated = True

  ' reread `TargetPath`
  ShortcutTarget = GetShortcutProperty("TargetPath")

  If PrintAssigned Then
    If Not (LCase(ShortcutTargetPrev) = ShortcutTargetUnquotedAbsLCase) Then
      PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(assigned)=" & ShortcutTarget
    Else
      PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(reassigned)=" & ShortcutTarget
    End If
  End If

  If AllowDOSTargetPath Then
    Dim ShortcutTargetLCase : ShortcutTargetLCase = LCase(ShortcutTarget)

    If ShortcutTargetLCase = ShortcutTargetUnquotedAbsLCase Then
      Exit Do
    End If

    If IsShortcutTargetPathExist Then
      Dim ShortcutTargetShortPath : ShortcutTargetShortPath = GetExistedShortPath(ShortcutTargetUnquotedAbs, IsShortcutTargetPathExistAsFile)

      If Not AllowTargetPathReassign Then
        If ShortcutTargetLCase = LCase(ShortcutTargetShortPath) Then
          PrintOrEchoErrorLine _
            WScript.ScriptName & ": warning: property `" & GetShortcutPropertyName("TargetPath") & "` has nocase equal path."
          Exit Do
        End If
      End If

      If PrintAssign Then
        PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(short)=" & ShortcutTargetShortPath
      End If

      If Not AlwaysQuote Then
        ShortcutTarget = ShortcutTargetShortPath
      Else
        ShortcutTarget = Chr(34) & ShortcutTargetShortPath & Chr(34)
      End If

      SetShortcutProperty "TargetPath", ShortcutTarget

      ' reread `TargetPath`
      ShortcutTarget = GetShortcutProperty("TargetPath")

      If PrintAssigned Then
        If Not (ShortcutTargetLCase = LCase(ShortcutTargetShortPath)) Then
          PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(assigned)=" & ShortcutTarget
        Else
          PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(reassigned)=" & ShortcutTarget
        End If
      End If
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

  If PrintAssign Then
    PrintOrEchoLine GetShortcutPropertyName("Arguments") & "=" & ShortcutTargetArgs
  End If

  SetShortcutProperty "Arguments", ShortcutTargetArgs
  ShortcutUpdated = True
End If

' ShortcutWorkingDirectory assign

Dim ShortcutWorkingDirectoryPrev : ShortcutWorkingDirectoryPrev = GetShortcutProperty("WorkingDirectory")

Dim ShortcutWorkingDirectoryAbsLCase
Dim ShortcutWorkingDirectoryLCase
Dim ShortcutWorkingDirectoryShortPath

If ShortcutWorkingDirectoryExist Then
Do ' empty `Do-Loop` to emulate `Break`
  ShortcutWorkingDirectoryAbsLCase = LCase(ShortcutWorkingDirectoryAbs)

  If Not AllowWorkingDirectoryReassign Then
    If LCase(ShortcutWorkingDirectoryPrev) = ShortcutWorkingDirectoryAbsLCase Then
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": warning: property `" & GetShortcutPropertyName("WorkingDirectory") & "` has nocase equal path."
      Exit Do
    End If
  End If

  If PrintAssign Then
    PrintOrEchoLine GetShortcutPropertyName("WorkingDirectory") & "=" & ShortcutWorkingDirectoryAbs
  End If

  SetShortcutProperty "WorkingDirectory", ShortcutWorkingDirectoryAbs
  ShortcutWorkingDirectoryUpdated = True
  ShortcutUpdated = True

  ' reread `WorkingDirectory`
  ShortcutWorkingDirectory = GetShortcutProperty("WorkingDirectory")

  If PrintAssigned Then
    If Not (LCase(ShortcutWorkingDirectoryPrev) = ShortcutWorkingDirectoryAbsLCase) Then
      PrintOrEchoLine GetShortcutPropertyName("WorkingDirectory") & "(assigned)=" & ShortcutWorkingDirectory
    Else
      PrintOrEchoLine GetShortcutPropertyName("WorkingDirectory") & "(reassigned)=" & ShortcutWorkingDirectory
    End If
  End If

  If AllowDOSWorkingDirectory Then
    ShortcutWorkingDirectoryLCase = LCase(ShortcutWorkingDirectory)

    If ShortcutWorkingDirectoryLCase = ShortcutWorkingDirectoryAbsLCase Then
      Exit Do
    End If

    If objFS.FolderExists("\\?\" & ShortcutWorkingDirectoryAbs) Then
      ShortcutWorkingDirectoryShortPath = GetExistedFolderShortPath(ShortcutWorkingDirectoryAbs)

      If Not AllowWorkingDirectoryReassign Then
        If ShortcutWorkingDirectoryLCase = LCase(ShortcutWorkingDirectoryShortPath) Then
          PrintOrEchoErrorLine _
            WScript.ScriptName & ": warning: property `" & GetShortcutPropertyName("WorkingDirectory") & "` has nocase equal DOS path."
          Exit Do
        End If
      End If

      If PrintAssign Then
        PrintOrEchoLine GetShortcutPropertyName("WorkingDirectory") & "(short)=" & ShortcutWorkingDirectoryShortPath
      End If

      SetShortcutProperty "WorkingDirectory", ShortcutWorkingDirectoryShortPath

      ' reread `WorkingDirectory`
      ShortcutWorkingDirectory = GetShortcutProperty("WorkingDirectory")

      If PrintAssigned Then
        If Not (ShortcutWorkingDirectoryLCase = LCase(ShortcutWorkingDirectoryShortPath)) Then
          PrintOrEchoLine GetShortcutPropertyName("WorkingDirectory") & "(assigned)=" & ShortcutWorkingDirectory
        Else
          PrintOrEchoLine GetShortcutPropertyName("WorkingDirectory") & "(reassigned)=" & ShortcutWorkingDirectory
        End If
      End If
    End If
  End If
Loop While False
End If

If ShowAsExist Then
  If PrintAssign Then
    PrintOrEchoLine GetShortcutPropertyName("WindowStyle") & "=" & CInt(ShowAs)
  End If

  SetShortcutProperty "WindowStyle", CInt(ShowAs)
  ShortcutUpdated = True
End If

If ShortcutUpdated Then
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
      backup_dir_path_abs = objFS.GetAbsolutePathName(BackupDir)

      ' remove `\\?\` prefix
      If Left(backup_dir_path_abs, 4) = "\\?\" Then
        backup_dir_path_abs = Mid(backup_dir_path_abs, 5)
      End If

      If objFS.FolderExists("\\?\" & backup_dir_path_abs) Then
        ' check on absolute path
        If IsPathAbsolute(BackupDir) Then
          ShortcutFileBackupDir = backup_dir_path_abs
        Else
          ShortcutFileBackupDir = ShortcutFileDir & "\" & backup_dir_path_abs
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
End If
