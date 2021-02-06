Dim cmd_arg
Dim param_args : param_args = Array()
If WScript.Arguments.Count > 1 Then
  ReDim param_args(WScript.Arguments.Count - 2)
End If

Dim ExpectFlags : ExpectFlags = True
Dim UnescapeArgs : UnescapeArgs = False
Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim Verb : Verb = "open"
Dim ShowAs : ShowAs = 1
Dim ExpandArgs : ExpandArgs = False
Dim ExpandArg0 : ExpandArg0 = False
Dim ExpandTailArgs : ExpandTailArgs = False
Dim AlwaysQuote : AlwaysQuote = False
Dim NoWindow : NoWindow = False
Dim MakeTempDirAsCWD : MakeTempDirAsCWD = ""
Dim WaitDeleteCWD : WaitDeleteCWD = 0
Dim WaitOnFileExist : WaitOnFileExist = ""

Dim now_obj, timer_obj

Dim shell_obj : Set shell_obj = WScript.CreateObject("WScript.Shell")
Dim winshell_obj : Set winshell_obj = WScript.CreateObject("Shell.Application")
Dim fs_obj : Set fs_obj = CreateObject("Scripting.FileSystemObject")

Dim arg
Dim IsCmdArg : IsCmdArg = True
Dim i, j : j = 0

For i = 0 To WScript.Arguments.Count-1
  If ExpectFlags Then
    If Mid(WScript.Arguments(i), 1, 1) = "-" Then
      If WScript.Arguments(i) = "-unesc" Then ' Unescape %xx or %uxxxx
        UnescapeArgs = True
      ElseIf WScript.Arguments(i) = "-D" Then ' Change current directory
        i = i + 1
        ChangeCurrentDirectory =  WScript.Arguments(i)
      ElseIf WScript.Arguments(i) = "-verb" Then ' Shell Verb
        i = i + 1
        Verb = WScript.Arguments(i)
      ElseIf WScript.Arguments(i) = "-showas" Then ' Show window as
        i = i + 1
        ShowAs = CInt(WScript.Arguments(i))
      ElseIf WScript.Arguments(i) = "-E" Then ' Expand environment variables in all arguments
        ExpandArgs = True
      ElseIf WScript.Arguments(i) = "-E0" Then ' Expand environment variables only in the first argument
        ExpandArg0 = True
      ElseIf WScript.Arguments(i) = "-Ea" Then ' Expand environment variables only in the tail arguments
        ExpandTailArgs = True
      ElseIf WScript.Arguments(i) = "-q" Then ' Always quote arguments (if already has no quote characters)
        AlwaysQuote = True
      ElseIf WScript.Arguments(i) = "-nowindow" Then
        NoWindow = True
      ElseIf WScript.Arguments(i) = "-make_temp_dir_as_cwd" Then
        i = i + 1
        MakeTempDirAsCWD = WScript.Arguments(i)
        now_obj = Now
        timer_obj = Timer
        ChangeCurrentDirectory = fs_obj.GetSpecialFolder(2) & "\" & _
          Year(now_obj) & "'" & Right("0" & Month(now_obj),2) & "'" & Right("0" & Day(now_obj),2) & "." & _
          Right("0" & Hour(now_obj),2) & "'" & Right("0" & Minute(now_obj),2) & "'" & Right("0" & Second(now_obj),2) & "''" & Right("0" & Int((timer_obj - Int(timer_obj)) * 1000),3) & "." & _
          "winshell_call"
      ElseIf WScript.Arguments(i) = "-wait_delete_cwd" Then ' ShellExecute current working directory, because the Windows locks current directory for a process being ran
        WaitDeleteCWD = 1
      ElseIf WScript.Arguments(i) = "-wait_on_file_exist" Then
        i = i + 1
        WaitOnFileExist = WScript.Arguments(i)
      End If
    Else
      ExpectFlags = False
    End If
  End If

  If Not ExpectFlags Then
    arg = WScript.Arguments(i)

    If ExpandArgs Then
      arg = shell_obj.ExpandEnvironmentStrings(arg)
    ElseIf ExpandArg0 And j = 0 Then
      arg = shell_obj.ExpandEnvironmentStrings(arg)
    ElseIf ExpandTailArgs And j > 0 Then
      arg = shell_obj.ExpandEnvironmentStrings(arg)
    End If

    If UnescapeArgs Then
      arg = Unescape(arg)
    End If

    If MakeTempDirAsCWD <> "" Then
      arg = Replace(arg, MakeTempDirAsCWD, ChangeCurrentDirectory, 1, -1, vbBinaryCompare)
    End If

    If InStr(arg, Chr(34)) = 0 Then
      If AlwaysQuote Or Len(arg & "") = 0 Or InStr(arg, Space(1)) <> 0 Or InStr(arg, vbTab) <> 0 Then
        arg = Chr(34) & arg & Chr(34)
      End If
    End If

    If Not IsCmdArg Then
      param_args(j) = arg
      j = j + 1
    Else
      cmd_arg = arg
      IsCmdArg = False
    End If
  End If
Next

If NoWindow Then ShowAs = 0

ReDim Preserve param_args(j - 1)

' MsgBox cmd_arg & " " & Join(param_args, " ")

If MakeTempDirAsCWD <> "" Then
  fs_obj.CreateFolder ChangeCurrentDirectory
End If

Dim PrevCurrentDirectory : PrevCurrentDirectory = shell_obj.CurrentDirectory

If ChangeCurrentDirectory <> "" Then
  shell_obj.CurrentDirectory = ChangeCurrentDirectory
End If

winshell_obj.ShellExecute cmd_arg, Join(param_args, " "), ChangeCurrentDirectory, Verb, ShowAs

If WaitDeleteCWD And ChangeCurrentDirectory <> "" Then
  ' ShellExecute startup synchronization timeout
  WScript.Sleep 1000
End If

If ChangeCurrentDirectory <> "" Then
  shell_obj.CurrentDirectory = PrevCurrentDirectory
End If

If WaitDeleteCWD And ChangeCurrentDirectory <> "" Then
  Do Until Not fs_obj.FolderExists(ChangeCurrentDirectory)
    On Error Resume Next
    fs_obj.DeleteFolder ChangeCurrentDirectory, False
    On Error Goto 0
    WScript.Sleep 20
  Loop
End If

If WaitOnFileExist <> "" Then
  Do Until Not fs_obj.FileExists(WaitOnFileExist)
    WScript.Sleep 20
  Loop
End If

' cleanup
If MakeTempDirAsCWD <> "" And Not WaitDeleteCWD And ChangeCurrentDirectory <> "" Then
  If fs_obj.FolderExists(ChangeCurrentDirectory) Then
    On Error Resume Next
    fs_obj.DeleteFolder ChangeCurrentDirectory, False
    On Error Goto 0
  End If
End If
