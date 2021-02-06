ReDim args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True
Dim UnescapeArgs : UnescapeArgs = False
Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim ShowAs : ShowAs = 1
Dim ExpandArgs : ExpandArgs = False
Dim ExpandArg0 : ExpandArg0 = False
Dim ExpandTailArgs : ExpandTailArgs = False
Dim AlwaysQuote : AlwaysQuote = False
Dim NoWait : NoWait = False
Dim NoWindow : NoWindow = False

Dim shell_obj : Set shell_obj = WScript.CreateObject("WScript.Shell")

Dim arg
Dim i, j : j = 0

For i = 0 To WScript.Arguments.Count-1
  If ExpectFlags Then
    If Mid(WScript.Arguments(i), 1, 1) = "-" Then
      If WScript.Arguments(i) = "-unesc" Then ' Unescape %xx or %uxxxx
        UnescapeArgs = True
      ElseIf WScript.Arguments(i) = "-D" Then ' Change current directory
        i = i + 1
        ChangeCurrentDirectory =  WScript.Arguments(i)
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
      ElseIf WScript.Arguments(i) = "-nowait" Then
        NoWait = True
      ElseIf WScript.Arguments(i) = "-nowindow" Then
        NoWindow = True
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

    If InStr(arg, Chr(34)) = 0 Then
      If AlwaysQuote Or Len(arg & "") = 0 Or InStr(arg, Space(1)) <> 0 Or InStr(arg, vbTab) <> 0 Then
        args(j) = Chr(34) & arg & Chr(34)
      Else
        args(j) = arg
      End If
    Else
      args(j) = arg
    End If

    j = j + 1
  End If
Next

If NoWindow Then ShowAs = 0

ReDim Preserve args(j - 1)

' MsgBox Join(args, " ")

If ChangeCurrentDirectory <> "" Then
  shell_obj.CurrentDirectory = ChangeCurrentDirectory
End If

shell_obj.Run Join(args, " "), ShowAs, Not NoWait
