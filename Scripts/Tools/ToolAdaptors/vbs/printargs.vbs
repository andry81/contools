ReDim args(WScript.Arguments.Count - 1)

Dim args_str : args_str = ""

For i = 0 To WScript.Arguments.Count-1
  args_str = args_str & Len(WScript.Arguments(i)) & "|" & WScript.Arguments(i) & "|" & vbCrLf
Next

WScript.Echo args_str

WScript.Quit CStr(WScript.Arguments.Count)
