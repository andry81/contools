ReDim args(WScript.Arguments.Count-1)
For i = 0 To WScript.Arguments.Count-1
  If InStr(WScript.Arguments(i), " ") > 0 Then
    args(i) = Chr(34) & WScript.Arguments(i) & Chr(34)
  ElseIf WScript.Arguments(i) = "" Then
    args(i) = Chr(34) & WScript.Arguments(i) & Chr(34)
  Else
    args(i) = WScript.Arguments(i)
  End If
Next

Set objShell = WScript.CreateObject("WScript.Shell")

' MsgBox Join(args, " ")

objShell.Run Join(args, " "), 0, True
