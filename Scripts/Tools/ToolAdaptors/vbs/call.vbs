ReDim args(WScript.Arguments.Count-1)

Dim ExpectFlags : ExpectFlags = True
Dim ExpandArgs : ExpandArgs = False
Dim AlwaysQuote : AlwaysQuote = False
Dim NoWait : NoWait = False
Dim NoWindow : NoWindow = False

Set objShell = WScript.CreateObject("WScript.Shell")

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1
  If ExpectFlags Then
    If Mid(WScript.Arguments(i), 1, 1) = "-" Then
      If WScript.Arguments(i) = "-E" Then ' Expand environment variables
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
    If Not ExpandArgs Then
      arg = WScript.Arguments(i)
      If InStr(arg, Chr(34)) = 0 Then
        If AlwaysQuote Or Len(arg & "") = 0 Or InStr(arg, Space(1)) <> 0 Or InStr(arg, vbTab) <> 0 Then
          args(j) = Chr(34) & arg & Chr(34)
        Else
          args(j) = arg
        End If
      Else
        args(j) = arg
      End If
    Else
      arg = objShell.ExpandEnvironmentStrings(WScript.Arguments(i))
      If InStr(arg, Chr(34)) = 0 Then
        If AlwaysQuote Or Len(arg & "") = 0 Or InStr(arg, Space(1)) <> 0 Or InStr(arg, vbTab) <> 0 Then
          args(j) = Chr(34) & arg & Chr(34)
        Else
          args(j) = arg
        End If
      Else
        args(j) = arg
      End If
    End If
    j = j + 1
  End If
Next

ReDim args(j - 1)

' MsgBox Join(args, " ")

if Not NoWindow Then
  If Not NoWait Then
    objShell.Run Join(args, " "), 1, True
  Else
    objShell.Run Join(args, " "), 1, False
  End If
Else
  If Not NoWait Then
    objShell.Run Join(args, " "), 0, True
  Else
    objShell.Run Join(args, " "), 0, False
  End If
End If
