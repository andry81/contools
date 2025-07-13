''' Gets list of drives and drive properties.

''' Print format:
'''   <Letter>|<Type>|<FileSystem>|<SerialNumber>|<Path>|<ShareName>|<VolumeName>
'''
'''   NOTE:
'''     If a value is empty or can not be retrieved, then the `?` character is
'''     used instead of an empty value.

''' Documentation:
'''   https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/drive-object

''' Related resources:
'''   https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-shllink
'''   https://github.com/libyal/liblnk/blob/main/documentation/Windows%20Shortcut%20File%20(LNK)%20format.asciidoc

''' CAUTION:
'''   Windows Scripting Host version 5.8 (Windows 7, 8, 8.1) has an issue
'''   around a conditional expression:
'''     `If Expr1 Or Expr2 ...`
'''   , where `Expr2` does execute even if `Expr1` is `True`.
'''
'''   Additionally, there is another issue, when the `Expr2` can trigger the
'''   corruption of following code.
'''
'''   The case is found in the `Expr2` expression, where a function does write
'''   into it's input parameter.
'''
'''   To workaround that we must declare a temporary parameter in the function
'''   of the `Expr2` and write into a temporary variable instead of an input
'''   parameter.
'''
'''   Example of potentially corrupted code:
'''
'''     Dim Expr1 : Expr1 = True ' or returned from a function call
'''     Function Expr2(MyVar1)
'''       MyVar1 = ... ' write into input parameter triggers the issue
'''     End Function
'''     If Expr1 Or Expr2 Then
'''       ... ' code here is potentially corrupted
'''     End If
'''
'''   Example of workarounded code:
'''
'''     Dim Expr1 : Expr1 = True ' or returned from a function call
'''     Function Expr2(MyVar1)
'''       Dim TempVar1 : TempVar1 = MyVar1
'''       TempVar1 = ... ' write into temporary parameter instead
'''     End Function
'''     If Expr1 Or Expr2 Then
'''       ... ' workarounded
'''     End If
'''
'''   Another workaround is to split the `Or` expression in a single `If` by a
'''   sequence of `If`/`ElseIf` conditions.
'''

Function FixStrToPrint(str)
  Dim new_str : new_str = ""
  Dim i, Char, CharAsc

  For i = 1 To Len(str)
    Char = Mid(str, i, 1)
    CharAsc = Asc(Char)

    ' NOTE:
    '   `&H3F` - is not printable unicode origin character which can not pass through the stdout redirection.
    If CharAsc <> &H3F Then
      new_str = new_str & Char
    Else
      new_str = new_str & "?"
    End If
  Next

  FixStrToPrint = new_str
End Function

Sub PrintOrEchoLine(str)
  On Error Resume Next
  WScript.stdout.WriteLine str
  If err = 5 Then ' Access is denied
    WScript.stdout.WriteLine FixStrToPrint(str)
  ElseIf err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

Sub PrintOrEchoErrorLine(str)
  On Error Resume Next
  WScript.stderr.WriteLine str
  If err = 5 Then ' Access is denied
    WScript.stderr.WriteLine FixStrToPrint(str)
  ElseIf err = &h80070006& Then
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
