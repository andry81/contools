''' Creates new Windows shortcut file.

''' CAUTION:
'''   WScript.Shell can not handle all Unicode characters in path properties, including characters in the path to a shortcut file.
'''   Details: https://stackoverflow.com/questions/39365489/how-do-you-keep-diacritics-in-shortcut-paths
'''

''' USAGE:
'''   make_shortcut.vbs
'''     [-CD <CurrentDirectoryPath>]
'''     [-obj] [-ignore-unexist] [-ignore-empty]
'''     [-showas <ShowWindowAsNumber>]
'''     [-allow-dos-current-dir] [-allow-dos-target-path] [-allow-dos-wd] [-allow-dos-paths]
'''     [-p[rint-assign]] [-print-assigned | -pd]
'''     [-u] [-q]
'''     [-E[0 | t | a | wd]]
'''     [-use-getlink | -g] [-print-remapped-names | -k]
'''     [-wd <ShortcutWorkingDirectory>]
'''     [-desc <ShortcutDescription> | -assign-target-to-desc | -dt]
'''     [--]
'''       <ShortcutFilePath> <ShortcutTarget> [<ShortcutTargetArgs>]

''' DESCRIPTION:
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''
'''   -CD <CurrentDirectoryPath>
'''     Changes current directory to <CurrentDirectoryPath> before the
'''     execution.
'''
'''   -obj
'''     By default <ShortcutTarget> does used as a file path. Use this flag to
'''     handle it as an object string and avoid path functions call on it.
'''     Can not be used together with  `-q` flag.
'''
'''   -ignore-unexist
'''     By default <ShortcutTarget> does check on existence before shortcut
'''     creation. Use this flag to skip the check.
'''     Has no effect if `-obj` flag is defined.
'''
'''   -ignore-empty
'''     By default <ShortcutTarget> does check on empty before shortcut
'''     creation. Use this flag to skip the check.
'''     Has effect if `-obj` flag is defined.
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
'''     Has no effect if `-obj` flag is defined.
'''     Has no effect if path does not exist.
'''   -allow-dos-wd
'''     Rereads working directory after assign and if it does not exist, then
'''     reassigns it by a reduced DOS path version.
'''     Has no effect if path does not exist.
'''   -allow-dos-paths
'''     Implies all `-allow-dos-*` flags.
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
'''     Can not be used together with  `-obj` flag.
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
'''   -use-getlink | -g
'''     Use `GetLink` property instead of `CreateShortcut` method.
'''     Alternative interface to assign path properties with Unicode
'''     characters.
'''   -print-remapped-names | -k
'''     Print remapped key names instead of `CreateShortcut` method object
'''     names.
'''     Has no effect if `-use-getlink` flag is not used.
'''
'''   -wd <ShortcutWorkingDirectory>
'''     Working directory value to assign.
'''
'''   -desc <ShortcutDescription>
'''     Description string to assign.
'''
'''   -assign-target-to-desc | -dt
'''     Use <ShortcutTarget> to assign <ShortcutDescription>.
'''     Has no effect if `-desc` option is used.

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
'''   make_shortcut.bat -obj -ignore-empty mycomputer.lnk
''' Or
'''   >
'''   del /F /Q mycomputer.lnk
'''   make_shortcut.bat -obj mycomputer.lnk "shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"

''' Example to create MTP device folder shortcut:
'''   >
'''   del /F /Q myfolder.lnk
'''   make_shortcut.bat -obj myfolder.lnk "shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\\\?\usb#vid_0e8d&pid_201d&mi_00#7&1084e14&0&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}"
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

