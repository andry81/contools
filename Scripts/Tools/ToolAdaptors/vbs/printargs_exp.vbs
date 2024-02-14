Dim args_str : args_str = ""

Dim objShell : Set objShell = WScript.CreateObject("WScript.Shell")

Dim arg
For i = 0 To WScript.Arguments.Count-1
  arg = objShell.ExpandEnvironmentStrings(WScript.Arguments(i))
  args_str = args_str & Len(arg) & "|" & arg & "|" & vbCrLf
Next

WScript.Echo args_str

WScript.Quit CStr(WScript.Arguments.Count)
