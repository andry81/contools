ReDim args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True
Dim UnescapeArgs : UnescapeArgs = False
Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim ShowAs : ShowAs = 1
Dim ExpandArgs : ExpandArgs = False
Dim AlwaysQuote : AlwaysQuote = False
Dim NoWait : NoWait = False
Dim NoWindow : NoWindow = False

Dim objShell : Set objShell = WScript.CreateObject("WScript.Shell")

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
      ElseIf WScript.Arguments(i) = "-E" Then ' Expand environment variables
        ExpandArgs = True
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
      arg = objShell.ExpandEnvironmentStrings(arg)
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
  objShell.CurrentDirectory = ChangeCurrentDirectory
End If

If Not NoWait Then
  objShell.Run Join(args, " "), ShowAs, True
Else
  objShell.Run Join(args, " "), ShowAs, False
End If
