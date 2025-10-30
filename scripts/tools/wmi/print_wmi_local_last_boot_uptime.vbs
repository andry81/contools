Dim objWMI : Set objWMI = GetObject("winmgmts:")
Dim objSet: Set objSet = objWMI.InstancesOf("Win32_OperatingSystem")

Dim obj
For Each obj in objSet
    WScript.Echo CDbl(Left(obj.LocalDateTime, 21)) - CDbl(Left(obj.LastBootUpTime, 21))
    Exit For
Next
