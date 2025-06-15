Dim objWMI : Set objWMI = GetObject("winmgmts:")
Dim objClasses : Set objClasses = objWMI.ExecQuery("SELECT * FROM meta_class") 

Dim objClass

For Each objClass in objClasses
  If objClass.Methods_.Count > 0 Then
    WScript.Echo objClass.Path_.Class
  End If
Next
