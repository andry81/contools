''' Gets short file path.

''' USAGE:
'''   get_shortfilepath.vbs <path>

''' NOTE:
'''   This script does not require the Adminitrator privileges.
'''

''' CAUTION:
'''   The file or directory must have has the short file name otherwise the
'''   script will return the long path.

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
On Error Goto 0

If Not (Len(Path) > 0) Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: path is empty."
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

If IsFileExist Then
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  Dim File : Set File = objFS.GetFile("\\?\" & PathAbs)
  Dim FileShortPath : FileShortPath = File.ShortPath
  If Left(FileShortPath, 4) = "\\?\" Then
    FileShortPath = Mid(FileShortPath, 5)
  End If

  PrintOrEchoLine FileShortPath

  WScript.Quit 0
ElseIf IsFolderExist Then ' just in case
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFolder` error: `Path not found`.
  Dim Folder : Set Folder = objFS.GetFolder("\\?\" & PathAbs & "\")
  Dim FolderShortPath : FolderShortPath = Folder.ShortPath
  If Left(FolderShortPath, 4) = "\\?\" Then
    FolderShortPath = Mid(FolderShortPath, 5)
  End If

  PrintOrEchoLine FolderShortPath

  WScript.Quit 0
End If

WScript.Quit 1