Function NumArgs(args)
  ''' Based on: https://stackoverflow.com/questions/4466967/how-can-i-determine-if-a-dynamic-array-has-not-be-dimensioned-in-vbscript/4469121#4469121
  On Error Resume Next
  Dim args_ubound : args_ubound = UBound(args)
  If Err = 0 Then
    NumArgs = args_ubound + 1
  Else
    ' Workaround for `WScript.Arguments`
    Err.Clear
    NumArgs = args.count
    If Err <> 0 Then NumArgs = 0
  End If
  On Error Goto 0
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

Dim IgnoreUnexist : IgnoreUnexist = False
Dim IgnoreEmpty : IgnoreEmpty = False

Dim UnescapeAllArgs : UnescapeAllArgs = False

Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim ChangeCurrentDirectoryExist : ChangeCurrentDirectoryExist = False

Dim ShortcutTarget : ShortcutTarget = ""
Dim ShortcutTargetObj : ShortcutTargetObj = False
Dim ShortcutTargetUnquoted : ShortcutTargetUnquoted = "" ' CAUTION: does NOT used in case of `-obj` flag

Dim ShortcutTargetArgs : ShortcutTargetArgs = ""
Dim ShortcutTargetArgsExist : ShortcutTargetArgsExist = False

Dim ShortcutWorkingDirectory : ShortcutWorkingDirectory = ""
Dim ShortcutWorkingDirectoryUnquoted : ShortcutWorkingDirectoryUnquoted = ""
Dim ShortcutWorkingDirectoryExist : ShortcutWorkingDirectoryExist = False

Dim ShortcutDescription : ShortcutDescription = ""
Dim ShortcutDescriptionExist : ShortcutDescriptionExist = False

Dim AssignTargetToDesc : AssignTargetToDesc = False

Dim ShowAs : ShowAs = 1
Dim ShowAsExist : ShowAsExist = False

Dim ExpandAllArgs : ExpandAllArgs = False
Dim ExpandArg0 : ExpandArg0 = False
Dim ExpandShortcutTarget : ExpandShortcutTarget = False
Dim ExpandShortcutTargetArgs : ExpandShortcutTargetArgs = False
Dim ExpandShortcutWorkingDirectory : ExpandShortcutWorkingDirectory = False

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
      ElseIf arg = "-ignore-empty" Then
       IgnoreEmpty = True
      ElseIf arg = "-print-assign" Or arg = "-p" Then ' Print assign
        PrintAssign = True
      ElseIf arg = "-print-assigned" Or arg = "-pd" Then ' Print assigned
        PrintAssigned = True
      ElseIf arg = "-u" Then ' Unescape %xx or %uxxxx
        UnescapeAllArgs = True
      ElseIf arg = "-wd" Then ' Shortcut working directory
        i = i + 1
        ShortcutWorkingDirectory = WScript.Arguments(i)
        ShortcutWorkingDirectoryExist = True
      ElseIf arg = "-desc" Then ' Shortcut description
        i = i + 1
        ShortcutDescription = WScript.Arguments(i)
      ElseIf arg = "-assign-target-to-desc" Or arg = "-dt" Then ' assign ShortcutTarget to ShortcutDescription
        AssignTargetToDesc = True
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

If ShortcutTargetObj And AlwaysQuote Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: flags is mixed: -obj <-> -q"
  WScript.Quit 255
End If

Dim num_args : num_args = NumArgs(cmd_args)

If IsEmptyArg(cmd_args, 0) Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <ShortcutFilePath> argument is not defined."
  WScript.Quit 255
End If

If Not IgnoreEmpty Then
  If IsEmptyArg(cmd_args, 1) Then
    PrintOrEchoErrorLine WScript.ScriptName & ": error: <ShortcutTarget> argument is not defined."
    WScript.Quit 255
  End If
End If

If AllowDOSPaths Then
  AllowDOSCurrentDirectory = AllowDOSPaths
  AllowDOSTargetPath = AllowDOSPaths
  AllowDOSWorkingDirectory = AllowDOSPaths
End If

' functions

Dim ErrNumber, ErrSource, ErrDesc, ErrHelpFile, ErrHelpContext

Function CopyError()
  ErrNumber = Err.Number
  ErrSource = Err.Source
  ErrDesc = Err.Description
  ErrHelpFile = Err.HelpFile
  ErrHelpContext = Err.HelpContext
End Function

Function GetFile(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  If Not Left(PathAbs, 2) = "\\" Then
    Set GetFile = objFS.GetFile("\\?\" & PathAbs)
  Else
    Set GetFile = objFS.GetFile(PathAbs)
  End If
End Function

Function GetFolder(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFolder` error: `Path not found`.
  If Not Left(PathAbs, 2) = "\\" Then
    Set GetFolder = objFS.GetFolder("\\?\" & PathAbs & "\")
  Else
    Set GetFolder = objFS.GetFolder(PathAbs)
  End If
End Function

Function FileExists(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `FileExists` error: `File not found`.
  If Not Left(PathAbs, 2) = "\\" Then
    FileExists = objFS.FileExists("\\?\" & PathAbs)
  Else
    FileExists = objFS.FileExists(PathAbs)
  End If
End Function

Function FolderExists(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `FolderExists` error: `Path not found`.
  If Not Left(PathAbs, 2) = "\\" Then
    FolderExists = objFS.FolderExists("\\?\" & PathAbs & "\")
  Else
    FolderExists = objFS.FolderExists(PathAbs)
  End If
End Function

' https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/createtextfile-method
'
Function CreateTextFileEx(FilePathAbs, IsOverwrite, IsUnicode)
  If Not Left(FilePathAbs, 2) = "\\" Then
    Set CreateTextFileEx = objFS.CreateTextFile("\\?\" & FilePathAbs, IsOverwrite, IsUnicode)
  Else
    Set CreateTextFileEx = objFS.CreateTextFile(FilePathAbs, IsOverwrite, IsUnicode)
  End If
End Function

Function RemoveWin32NamespacePathPrefix(PathAbs)
  ' CAUTION:
  '   Avoid to remove other path prefixes started by `\\`:
  '     * UNC: \\domain...
  '     * Volume: \\?\Volume{...
  '
  If Left(PathAbs, 4) = "\\?\" And Mid(PathAbs, 6, 1) = ":" Then
    RemoveWin32NamespacePathPrefix = Mid(RemoveWin32NamespacePathPrefix, 5)
  Else
    RemoveWin32NamespacePathPrefix = PathAbs
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

Function CreateTextFile(FilePathAbs)
  Set CreateTextFile = CreateTextFileEx(FilePathAbs, True, False)
End Function

Function DeleteFile(FilePathAbs)
  If Not Left(FilePathAbs, 2) = "\\" Then
    objFS.DeleteFile("\\?\" & FilePathAbs)
  Else
    objFS.DeleteFile(FilePathAbs)
  End If
End Function

Function DeleteFileEx(FilePathAbs)
  If objFS.FileExists(FilePathAbs) Then
    ' is not long path
    DeleteFile(FilePathAbs)
  Else
    ' translate into short path
    Dim FileShortPath : FileShortPath = GetExistedFileShortPath(FilePathAbs)

    DeleteFile(FileShortPath)
  End If
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

Function GetShortcut(ShortcutFilePathToOpen)
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
End Function

Function MakeShortcut(ShortcutFilePathToOpen)
  If Not UseGetLink Then
    ' CAUTION:
    '   Base `CreateShortcut` method does not support all Unicode characters.
    '   Use `GetLink` property (`-use-getlink` flag) instead to workaround that.
    '
    Set MakeShortcut = objShell.CreateShortcut(ShortcutFilePathToOpen)
  Else
    ' NOTE:
    '   The `ParseName` still requires a shortcut file existence, but `CreateShortcut` can not handle unknown unicode characters in the path.
    '   Use empty shortcut binary file to open it through `ShellLinkObject` interface.

    Dim EmptyLnk : EmptyLnk = "4C0000000114020000000000C000000000000046800000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000"

    ' create empty shortcut to open in `ParseName`
    Dim objSCFile : Set objSCFile = CreateTextFileEx(ShortcutFilePathToOpen, True, False)

    Dim i
    For i = 1 To Len(EmptyLnk) Step 2
      objSCFile.Write Chr(CLng("&H" & Mid(EmptyLnk, i, 2)))
    Next

    objSCFile.Close
    Set objSCFile = Nothing

    Set MakeShortcut = GetShortcut(ShortcutFilePathToOpen)
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

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

' change current directory before any file system request because of relative paths
If ChangeCurrentDirectoryExist Then
  Dim ChangeCurrentDirectoryAbs : ChangeCurrentDirectoryAbs = objFS.GetAbsolutePathName(ChangeCurrentDirectory) ' CAUTION: can alter a path character case if path exists

  ' remove `\\?\` Win32 Namespace prefix
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
  If (Not AllowDOSCurrentDirectory) Or objFS.FolderExists(ChangeCurrentDirectoryAbs) Then
    ' is not long path
    objShell.CurrentDirectory = ChangeCurrentDirectoryAbs
  ElseIf AllowDOSCurrentDirectory Then
    ' translate into short path
    objShell.CurrentDirectory = GetExistedFolderShortPath(ChangeCurrentDirectoryAbs)
  End If
End If

Dim ShortcutFilePath : ShortcutFilePath = cmd_args(0)

Dim ShortcutFilePathAbs : ShortcutFilePathAbs = objFS.GetAbsolutePathName(ShortcutFilePath) ' CAUTION: can alter a path character case if path exists

' remove `\\?\` Win32 Namespace prefix
ShortcutFilePathAbs = RemoveWin32NamespacePathPrefix(ShortcutFilePathAbs)

' test on path existence including long path
Dim IsShortcutFileExist : IsShortcutFileExist = FileExists(ShortcutFilePathAbs)
If IsShortcutFileExist Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: shortcut file must not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: ShortcutFilePath=`" & ShortcutFilePathAbs & "`"
  WScript.Quit 10
End If

Dim ShortcutFileDir : ShortcutFileDir = objFS.GetParentFolderName(ShortcutFilePathAbs)
Dim IsShortcutFileDirExist : IsShortcutFileDirExist = FolderExists(ShortcutFileDir)
If Not IsShortcutFileDirExist Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: shortcut file directory must exist:" & vbCrLf & _
    WScript.ScriptName & ": info: ShortcutFileDir=`" & ShortcutFileDir & "`"
  WScript.Quit 20
End If

If Not IsEmptyArg(cmd_args, 1) Then
  ShortcutTarget = cmd_args(1)
End If

If num_args > 2 Then
  ShortcutTargetArgs = cmd_args(2)
  ShortcutTargetArgsExist = True
End If

Dim ShortcutWorkingDirectoryUpdated : ShortcutWorkingDirectoryUpdated = False

' ShortcutTarget validate

If ExpandAllArgs Or ExpandShortcutTarget Then
  ShortcutTarget = objShell.ExpandEnvironmentStrings(ShortcutTarget)
End If

If UnescapeAllArgs Then
  ShortcutTarget = Unescape(ShortcutTarget)
End If

Dim ShortcutTargetUnquotedAbs ' CAUTION: used as an object string (not unquoted nor absolute) in case of `-obj` flag

If Not ShortcutTargetObj Then
  If Len(ShortcutTarget) > 1 And Left(ShortcutTarget, 1) = Chr(34) And Right(ShortcutTarget, 1) = Chr(34) Then
    ShortcutTargetUnquoted = Mid(ShortcutTarget, 2, Len(ShortcutTarget) - 2)
  Else
    ShortcutTargetUnquoted = ShortcutTarget
  End If

  ShortcutTargetUnquotedAbs = objFS.GetAbsolutePathName(ShortcutTargetUnquoted) ' CAUTION: can alter a path character case if path exists

  ' remove `\\?\` Win32 Namespace prefix
  ShortcutTargetUnquotedAbs = RemoveWin32NamespacePathPrefix(ShortcutTargetUnquotedAbs)

  If Not IgnoreUnexist Then
    Dim IsShortcutTargetPathExist : IsShortcutTargetPathExist = False

    ' test on path existence including long path
    If FileExists(ShortcutTargetUnquotedAbs) Then
      IsShortcutTargetPathExist = True
    ElseIf FolderExists(ShortcutTargetUnquotedAbs) Then
      IsShortcutTargetPathExist = True
    End If

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
Else
  ShortcutTargetUnquotedAbs = ShortcutTarget ' CAUTION: is not unquoted because is not a file path
End If

Dim ShortcutFilePathToOpen

' test on long path existence by temporary empty text file
Dim ShortcutEmptyFile : Set ShortcutEmptyFile = CreateTextFile(ShortcutFilePathAbs)
' close handle immediately to be able to delete the file later
ShortcutEmptyFile.Close()
Set ShortcutEmptyFile = Nothing

If FileExists(ShortcutFilePathAbs) Then
  ' is not long path
  DeleteFile(ShortcutFilePathAbs)
  ShortcutFilePathToOpen = ShortcutFilePathAbs
Else
  ' translate into short path
  Dim ShortcutFileShortPath : ShortcutFileShortPath = GetExistedFileShortPath(ShortcutFilePathAbs)

  DeleteFile(ShortcutFilePathAbs)

  ' construct path from short path parent directory and long path file name
  ShortcutFilePathToOpen = objFS.GetParentFolderName(ShortcutFileShortPath) & "\" & objFS.GetFileName(ShortcutFilePathAbs)
End If

Dim objSC

On Error Resume Next
Set objSC = MakeShortcut(ShortcutFilePathToOpen)
If err <> 0 Then
  CopyError()

  ' Remove shortcut if created from a template file
  If UseGetLink Then
    DeleteFileEx(ShortcutFilePathToOpen)
  End If

  On Error Goto 0
  err.Raise ErrNumber, ErrSource, ErrDesc, ErrHelpFile, ErrHelpContext
End If
On Error Goto 0

' ShortcutTarget

If PrintAssign Then
  PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "=" & ShortcutTargetUnquotedAbs
End If

SetShortcutProperty "TargetPath", ShortcutTarget

' reread `TargetPath`
ShortcutTarget = GetShortcutProperty("TargetPath")

If PrintAssigned Then
  PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(assigned)=" & ShortcutTarget
End If

If (Not ShortcutTargetObj) And AllowDOSTargetPath Then
Do ' empty `Do-Loop` to emulate `Break`
  Dim ShortcutTargetLCase : ShortcutTargetLCase = LCase(ShortcutTarget)

  ' including invalid unicode characters fix
  If ShortcutTargetLCase = LCase(ShortcutTargetUnquotedAbs) Then ' Or ShortcutTargetLCase = LCase(FixStrToPrint(ShortcutTargetUnquotedAbs)) Then
    Exit Do
  End If

  Dim ShortcutTargetShortPath : ShortcutTargetShortPath = GetShortPath(ShortcutTargetUnquotedAbs)

  If Not (Len(ShortcutTargetShortPath) > 0) Or ShortcutTargetLCase = LCase(ShortcutTargetShortPath) Then
    Exit Do
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
    PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(assigned)=" & ShortcutTarget
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
    PrintOrEchoLine GetShortcutPropertyName("TargetArgs") & "=" & ShortcutTargetArgs
  End If

  SetShortcutProperty "Arguments", ShortcutTargetArgs
End If

' ShortcutWorkingDirectory

Dim ShortcutWorkingDirectoryAbsLCase
Dim ShortcutWorkingDirectoryLCase
Dim ShortcutWorkingDirectoryShortPath

If ShortcutWorkingDirectoryExist Then
Do ' empty `Do-Loop` to emulate `Break`
  If ExpandAllArgs Or ExpandShortcutWorkingDirectory Then
    ShortcutWorkingDirectory = objShell.ExpandEnvironmentStrings(ShortcutWorkingDirectory)
  End If

  If UnescapeAllArgs Then
    ShortcutWorkingDirectory = Unescape(ShortcutWorkingDirectory)
  End If

  Dim ShortcutWorkingDirectoryAbs : ShortcutWorkingDirectoryAbs = objFS.GetAbsolutePathName(ShortcutWorkingDirectory) ' CAUTION: can alter a path character case if path exists

  ' remove `\\?\` Win32 Namespace prefix
  ShortcutWorkingDirectoryAbs = RemoveWin32NamespacePathPrefix(ShortcutWorkingDirectoryAbs)

  Dim IsShortcutWorkingDirectoryExist : IsShortcutWorkingDirectoryExist = False

  ' test on path existence including long path
  If FolderExists(ShortcutWorkingDirectoryAbs) Then
    IsShortcutWorkingDirectoryExist = True
  End If

  If Not IsShortcutWorkingDirectoryExist Then
    PrintOrEchoErrorLine _
      WScript.ScriptName & ": error: shortcut working directory does not exist:" & vbCrLf & _
      WScript.ScriptName & ": info: ShortcutWorkingDirectory=`" & ShortcutWorkingDirectoryAbs & "`"
    WScript.Quit 40
  End If

  ShortcutWorkingDirectoryAbsLCase = LCase(ShortcutWorkingDirectoryAbs)

  If PrintAssign Then
    PrintOrEchoLine GetShortcutPropertyName("WorkingDirectory") & "=" & ShortcutWorkingDirectoryAbs
  End If

  SetShortcutProperty "WorkingDirectory", ShortcutWorkingDirectoryAbs
  ShortcutWorkingDirectoryUpdated = True

  ' reread `WorkingDirectory`
  ShortcutWorkingDirectory = GetShortcutProperty("WorkingDirectory")

  If PrintAssigned Then
    PrintOrEchoLine GetShortcutPropertyName("WorkingDirectory") & "(assigned)=" & ShortcutWorkingDirectory
  End If

  If AllowDOSWorkingDirectory Then
    ShortcutWorkingDirectoryLCase = LCase(ShortcutWorkingDirectory)

    ' including invalid unicode characters fix
    If ShortcutWorkingDirectoryLCase = ShortcutWorkingDirectoryAbsLCase Then ' Or ShortcutWorkingDirectoryLCase = LCase(FixStrToPrint(ShortcutWorkingDirectory)) Then
      Exit Do
    End If

    ShortcutWorkingDirectoryShortPath = GetExistedFolderShortPath(ShortcutWorkingDirectoryAbs)

    If ShortcutWorkingDirectoryLCase = LCase(ShortcutWorkingDirectoryShortPath) Then
      Exit Do
    End If

    If PrintAssign Then
      PrintOrEchoLine GetShortcutPropertyName("WorkingDirectory") & "(short)=" & ShortcutWorkingDirectoryShortPath
    End If

    SetShortcutProperty "WorkingDirectory", ShortcutWorkingDirectoryShortPath

    ' reread `WorkingDirectory`
    ShortcutWorkingDirectory = GetShortcutProperty("WorkingDirectory")

    If PrintAssigned Then
      PrintOrEchoLine GetShortcutPropertyName("WorkingDirectory") & "(assigned)=" & ShortcutWorkingDirectory
    End If
  End If
Loop While False
End If

' ShortcutDescription

If (Not ShortcutDescriptionExist) And AssignTargetToDesc Then
  ShortcutDescription = ShortcutTargetUnquotedAbs
  ShortcutDescriptionExist = True
End If

If ShortcutDescriptionExist Then
Do ' empty `Do-Loop` to emulate `Break`
  If PrintAssign Then
    PrintOrEchoLine GetShortcutPropertyName("Description") & "=" & ShortcutDescription
  End If

  SetShortcutProperty "Description", ShortcutDescription

  ' reread `Description`
  ShortcutDescription = GetShortcutProperty("Description")

  If PrintAssigned Then
    PrintOrEchoLine GetShortcutPropertyName("Description") & "(assigned)=" & ShortcutDescription
  End If
Loop While False
End If

If ShowAsExist Then
  SetShortcutProperty "WindowStyle", CInt(ShowAs)
End If

objSC.Save
