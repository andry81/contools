''' Prints all property values of the `Win32_Processor` instance.

''' CAUTION:
'''   The `WScript.std[out|err].WriteLine STR` functions has issue with the
'''   last line desynchronization between streams.
'''   To workaround use `WScript.std[out|err].Write STR & vbCrLf` instead.

Function FixStrToPrint(str)
  Dim new_str : new_str = ""
  Dim i, Char, CharAsc

  For i = 1 To Len(str)
    Char = Mid(str, i, 1)
    CharAsc = Asc(Char)

    ' NOTE:
    '   `&H3F` - is not printable unicode origin character which can not pass through the stdout redirection.
    If CharAsc <> &H3F Then
      new_str = new_str & Char
    Else
      new_str = new_str & "?"
    End If
  Next

  FixStrToPrint = new_str
End Function

Sub PrintOrEchoLine(str)
  On Error Resume Next
  WScript.stdout.Write str & vbCrLf
  If err = 5 Then ' Access is denied
    WScript.stdout.Write FixStrToPrint(str) & vbCrLf
  ElseIf err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

' On Error Resume Next

Dim objWMI : Set objWMI = GetObject("winmgmts:")
Dim objSet: Set objSet = objWMI.InstancesOf("Win32_Processor")
Dim objClass : Set objClass = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2:Win32_Processor")

Dim obj, objClassProp
For Each obj in objSet
  PrintOrEchoLine "[" & obj.Name & "]"

  For Each objClassProp In objClass.Properties_
    PrintOrEchoLine objClassProp.Name & "=" & Eval("obj." & objClassProp.Name)
  Next

  PrintOrEchoLine ""
Next
