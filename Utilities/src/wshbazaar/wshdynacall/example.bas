' Example VB Script using DynamicWrapper Object

' Create the wrapper object
Dim UserWrap As Object
Set UserWrap = CreateObject("DynamicWrapper")
Dim val ' Receives return result

' Call MessageBoxA()
UserWrap.Register "USER32.DLL", "MessageBoxA", "I=HsSu", "f=s", "R=l"
UserWrap.MessageBoxA Null, "MessageBox (ANSI)", "From DynaWrap Object", 3

' Call sin()
UserWrap.Register("MSVCRT.DLL", "sin", "I=d", "R=d", "f=S8")
val = UserWrap.Sin(2)

' Call MessageBoxW
UserWrap.Register("USER32.DLL", "MessageBoxW", "I=Hwwu", "f=S", "R=l")
val = UserWrap.MessageBoxW(Null, "MessageBox (UNICODE)", "From DynaWrap Object", 3)
