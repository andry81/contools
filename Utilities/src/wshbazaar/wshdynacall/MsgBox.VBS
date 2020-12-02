'************************************************
' File:   DynaMsg.vbs (WSH-sample in VBScript) 
' Author: G. Born
'
' Demonstrates how to use the Dyncall.dll to access
' API functions from VBScript. The DLL may be downloaded
' from C. Washingtons site:
' http://cwashington.netreach.net/site/downloads.html
'************************************************
' 
Option Explicit
Dim UserWrap 
Set UserWrap = CreateObject("DynamicWrapper")

' Call MessageBoxA(), first register the API function
UserWrap.Register "USER32.DLL", "MessageBoxA", "I=HsSu", _
                 "f=s", "R=l"
' now call the function
UserWrap.MessageBoxA Null, "MessageBox (ANSI)", _
        "From DynaWrap Object", 3

'*************************************************
'***    End ->WSH-VBScript                     ***
'*************************************************