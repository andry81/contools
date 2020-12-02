'===========================================================================
' Created by The Axean Group, a California corporation.                    =
' Copyright © 1998, 1999 The Axean Group.                                  =
'===========================================================================
'   Create the wrapper object for dynamic DLL function calling
Dim UserWrap 
Set UserWrap = CreateObject("DynamicWrapper")
'   GetProcAddress for GetPrivateProfileStringA()
UserWrap.Register "kernel32.DLL", "GetPrivateProfileString", "i=sssrls", "f=s", "r=l"
'   GetProcAddress for GetPrivateProfileSection()
UserWrap.Register "kernel32.DLL", "GetPrivateProfileSection", "I=sshs", "f=s", "R=l"


Const ForReading = 1, ForWriting = 2, ForAppending = 3
Const TristateUseDefault = -2, TristateTrue = -1, TristateFalse = 0
Dim lsCCSource, lsSection
Dim KeyValue
Dim INIFile
Dim fso, f, ts, LogFile
INIFile = "c:\ccupd\ccupd.ini"   
LogFile = "getapps.log"

    Set fso = CreateObject("Scripting.FileSystemObject")
    If (fso.FileExists(LogFile)) Then fso.DeleteFile(LogFile)
    fso.CreateTextFile LogFile                                     
    Set f = fso.GetFile(LogFile)
    Set ts = f.OpenAsTextStream(ForWriting, TristateUseDefault)
    WriteLogRec("Processing Begins:")
 
    lsCCSource = VBSGetPrivateINIkey("CC", "SOURCE", INIFile)
'    lsSection = VBSGetPrivateINIsection("CC", INIFile)

    WriteLogRec(lsCCSource)
    WriteLogRec(lsSection)
    ts.Close

' End Script

Wscript.quit

'---------------------------------------------------------------
' FUNCTIONS
'---------------------------------------------------------------

'--------------------------------------------------------------
' Read INI File
'--------------------------------------------------------------
Function VBSGetPrivateINIkey(Section, Key, INIFiles)
Dim KeyValue
Dim KeyInit
Dim characters 
KeyInit  = String(128, "*")
    
    KeyValue = Cstr(KeyInit)
    characters = UserWrap.GetPrivateProfileString(Cstr(Section), Cstr(Key), "", KeyValue, Clng(127), Cstr(INIFiles))
   
    If characters > 1 Then
        KeyValue = Left(cstr(KeyValue), characters)
    End If

    WriteLogRec(characters)
    WriteLogRec(KeyValue)

    VBSGetPrivateINIkey = KeyValue

End Function

Function VBSGetPrivateINIsection(Section, INIFiles)
Dim KeyValue
Dim characters 
Dim Keylen
KeyValue = String(128, 0)
Keylen = 127


    characters = UserWrap.GetPrivateProfileSection(Cstr(Section), Cstr(KeyValue), Clng(Keylen), Cstr(INIFiles))

    If characters > 1 Then
        KeyValue = Left(KeyValue, characters)
    End If

    WriteLogRec(characters)

    VBSGetPrivateINIsection = KeyValue

End Function

'--------------------------------------------------------------
' Write to GetApps Log file
'--------------------------------------------------------------
Function WriteLogRec(msgtxt)
Dim CRLF
CRLF = Chr(13) & Chr(10)

    ts.Write(msgtxt &  " "  & Date & " " & Time & " " & CRLF)
  
End Function

