ReDim args(WScript.Arguments.Count-1)
Dim ExpectFlags
Dim ExpandArgs
Dim NoWait
Dim NoWindow

ExpectFlags = True
ExpandArgs = False
NoWait = False
NoWindow = False

Set objShell = WScript.CreateObject("WScript.Shell")

Dim j
j = 0

For i = 0 To WScript.Arguments.Count-1
  If ExpectFlags Then
    If Mid(WScript.Arguments(i), 1, 1) = "-" Then
      If WScript.Arguments(i) = "-E" Then
        ExpandArgs = True
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
      If InStr(WScript.Arguments(i), Chr(34)) = 0 Then
        args(j) = Chr(34) & WScript.Arguments(i) & Chr(34)
      Else
        args(j) = WScript.Arguments(i)
      End If
    Else
      If InStr(WScript.Arguments(i), Chr(34)) = 0 Then
        args(j) = Chr(34) & objShell.ExpandEnvironmentStrings(WScript.Arguments(i)) & Chr(34)
      Else
        args(j) = objShell.ExpandEnvironmentStrings(WScript.Arguments(i))
      End If
    End If
    j = j + 1
  End If
Next

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
