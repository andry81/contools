' script to preformat an xml file

If WScript.Arguments.Count > 0 Then
  If TypeName(WScript.Arguments(0)) <> "Nothing" Then
    xml_file_in = WScript.Arguments(0)
  End If
End If
If WScript.Arguments.Count > 1 Then
  If TypeName(WScript.Arguments(1)) <> "Nothing" Then
    xml_file_out = WScript.Arguments(1)
  End If
End If

Set fso = CreateObject("Scripting.FileSystemObject")
If Not fso.FileExists(xml_file_in) Then
  WScript.Quit(1)
End If

If TypeName(xml_file_out) = "Nothing" Or xml_file_out = "" Then
  WScript.Quit(2)
End If

Set xmlDoc = CreateObject("Microsoft.XMLDOM")
xmlDoc.Async = "False"
xmlDoc.Load(xml_file_in)
xmlDoc.Save(xml_file_out)
