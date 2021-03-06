''' Updates the Windows shortcut file.

''' USAGE:
'''   update_shortcut.vbs [-CD <CurrentDirectoryPath>] [-WD <ShortcutWorkingDirectory>] [-showas <ShowWindowAsNumber>] [-E | -E0 | -Et | -Ea] [-q] [-u] [-t <ShortcutTarget>] [-args <ShortcutArgs>] [--] <ShortcutFileName>

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

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

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
      If arg = "-u" Then ' Unescape %xx or %uxxxx
        UnescapeAllArgs = True
      ElseIf arg = "-CD" Then ' Change current directory
        i = i + 1
        ChangeCurrentDirectory =  WScript.Arguments(i)
        ChangeCurrentDirectoryExist = True
      ElseIf arg = "-WD" Then ' Shortcut working directory
        i = i + 1
        ShortcutWorkingDirectory =  WScript.Arguments(i)
        ShortcutWorkingDirectoryExist = True
      ElseIf arg = "-t" Then ' Shortcut target object
        i = i + 1
        ShortcutTarget =  WScript.Arguments(i)
        ShortcutTargetExist = True
      ElseIf arg = "-args" Then ' Shortcut target object arguments
        i = i + 1
        ShortcutArgs =  WScript.Arguments(i)
        ShortcutArgsExist = True
      ElseIf arg = "-showas" Then ' Show window as
        i = i + 1
        ShowAs = CInt(WScript.Arguments(i))
        ShowAsExist = True
      ElseIf arg = "-E" Then ' Expand environment variables in all arguments
        ExpandAllArgs = True
      ElseIf arg = "-E0" Then ' Expand environment variables only in the first argument
        ExpandArg0 = True
      ElseIf arg = "-Et" Then ' Expand environment variables only in the shortcut target object
        ExpandShortcutTarget = True
      ElseIf arg = "-Ea" Then ' Expand environment variables only in the shortcut arguments
        ExpandShortcutArgs = True
      ElseIf arg = "-q" Then ' Always quote CMD argument (if has no quote characters)
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
  WScript.Echo WScript.ScriptName & ": error: FILE_NAME argument is not defined."
  WScript.Quit 1
End If

If ChangeCurrentDirectoryExist Then
  objShell.CurrentDirectory = ChangeCurrentDirectory
End If

set objSC = objShell.CreateShortcut(cmd_args(0))

If ShortcutTargetExist Then
  If ExpandAllArgs Or ExpandShortcutTarget Then
    ShortcutTarget = objShell.ExpandEnvironmentStrings(ShortcutTarget)
  End If

  If UnescapeAllArgs Then
    ShortcutTarget = Unescape(ShortcutTarget)
  End If
Else
  ShortcutTarget = objSC.TargetPath
End If

If AlwaysQuote And InStr(ShortcutTarget, Chr(34)) = 0 Then
  ShortcutTarget = Chr(34) & ShortcutTarget & Chr(34)
End If

objSC.TargetPath = ShortcutTarget

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

  objSC.WorkingDirectory = ShortcutWorkingDirectory
End If

If ShowAsExist Then
  objSC.WindowStyle = CInt(ShowAs)
End If

objSC.Save
