Set objShell = WScript.CreateObject("WScript.Shell")
objShell.Run """%COMSPEC%"" /c start """" /B /WAIT notepad.exe", 0, True
