Dim objWMI : Set objWMI = GetObject("winmgmts:")
Dim objSet: Set objSet = objWMI.InstancesOf("Win32_OperatingSystem")

Dim obj
For Each obj in objSet
    WScript.Echo obj.LocalDateTime
    Exit For
Next
