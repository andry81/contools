''' Sets short file name.

''' USAGE:
'''   set_shortfilename.vbs <path> <short-file-name>

''' CAUTION:
'''   This script requires the Adminitrator privileges to request below privileges.

''' CAUTION:
'''   The script process must be a 32-bit process to create `jcb.tools` object.

'' The privileges request example though the WMI.
''
'' CAUTION:
''   Works only for the object in a wsh host process, not for the process itself.
''
'Dim objWMIService  : Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate, (Restore,Backup)}")

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

On Error Resume Next
Dim Path : Path = WScript.Arguments(0)
Dim ShortFileName : ShortFileName = WScript.Arguments(1)
On Error Goto 0

If Not (Len(Path) > 0) Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: path is empty."
  WScript.Quit 255
End If

If Not (Len(ShortFileName) > 0) Or Len(ShortFileName) > 8 Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: short file name is empty or longer than 8 characters:" & vbCrLf & _
    WScript.ScriptName & ": info: ShortFileName=`" & ShortFileName & "`"
  WScript.Quit 255
End If

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

Dim PathAbs : PathAbs = objFS.GetAbsolutePathName(Path) ' CAUTION: can alter a path character case if path exists

' remove `\\?\` prefix
If Left(PathAbs, 4) = "\\?\" Then
  PathAbs = Mid(PathAbs, 5)
End If

' test on path existence including long path
Dim IsFileExist : IsFileExist = objFS.FileExists("\\?\" & PathAbs)
Dim IsFolderExist : IsFolderExist = False
If Not IsFileExist Then
  IsFolderExist = objFS.FolderExists("\\?\" & PathAbs)
End If
If (Not IsFileExist) And (Not IsFolderExist) Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: path does not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & PathAbs & "`"
  WScript.Quit 255
End If

' requires `bellamyjc--jcb-ocx/_externals/20150119/bin/jcb.ocx` as already registered
On Error Resume Next
set objJcbTools = wscript.CreateObject("jcb.tools", "event_")
If err <> 0 Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: CreateObject is failed:" & vbCrLf & _
    WScript.ScriptName & ": info: Error=`" & CStr(err) & "` (0x" & Hex(err) & ")" & vbCrLf & _
    WScript.ScriptName & ": info: Description: `" & err.Description & "`"
  WScript.Quit 255
End If
On Error Goto 0

objJcbTools.SetPrivileges

' To check wsh host process privileges
'MsgBox "Wait..."

' requires `Utilities/bin/wshbazaar/wshdynacall/wshdynacall32.dll` as already registered
On Error Resume Next
Dim dynacall : Set dynacall = CreateObject("DynamicWrapper")
If err <> 0 Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: CreateObject is failed:" & vbCrLf & _
    WScript.ScriptName & ": info: Error=`" & CStr(err) & "` (0x" & Hex(err) & ")" & vbCrLf & _
    WScript.ScriptName & ": info: Description: `" & err.Description & "`"
  WScript.Quit 255
End If
On Error Goto 0

Const INVLID_HANDLE_VALUE = -1

dynacall.Register "Kernel32.dll", "GetLastError", "f=s", "r=u"
dynacall.Register "Kernel32.dll", "CloseHandle", "i=h", "f=s", "r=l"
dynacall.Register "Kernel32.dll", "CreateFileW", "i=wllhllh", "f=s", "r=h"
dynacall.Register "Kernel32.dll", "SetFileShortNameW", "i=hw", "f=s", "r=u"

Dim bRes, dwLastError

' CreateFileW:            https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilew
' Generic Access Rights:  https://learn.microsoft.com/en-us/windows/win32/secauthz/generic-access-rights
' Generic Access Mask:    https://learn.microsoft.com/en-us/windows/win32/secauthz/access-mask-format
' Access Mask:            https://learn.microsoft.com/en-us/windows/win32/secauthz/access-mask
'
Dim hFile : hFile = dynacall.CreateFileW("\\?\" & PathAbs, &H10000000, 0, Null, 3, &H02000000, Null)
dwLastError = dynacall.GetLastError()

If hFile <> INVLID_HANDLE_VALUE Then
  ' CAUTION:
  '   We must use `CStr(ShortFileName)` or `"" & ShortFileName` expression here to automatically convert input ANSI string into Unicode (UTF16)!
  '
  bRes = dynacall.SetFileShortNameW(hFile, CStr(ShortFileName))
  dwLastError = dynacall.GetLastError()
  dynacall.CloseHandle(hFile)

  If CInt(bRes) = 0 Then
    PrintOrEchoErrorLine _
      WScript.ScriptName & ": error: SetFileShortNameW is failed:" & vbCrLf & _
      WScript.ScriptName & ": info: LastError=`" & CStr(dwLastError) & "` (0x" & Hex(dwLastError) & ")" & vbCrLf & _
      WScript.ScriptName & ": info: Path=`" & PathAbs & "`"
  End If

  ' reread the short file path
  If IsFileExist Then
    ' WORKAROUND:
    '   We use `\\?\` to bypass `GetFile` error: `File not found`.
    Dim File : Set File = objFS.GetFile("\\?\" & PathAbs)
    Dim FileShortPath : FileShortPath = File.ShortPath
    If Left(FileShortPath, 4) = "\\?\" Then
      FileShortPath = Mid(FileShortPath, 5)
    End If

    PrintOrEchoLine FileShortPath
  ElseIf IsFolderExist Then ' just in case
    ' WORKAROUND:
    '   We use `\\?\` to bypass `GetFolder` error: `Path not found`.
    Dim Folder : Set Folder = objFS.GetFolder("\\?\" & PathAbs & "\")
    Dim FolderShortPath : FolderShortPath = Folder.ShortPath
    If Left(FolderShortPath, 4) = "\\?\" Then
      FolderShortPath = Mid(FolderShortPath, 5)
    End If

    PrintOrEchoLine FolderShortPath
  End If

  If Not CInt(bRes) Then
    WScript.Quit 1
  End If

  WScript.Quit 0
End If

PrintOrEchoErrorLine _
  WScript.ScriptName & ": error: CreateFileW is failed:" & vbCrLf & _
  WScript.ScriptName & ": info: LastError=`" & CStr(dwLastError) & "` (0x" & Hex(dwLastError) & ")" & vbCrLf & _
  WScript.ScriptName & ": info: Path=`" & PathAbs & "`" & vbCrLf & _
  WScript.ScriptName & ": note: the process must have has Adminitrator privileges.`"
WScript.Quit -1
