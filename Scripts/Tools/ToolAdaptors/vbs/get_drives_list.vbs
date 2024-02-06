''' Gets list of drives and drive properties.

''' Print format:
'''   <Letter>|<Type>|<FileSystem>|<SerialNumber>|<Path>|<ShareName>|<VolumeName>
'''
'''   NOTE:
'''     If a value is empty or can not be retrieved, then the `?` character is
'''     used instead of an empty value.

''' Documentation:
'''   https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/drive-object

''' Another resources:
'''   https://github.com/libyal/liblnk/blob/main/documentation/Windows%20Shortcut%20File%20(LNK)%20format.asciidoc

Sub PrintOrEchoLine(str)
  On Error Resume Next
  WScript.stdout.WriteLine str
  If err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

Sub PrintOrEchoErrorLine(str)
  On Error Resume Next
  WScript.stderr.WriteLine str
  If err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

Dim Drive, DriveIsReadyStr, DriveLetter, DriveType, DriveTypeStr, FileSystemStr, SerialNumberStr
Dim Path, ShareName, VolumeName

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

For Each Drive in objFS.Drives
  DriveLetter = Drive.DriveLetter
  DriveType = Drive.DriveType

  Select Case DriveType
    case 0: DriveTypeStr = "Unknown"
    case 1: DriveTypeStr = "Removable"
    case 2: DriveTypeStr = "Fixed"
    case 3: DriveTypeStr = "Network"
    case 4: DriveTypeStr = "CD-ROM"
    case 5: DriveTypeStr = "RAM Disk"
  End Select

  If Drive.IsReady Then
    FileSystemStr = Drive.FileSystem
    SerialNumberStr = Hex(Drive.SerialNumber)
    VolumeName = Drive.VolumeName

    If Not (Len(FileSystemStr) > 0) Then
      FileSystemStr = "?"
    End If
    If Not (Len(SerialNumberStr) > 0) Then
      SerialNumberStr = "?"
    End If
    If Not (Len(VolumeName) > 0) Then
      VolumeName = "?"
    End If
  Else
    FileSystemStr = "?"
    SerialNumberStr = "?"
    VolumeName = "?"
  End If

  Path = Drive.Path
  ShareName = Drive.ShareName

  If Not (Len(DriveLetter) > 0) Then
    DriveLetter = "?"
  End If
  If Not (Len(DriveType) > 0) Then
    DriveType = "?"
  End If

  If Not (Len(Path) > 0) Then
    Path = "?"
  End If
  If Not (Len(ShareName) > 0) Then
    ShareName = "?"
  End If

  PrintOrEchoLine DriveLetter & "|" & DriveTypeStr & "|" & FileSystemStr & "|" & SerialNumberStr & "|" & Path & "|" & ShareName & "|" & VolumeName
Next 
