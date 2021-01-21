Dim cmd_arg
Dim param_args
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
Dim WaitOnFileExist : WaitOnFileExist = ""

Dim objShell : Set objShell = WScript.CreateObject("WScript.Shell")
Dim objWinShell : Set objWinShell = WScript.CreateObject("Shell.Application")

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
      arg = objShell.ExpandEnvironmentStrings(arg)
    ElseIf ExpandArg0 And j = 0 Then
      arg = objShell.ExpandEnvironmentStrings(arg)
    ElseIf ExpandTailArgs And j > 0 Then
      arg = objShell.ExpandEnvironmentStrings(arg)
    End If

    If UnescapeArgs Then
      arg = Unescape(arg)
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

objWinShell.ShellExecute cmd_arg, Join(param_args, " "), ChangeCurrentDirectory, Verb, ShowAs

If WaitOnFileExist <> "" Then
  Dim fs_obj : Set fs_obj = CreateObject("Scripting.FileSystemObject")
  Do Until Not fs_obj.FileExists(WaitOnFileExist)
    WScript.Sleep 20
  Loop
End If
