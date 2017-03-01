Sub includeFile(fSpec)
    executeGlobal CreateObject("Scripting.FileSystemObject").openTextFile(fSpec).readAll()
End Sub

includeFile("ProductKey.vbs")

Function GetKeyFromRegLoc(key, value)
    Dim WSHShell
    Dim keyValue

    On Error Resume Next
    Set WSHShell = CreateObject("WScript.Shell")
    keyValue = WSHShell.RegRead(key & "\" & value)

    If err.number <> 0 Then
      Wscript.Echo("error: registry read error: (0x" & Hex(err.number) & ") " & key & ":" & value)
      GetKeyFromRegLoc = ""
    Else
      Dim sString
      size = UBound(keyValue)
      ReDim keyBytes(size)
      For i = 0 To size
          sString = sString & Chr(keyValue(i))
      Next
      GetKeyFromRegLoc = sString
    End If

    Set WSHShell = Nothing
End Function

Dim key
Dim value

key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
value = "DigitalProductId"

If WScript.Arguments.Count > 0 Then
    If TypeName(WScript.Arguments(0)) <> "Nothing" Then
        key = WScript.Arguments(0)
    End If
End If
If WScript.Arguments.Count > 1 Then
    If TypeName(WScript.Arguments(1)) <> "Nothing" Then
        value = WScript.Arguments(1)
    End If
End If

Dim regBytes
regBytes = GetKeyFromRegLoc(key, value)

If not regBytes = "" Then
  Wscript.Echo(DecodeFromBytes(regBytes))
End If
