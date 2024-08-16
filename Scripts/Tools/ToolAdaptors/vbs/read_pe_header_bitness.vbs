''' Read a binary file PE header bitness.

''' USAGE:
'''   read_pe_header_bitness.vbs <FilePath>

''' DESCRIPTION:
'''   <FilePath>
'''     Path to binary file to read.

' Check if a binary (EXE or DLL) is 32 bit (x86) or 64 bit (x64)

' INFO:
'   Workaround to avoid error `runtime error: Type mismatch: 'UBound'` around invalid `Or` condition parse: `If (Not IsArray(arr)) Or UBound(arr) <> ... Then`, where
'   the `UBound(arr)` expression DOES evaluate even if the `arr` expression is not an array object.
Function GetArraySize(arr_obj)
  If IsArray(arr_obj) Then
    GetArraySize = UBound(arr_obj) + 1
  Else
    GetArraySize = 0
  End If
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

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim objShell : Set objShell = WScript.CreateObject("WScript.Shell")

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  ' read command line flags here...

  cmd_args(j) = arg

  j = j + 1
Loop While False : Next

ReDim Preserve cmd_args(j - 1)

' MsgBox Join(cmd_args, " ")

Dim cmd_args_ubound : cmd_args_ubound = UBound(cmd_args)

If cmd_args_ubound < 0 Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <FilePath> argument is not defined."
  WScript.Quit 1
End If

Dim FilePath : FilePath = cmd_args(0)

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

Dim FilePathAbs : FilePathAbs = objFS.GetAbsolutePathName(FilePath) ' CAUTION: can alter a path character case if path exists

' remove `\\?\` prefix
If Left(FilePathAbs, 4) = "\\?\" Then
  FilePathAbs = Mid(FilePathAbs, 5)
End If

' test on path existence including long path
Dim IsFileExist : IsFileExist = objFS.FileExists("\\?\" & FilePathAbs)
If Not IsFileExist Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: file does not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & FilePathAbs & "`"
  WScript.Quit 2
End If

Dim FilePathToOpen

' test on long path existence
If objFS.FileExists(FilePathAbs) Then
  ' is not long path
  FilePathToOpen = FilePathAbs
Else
  ' translate into short path

  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  Dim File_ : Set File_ = objFS.GetFile("\\?\" & FilePathAbs)
  Dim FileShortPath : FileShortPath = File_.ShortPath
  If Left(FileShortPath, 4) = "\\?\" Then
    FileShortPath = Mid(FileShortPath, 5)
  End If

  FilePathToOpen = FileShortPath
End If

Dim BinaryStream : Set BinaryStream = CreateObject("ADODB.Stream")

BinaryStream.Type = 1
BinaryStream.Open

BinaryStream.LoadFromFile FilePathToOpen

Function ByteToHex(byte_)
  Dim str : str = Hex(byte_)
  If Len(str) = 1 Then
    str = "0" & str
  End If
  ByteToHex = str
End Function

Dim PositionHexStr
Dim Position : Position = 0

Dim PeSignature : PeSignature = BinaryStream.Read(3)

Dim ByteCode
Dim PeHexStr

If IsArray(PeSignature) Then
  For i = 0 to UBound(PeSignature)
    ByteCode = Ascb(Midb(PeSignature, i + 1, 1))
    PeHexStr = PeHexStr & ByteToHex(ByteCode)
  Next
Else
  PeHexStr = ""
End If

' compare on `MZђ` sequence
If PeHexStr <> "4D5A90" Then
  PositionHexStr = Hex(Position)
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: invalid PE header (1):" & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & FilePath & "`" & vbCrLf & _
    WScript.ScriptName & ": info: Position=`" & Position & "` (0x" & PositionHexStr & ")" & vbCrLf & _
    WScript.ScriptName & ": info: Bytes=`" & PeHexStr & "`"
  WScript.Quit 3
End If

PositionHexStr = "3C"

On Error Resume Next
Position = CInt("&H" & PositionHexStr)
BinaryStream.Position = Position
If err = &h80070057& Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: invalid PE header (2):" & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & FilePath & "`" & vbCrLf & _
    WScript.ScriptName & ": info: Position=`" & Position & "` (0x" & PositionHexStr & ")"
  WScript.Quit 4
End If
On Error Goto 0

Dim NextPositionHexStr

Dim PositionSignature : PositionSignature = BinaryStream.Read(4)

If IsArray(PositionSignature) Then
  For i = 0 to UBound(PositionSignature)
    ByteCode = Ascb(Midb(PositionSignature, i + 1, 1))
    NextPositionHexStr = ByteToHex(ByteCode) & NextPositionHexStr
  Next
'Else
'  NextPositionHexStr = PositionHexStr ' just in case
End If

If (Not IsArray(PositionSignature)) Or GetArraySize(PositionSignature) <> 4 Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: invalid PE header (3):" & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & FilePath & "`" & vbCrLf & _
    WScript.ScriptName & ": info: Position=`" & Position & "` (0x" & PositionHexStr & ")" & vbCrLf & _
    WScript.ScriptName & ": info: Bytes=`" & NextPositionHexStr & "`"
  WScript.Quit 4
End If

PositionHexStr = NextPositionHexStr

On Error Resume Next
Position = CInt("&H" & PositionHexStr)
BinaryStream.Position = Position
If err = &h80070057& Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: invalid PE header (4):" & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & FilePath & "`" & vbCrLf & _
    WScript.ScriptName & ": info: Position=`" & Position & "` (0x" & PositionHexStr & ")"
  WScript.Quit 4
End If
On Error Goto 0

Dim BitnessSignature : BitnessSignature = BinaryStream.Read(6)

Dim BitnessHexStr

If IsArray(BitnessSignature) Then
  For i = 0 to UBound(BitnessSignature)
    ByteCode = Ascb(Midb(BitnessSignature, i + 1, 1))
    BitnessHexStr = BitnessHexStr & ByteToHex(ByteCode)
  Next
End If

If (Not IsArray(BitnessSignature)) Or GetArraySize(BitnessSignature) <> 6 Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: invalid PE header (5):" & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & FilePath & "`" & vbCrLf & _
    WScript.ScriptName & ": info: Position=`" & Position & "` (0x" & PositionHexStr & ")" & vbCrLf & _
    WScript.ScriptName & ": info: Bytes=`" & BitnessHexStr & "`"
  WScript.Quit 4
End If

BinaryStream.Close

If BitnessHexStr = "504500004C01" Then
  PrintOrEchoLine "32"
ElseIf BitnessHexStr = "504500006486" Then
  PrintOrEchoLine "64"
End If
