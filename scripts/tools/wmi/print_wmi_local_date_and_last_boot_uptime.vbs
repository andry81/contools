Function CDbl_(str)
    Dim dbl_with_sep : dbl_with_sep = CStr(CDbl(1/2))
    Dim dbl_sep : dbl_sep = Mid(dbl_with_sep, 2, 1) ' locale separator

    ' fix dbl separator
    If InStr(str, ".") > 0 And dbl_sep <> "." Then
        CDbl_ = CDbl(Replace(str, ".", dbl_sep))
    ElseIf InStr(str, ",") > 0 And dbl_sep <> "," Then
        CDbl_ = CDbl(Replace(str, ",", dbl_sep))
    Else
        CDbl_ = CDbl(str)
    End If
End Function

Dim objWMI : Set objWMI = GetObject("winmgmts:")
Dim objSet: Set objSet = objWMI.InstancesOf("Win32_OperatingSystem")

Dim obj
For Each obj in objSet
    WScript.Echo Left(obj.LocalDateTime, 8) & ";" & CDbl_(Left(obj.LocalDateTime, 21)) - CDbl_(Left(obj.LastBootUpTime, 21))
    Exit For
Next
