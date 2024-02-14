Dim args_str : args_str = ""

Dim arg
For i = 0 To WScript.Arguments.Count-1
  arg = Unescape(WScript.Arguments(i))
  args_str = args_str & Len(arg) & "|" & arg & "|" & vbCrLf
Next

WScript.Echo args_str

WScript.Quit CStr(WScript.Arguments.Count)
