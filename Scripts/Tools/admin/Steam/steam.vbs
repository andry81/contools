Function ReadBinaryFile(strPath)
    Dim oFSO: Set oFSO = CreateObject("Scripting.FileSystemObject")
    Dim oFile: Set oFile = oFSO.GetFile(strPath)

    If IsNull(oFile) Then MsgBox("File not found: " & strPath) : Exit Function

    Set ts = oFile.OpenAsTextStream()
    ReadBinaryFile = ts.Read(oFile.Size)
    ts.Close
End Function

Function WriteBinaryFile(strText, strPath)
    Dim oFSO: Set oFSO = CreateObject("Scripting.FileSystemObject")

    ' below lines purpose: checks that write access is possible!
    Dim oTxtStream: Set oTxtStream = oFSO.createTextFile(strPath)
    On Error Resume Next
    If Err.number <> 0 Then MsgBox(Err.message) : Exit Function
    On Error GoTo 0
    Set oTxtStream = Nothing
    ' end check of write access

    With oFSO.createTextFile(strPath)
        .Write(strText)
        .Close
    End With
End Function

Dim mode
If WScript.Arguments.Count >= 1 Then
    mode = WScript.Arguments(0)
Else
    mode = "online"
End If

Set objShell = CreateObject("WScript.Shell")

Dim isOnline
If mode = "online" Then
  isOnline = True
ElseIf mode = "offline" Then
  isOnline = False
Else
  objShell.Run("steam://rungameid/" & mode)
  WScript.Quit
End If

Dim strText
strText = ReadBinaryFile("config\loginusers.vdf")

' special characters
Dim vbLf
vbLf = chr(10) ' unix text format
Dim vbTab
vbTab = chr(9)

' replace specific variables
Dim listLines
listLines = Split(strText, vbLf)

' use inpit variable as output
strText = ""

Dim WantsOfflineMode_strOffset
Dim SkipOfflineModeWarning_strOffset
For Each strLine In listLines
    WantsOfflineMode_strOffset = InStr(strLine, """WantsOfflineMode""")
    If WantsOfflineMode_strOffset = 0 Then
      SkipOfflineModeWarning_strOffset = InStr(strLine, """SkipOfflineModeWarning""")
    End If
    If WantsOfflineMode_strOffset <> 0 Then
      WantsOfflineMode_strOffset = WantsOfflineMode_strOffset - 1
    End If
    If SkipOfflineModeWarning_strOffset <> 0 Then
      SkipOfflineModeWarning_strOffset = SkipOfflineModeWarning_strOffset - 1
    End If

    If WantsOfflineMode_strOffset <> 0 Then
        If isOnline = True Then
          strText = strText & Left(strLine, WantsOfflineMode_strOffset) & """WantsOfflineMode""" & vbTab & vbTab & """0""" & vbLf
        Else
          strText = strText & Left(strLine, WantsOfflineMode_strOffset) & """WantsOfflineMode""" & vbTab & vbTab & """1""" & vbLf
        End If
    ElseIf SkipOfflineModeWarning_strOffset <> 0 Then
      If isOnline = True Then
        strText = strText & Left(strLine, SkipOfflineModeWarning_strOffset) & """SkipOfflineModeWarning""" & vbTab & vbTab & """0""" & vbLf
      Else
        strText = strText & Left(strLine, SkipOfflineModeWarning_strOffset) & """SkipOfflineModeWarning""" & vbTab & vbTab & """1""" & vbLf
      End If
    Else
      strText = strText & strLine & vbLf
    End If
Next

' WScript.Echo strText

WriteBinaryFile strText, "config\loginusers.vdf"

objShell.Exec("Steam.exe")
