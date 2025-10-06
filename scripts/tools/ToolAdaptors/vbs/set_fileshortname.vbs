''' Sets short file name.

''' USAGE:
'''   set_shortfilename.vbs <path> <short-file-name>

''' CAUTION:
'''   This script requires the Administrator privileges to request below privileges.

''' CAUTION:
'''   The script process must be a 32-bit process to create `jcb.tools` object.

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

'' The privileges request example though the WMI.
''
'' CAUTION:
''   Works only for the object in a wsh host process, not for the process itself.
''
'Dim objWMIService  : Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate, (Restore,Backup)}")

Function IsEmptyArg(args, index)
  ''' Based on: https://stackoverflow.com/questions/4466967/how-can-i-determine-if-a-dynamic-array-has-not-be-dimensioned-in-vbscript/4469121#4469121
  On Error Resume Next
  Dim args_ubound : args_ubound = UBound(args)
  If Err = 0 Then
    If args_ubound >= index Then
      ' CAUTION:
      '   Must be a stand alone condition.
      '   Must be negative condition in case of an invalid `index`
      If Not (Len(args(index)) > 0) Then
        IsEmptyArg = True
      Else
        IsEmptyArg = False
      End If
    Else
      IsEmptyArg = True
    End If
  Else
    ' Workaround for `WScript.Arguments`
    Err.Clear
    Dim num_args : num_args = args.count
    If Err = 0 Then
      If index < num_args Then
        ' CAUTION:
        '   Must be a stand alone condition.
        '   Must be negative condition in case of an invalid `index`
        If Not (Len(args(index)) > 0) Then
          IsEmptyArg = True
        Else
          IsEmptyArg = False
        End If
      Else
        IsEmptyArg = True
      End If
    Else
      IsEmptyArg = True
    End If
  End If
  On Error Goto 0
End Function

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

If IsEmptyArg(WScript.Arguments, 0) Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: <path> is empty."
  WScript.Quit 255
End If

Dim Path : Path = WScript.Arguments(0)

Dim ShortFileName : If Not IsEmptyArg(WScript.Arguments, 1) Then ShortFileName = WScript.Arguments(1)

If Not (Len(ShortFileName) > 0) Or Len(ShortFileName) > 8 Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: <short-file-name> is empty or longer than 8 characters:" & vbCrLf & _
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

' requires `wshbazaar/wshdynacall/wshdynacall32.dll` as already registered (`contools--utils` project)
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
  ElseIf IsFolderExist Then
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
  WScript.ScriptName & ": note: the process must have has Administrator privileges.`"
WScript.Quit -1
