''' Creates the Windows shortcut file.

''' USAGE:
'''   make_shortcut.vbs [-CD <CurrentDirectoryPath>] [-WD <ShortcutWorkingDirectory>] [-showas <ShowWindowAsNumber>] [-E] [-q] [-unesc] <ShortcutFileName> <ShortcutTarget> <ShortcutArgs>
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
'''   make_shortcut.bat -CD "%WINDIR%\System32" -unesc cmd_system32.lnk "%22%25SystemRoot%25\System32\cmd.exe%22"
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

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim UnescapeArgs : UnescapeArgs = False

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

Dim ExpandArgs : ExpandArgs = False
Dim ExpandArg0 : ExpandArg0 = False
Dim ExpandShortcutTarget : ExpandShortcutTarget = False
Dim ExpandShortcutArgs : ExpandShortcutArgs = False
Dim AlwaysQuote : AlwaysQuote = False

Dim objShell : Set objShell = WScript.CreateObject("WScript.Shell")

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1
  If ExpectFlags Then
    If Mid(WScript.Arguments(i), 1, 1) = "-" Then
      If WScript.Arguments(i) = "-unesc" Then ' Unescape %xx or %uxxxx
        UnescapeArgs = True
      ElseIf WScript.Arguments(i) = "-CD" Then ' Change current directory
        i = i + 1
        ChangeCurrentDirectory =  WScript.Arguments(i)
        ChangeCurrentDirectoryExist = True
      ElseIf WScript.Arguments(i) = "-WD" Then ' Shortcut working directory
        i = i + 1
        ShortcutWorkingDirectory =  WScript.Arguments(i)
        ShortcutWorkingDirectoryExist = True
      ElseIf WScript.Arguments(i) = "-showas" Then ' Show window as
        i = i + 1
        ShowAs = CInt(WScript.Arguments(i))
        ShowAsExist = True
      ElseIf WScript.Arguments(i) = "-E" Then ' Expand environment variables in all arguments
        ExpandArgs = True
      ElseIf WScript.Arguments(i) = "-E0" Then ' Expand environment variables only in the first argument
        ExpandArg0 = True
      ElseIf WScript.Arguments(i) = "-Et" Then ' Expand environment variables only in the shortcut target object
        ExpandShortcutTarget = True
      ElseIf WScript.Arguments(i) = "-Ea" Then ' Expand environment variables only in the shortcut arguments
        ExpandShortcutArgs = True
      ElseIf WScript.Arguments(i) = "-q" Then ' Always quote CMD argument (if has no quote characters)
        AlwaysQuote = True
      Else
        WScript.Echo WScript.ScriptName & ": error: unknown flag: `" & WScript.Arguments(i) & "`"
        WScript.Quit 255
      End If
    Else
      ExpectFlags = False
    End If
  End If

  If Not ExpectFlags Then
    arg = WScript.Arguments(i)

    If ExpandArgs Then
      arg = objShell.ExpandEnvironmentStrings(arg)
    ElseIf ExpandArg0 And j = 0 Then
      arg = objShell.ExpandEnvironmentStrings(arg)
    ElseIf ExpandShortcutTarget And j = 1 Then
      arg = objShell.ExpandEnvironmentStrings(arg)
    ElseIf ExpandShortcutArgs And j = 2 Then
      arg = objShell.ExpandEnvironmentStrings(arg)
    End If

    If UnescapeArgs Then
      arg = Unescape(arg)
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
Next

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

set objSC = objShell.CreateShortcut(cmd_args(0))

If AlwaysQuote And InStr(ShortcutTarget, Chr(34)) = 0 Then
  ShortcutTarget = Chr(34) & ShortcutTarget & Chr(34)
End If

objSC.TargetPath = ShortcutTarget

If ShortcutArgsExist Then
  objSC.Arguments = ShortcutArgs
End If

If ShortcutWorkingDirectoryExist Then
  If UnescapeArgs Then
    ShortcutWorkingDirectory = Unescape(ShortcutWorkingDirectory)
  End If

  objSC.WorkingDirectory = ShortcutWorkingDirectory
End If

If ShowAsExist Then
  objSC.WindowStyle = CInt(ShowAs)
End If

objSC.Save
