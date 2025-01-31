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
'''     By default the target path does used as a file path. Use this flag to
'''     handle it as an object string and reduce (but not avoid) path functions
'''     call on it.
'''     Can not be used together with  `-q` flag.
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
'''   -reset-wd[-from-target-path]
'''     Reset WorkingDirectory from TargetPath.
'''     Does not apply if TargetPath is empty.
'''     Has effect if `-obj` flag is used.
'''   -reset-target-path-from-wd
'''     Reset TargetPath from WorkingDirectory leaving the file name as is.
'''     Does not apply if WorkingDirectory or TargetPath is empty.
'''     Has effect if `-obj` flag is used.
'''   -reset-target-path-from-desc
'''     Reset TargetPath from Description.
'''     Does not apply if Description is empty or not a path.
'''     Has no effect if TargetPath is already resetted.
'''     Has effect if `-obj` flag is used.
'''   -reset-target-name-from-file-path
'''     Reset TargetPath name from shortcut file name without `.lnk` extension.
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
    ' is not long path
    objShell.CurrentDirectory = ChangeCurrentDirectoryAbs
  ElseIf AllowDOSCurrentDirectory Then
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
  If ShortcutTargetEmpty Then
    PrintOrEchoErrorLine WScript.ScriptName & ": error: shortcut target path is empty."
    WScript.Quit 10
  End If

  If ShortcutWorkingDirectoryEmpty Then
    PrintOrEchoErrorLine WScript.ScriptName & ": error: shortcut working directory path is empty."
    WScript.Quit 11
  End If

  If Not ShortcutTargetEmpty Then
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
End If

' 3

If ResetTargetPathFromDesc And (Not ShortcutTargetAssigned) Then
  If (Not ShortcutDescEmpty) And ShortcutDescExist Then
    ShortcutTargetToAssign = ShortcutDescUnquoted

    If Not IgnoreUnexist Then
      ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

      If Not ShortcutTargetToAssignExist Then
        PrintOrEchoErrorLine _
          WScript.ScriptName & ": error: shortcut desciprion as path to assign does not exist:" & vbCrLf & _
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
  If PrintAssign Then
    PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "=" & ShortcutTargetToAssign
  End If

  If AlwaysQuote And InStr(ShortcutTargetToAssign, Chr(34)) = 0 Then
    ShortcutTargetToAssign = Chr(34) & ShortcutTargetToAssign & Chr(34)
  End If

  SetShortcutProperty "TargetPath", ShortcutTargetToAssign

  ' reread `TargetPath`
  ShortcutTarget = GetShortcutProperty("TargetPath")

  If PrintAssigned Then
    PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(assigned)=" & ShortcutTarget
  End If
ElseIf AllowTargetPathReassign Then
  If Not ShortcutTargetObj Then
    If ShortcutTargetExist Or IgnoreUnexist Then
      If PrintAssign Then
        PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(reassign)=" & ShortcutTargetUnquoted
      End If

      SetShortcutProperty "TargetPath", ShortcutTarget ' reassign
      ShortcutTargetAssigned = True

      ' reread `TargetPath`
      ShortcutTarget = GetShortcutProperty("TargetPath")

      If PrintAssigned Then
        PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(reassigned)=" & ShortcutTarget
      End If
    End If
  Else
    If PrintAssign Then
      PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(reassign)=" & ShortcutTarget
    End If

    SetShortcutProperty "TargetPath", ShortcutTarget ' reassign
    ShortcutTargetAssigned = True

    ' reread `TargetPath`
    ShortcutTarget = GetShortcutProperty("TargetPath")

    If PrintAssigned Then
      PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(reassigned)=" & ShortcutTarget
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
      PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(short)=" & ShortcutTargetShortPath
    End If

    SetShortcutProperty "TargetPath", ShortcutTargetShortPath

    ' reread `TargetPath`
    ShortcutTarget = GetShortcutProperty("TargetPath")

    If PrintAssigned Then
      PrintOrEchoLine GetShortcutPropertyName("TargetPath") & "(assigned)=" & ShortcutTarget
    End If
  End If
End If

If ShortcutWorkingDirectoryAssigned Then
  If PrintAssign Then
    PrintOrEchoLine GetShortcutPropertyName("WorkingDirectory") & "=" & ShortcutWorkingDirectoryToAssign
  End If

  SetShortcutProperty "WorkingDirectory", ShortcutWorkingDirectoryToAssign

  ' reread `WorkingDirectory`
  ShortcutWorkingDirectory = GetShortcutProperty("WorkingDirectory")

  If PrintAssigned Then
    PrintOrEchoLine GetShortcutPropertyName("WorkingDirectory") & "(assigned)=" & ShortcutWorkingDirectory
  End If

  If AllowDOSWorkingDirectory Then
    Dim ShortcutWorkingDirectoryAbs : ShortcutWorkingDirectoryAbs = objFS.GetAbsolutePathName(ShortcutWorkingDirectory)

    Dim ShortcutWorkingDirectoryShortPath : ShortcutWorkingDirectoryShortPath = ""

    If Not objFS.FolderExists(ShortcutWorkingDirectory) Then
      ShortcutWorkingDirectoryShortPath = GetFolderShortPath(ShortcutWorkingDirectory)
    End If

    If Len(ShortcutWorkingDirectoryShortPath) > 0 Then
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
  End If
End If

objSC.Save
