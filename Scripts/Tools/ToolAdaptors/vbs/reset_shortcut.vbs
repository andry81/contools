''' Resets the Windows shortcut file.

''' CAUTION:
'''   WScript.Shell can not handle all Unicode characters in path properties, including characters in the path to a shortcut file.
'''   Details: https://stackoverflow.com/questions/39365489/how-do-you-keep-diacritics-in-shortcut-paths
'''

''' USAGE:
'''   reset_shortcut.vbs [-CD <CurrentDirectoryPath>]
'''     [-ignore-unexist]
'''     [-reset-wd[-from-target-path]]
'''     [-reset-target-path-from-wd]
'''     [-reset-target-path-from-desc]
'''     [-reset-target-name-from-file-path]
'''     [-reset-target-drive-from-file-path]
'''     [-allow-auto-recover]
'''     [-allow-target-path-reassign]
'''     [-allow-wd-reassign]
'''     [-p[rint-assing]] [-q] [--]
'''     <ShortcutFilePath>

''' DESCRIPTION:
'''   By default resaves shortcut which does trigger the Windows Shell
'''   component to validate the path and rewrites the shortcut file even if
'''   nothing is changed reducing the shortcut content.
'''   Does not apply if TargetPath does not exist and `-ignore-unexist`
'''   option is not used, to avoid a shortcut accident corruption by the
'''   Windows Shell component internal guess logic (see `-ignore-unexist`
'''   option description).
'''   Has no effect if TargetPath is already changed using `-reset-*` flags or
'''   by any other reset.
'''
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''   -CD <CurrentDirectoryPath>
'''     Changes current directory to <CurrentDirectoryPath> before the
'''     execution.
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
'''   -reset-wd[-from-target-path]
'''     Reset WorkingDirectory from TargetPath.
'''     Does not apply if TargetPath is empty.
'''   -reset-target-path-from-wd
'''     Reset TargetPath from WorkingDirectory leaving the file name as is.
'''     Does not apply if WorkingDirectory or TargetPath is empty.
'''   -reset-target-path-from-desc
'''     Reset TargetPath from Description.
'''     Does not apply if Description is empty or not a path.
'''     Has no effect if TargetPath is already resetted.
'''   -reset-target-name-from-file-path
'''     Reset TargetPath name from shortcut file name without `.lnk` extension.
'''   -reset-target-drive-from-file-path
'''     Reset TargetPath drive from shortcut file drive.
'''
'''   -allow-auto-recover
'''     Allow auto recover by using the guess logic appling in this order:
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
'''   -allow-target-path-reassign
'''     Allow TargetPath reassign if not been assigned.
'''     Has no effect if TargetPath is already resetted.
'''   -allow-wd-reassign
'''     Allow WorkingDirectory reassign if not been assigned.
'''     Has no effect if WorkingDirectory is already resetted.
'''
'''   -p[rint-assign]
'''     Print assign.
'''   -q
'''     Always quote target path argument if has no quote characters.

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

Dim ResetWorkingDirFromTargetPath : ResetWorkingDirFromTargetPath = False
Dim ResetTargetPathFromWorkingDir : ResetTargetPathFromWorkingDir = False
Dim ResetTargetPathFromDesc : ResetTargetPathFromDesc = False
Dim ResetTargetNameFromFilePath : ResetTargetNameFromFilePath = False
Dim ResetTargetDriveFromFilePath : ResetTargetDriveFromFilePath = False

Dim AllowAutoRecover : AllowAutoRecover = False
Dim AllowTargetPathReassign : AllowTargetPathReassign = False
Dim AllowWorkingDirectoryReassign : AllowWorkingDirectoryReassign = False

Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim ChangeCurrentDirectoryExist : ChangeCurrentDirectoryExist = False

Dim ShortcutFilePath : ShortcutFilePath = ""

Dim ShortcutTarget : ShortcutTarget = ""
Dim ShortcutTargetUnquoted : ShortcutTargetUnquoted = ""
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

Dim objShell : Set objShell = WScript.CreateObject("WScript.Shell")

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Left(arg, 1) = "-" Then
      If arg = "-ignore-unexist" Then
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
      ElseIf arg = "-allow-wd-reassign" Then
        AllowWorkingDirectoryReassign = True
      ElseIf arg = "-print-assign" Or arg = "-p" Then ' Print assign
        PrintAssign = True
      ElseIf arg = "-CD" Then ' Change current directory
        i = i + 1
        ChangeCurrentDirectory = WScript.Arguments(i)
        ChangeCurrentDirectoryExist = True
      ElseIf arg = "-q" Then ' Always quote target path property if has no quote characters
        AlwaysQuote = True
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

If IgnoreUnexist And AllowAutoRecover Then
  WScript.Echo WScript.ScriptName & ": error: flags is mixed: -ignore-unexist <-> -allow-auto-recover"
  WScript.Quit 255
End If

ShortcutFilePath = cmd_args(0)

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

Dim ShortcutFileExist : ShortcutFileExist = objFS.FileExists(ShortcutFilePath)

If Not ShortcutFileExist Then
  WScript.Echo _
    WScript.ScriptName & ": error: shortcut path does not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: ShortcutFilePath=`" & ShortcutFilePath & "`"
  WScript.Quit 1
End If

If ChangeCurrentDirectoryExist Then
  objShell.CurrentDirectory = ChangeCurrentDirectory
End If

Dim objSC : Set objSC = objShell.CreateShortcut(ShortcutFilePath)

' read TargetPath unconditionally

ShortcutTarget = objSC.TargetPath

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

ShortcutWorkingDirectory = objSC.WorkingDirectory

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
  ShortcutDesc = objSC.Description

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
          WScript.Echo _
            WScript.ScriptName & ": error: shortcut working directory to assign does not exist:" & vbCrLf & _
            WScript.ScriptName & ": info: WorkingDirectory=`" & ShortcutWorkingDirectoryToAssign & "`"
          WScript.Quit 21
        End If
      End If

      ShortcutWorkingDirectoryAssigned = True
    Else
      WScript.Echo _
        WScript.ScriptName & ": warning: WorkingDirectory reset is skipped because WorkingDirectory is empty and TargetPath is existed directory path:" & vbCrLf & _
        WScript.ScriptName & ": info: TargetPath=`" & ShortcutTargetUnquoted & "`"
    End If
  Else
    WScript.Echo WScript.ScriptName & ": error: shortcut target path is empty."
    WScript.Quit 10
  End If
End If

' 2

If ResetTargetPathFromWorkingDir Then
  If ShortcutTargetEmpty Then
    WScript.Echo WScript.ScriptName & ": error: shortcut target path is empty."
    WScript.Quit 10
  End If

  If ShortcutWorkingDirectoryEmpty Then
    WScript.Echo WScript.ScriptName & ": error: shortcut working directory path is empty."
    WScript.Quit 11
  End If

  If Not ShortcutTargetEmpty Then
    ShortcutTargetToAssign = ShortcutWorkingDirectoryUnquoted & "\" & objFS.GetFileName(ShortcutTargetUnquoted)

    If Not IgnoreUnexist Then
      ShortcutTargetToAssignExist = objFS.FileExists(ShortcutTargetToAssign)

      If Not ShortcutTargetToAssignExist Then
        WScript.Echo _
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
        WScript.Echo _
          WScript.ScriptName & ": error: shortcut desciprion as path to assign does not exist:" & vbCrLf & _
          WScript.ScriptName & ": info: TargetPath=`" & ShortcutTargetToAssign & "`"
        WScript.Quit 20
      End If
    End If

    ShortcutTargetAssigned = True
  Else
    WScript.Echo _
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
    WScript.Echo "TargetPath=" & ShortcutTargetToAssign
  End If

  If AlwaysQuote And InStr(ShortcutTargetToAssign, Chr(34)) = 0 Then
    ShortcutTargetToAssign = Chr(34) & ShortcutTargetToAssign & Chr(34)
  End If

  objSC.TargetPath = ShortcutTargetToAssign
ElseIf AllowTargetPathReassign Then
  If ShortcutTargetExist Or IgnoreUnexist Then
    If PrintAssign Then
      WScript.Echo "TargetPath=" & ShortcutTargetUnquoted
    End If

    objSC.TargetPath = ShortcutTarget ' reassign
  End If
End If

If ShortcutWorkingDirectoryAssigned Then
  If PrintAssign Then
    WScript.Echo "WorkingDirectory=" & ShortcutWorkingDirectoryToAssign
  End If

  objSC.WorkingDirectory = ShortcutWorkingDirectoryToAssign
ElseIf AllowWorkingDirectoryReassign Then
  If WorkingDirectoryExist Or IgnoreUnexist Then
    If PrintAssign Then
      WScript.Echo "WorkingDirectory=" & ShortcutWorkingDirectory
    End If

    objSC.WorkingDirectory = ShortcutWorkingDirectory ' reassign
  End If
End If

objSC.Save
