''' Read a binary file PE header bitness.

''' USAGE:
'''   read_pe_header_bitness.vbs <FilePath>

''' DESCRIPTION:
'''   <FilePath>
'''     Path to binary file to read.

' Check if a binary (EXE or DLL) is 32 bit (x86) or 64 bit (x64)

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
    WScript.ScriptName & ": info: FilePath=`" & FilePathAbs & "`"
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

Dim PeSignature : PeSignature = BinaryStream.Read(3)

Dim ByteCode
Dim PeHexStr

For i = 0 to UBound(PeSignature)
  ByteCode = Ascb(Midb(PeSignature, i + 1, 1))
  PeHexStr = PeHexStr & ByteToHex(ByteCode)
Next

rem compare on `MZђ` sequence
If PeHexStr <> "4D5A90" Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: file has no PE header:" & vbCrLf & _
    WScript.ScriptName & ": info: FilePath=`" & FilePath & "`"
  WScript.Quit 3
End If

BinaryStream.Position = &H3C
Dim PositionSignature : PositionSignature = BinaryStream.Read(4)

Dim PositionHexStr

For i = 0 to UBound(PositionSignature)
    ByteCode = Ascb(Midb(PositionSignature, i + 1, 1))
    PositionHexStr = ByteToHex(ByteCode) & PositionHexStr
Next

BinaryStream.Position = CInt("&H" & PositionHexStr)

Dim BitnessSignature : BitnessSignature = BinaryStream.Read(6)

Dim BitnessHexStr

For i = 0 to UBound(BitnessSignature)
    ByteCode = Ascb(Midb(BitnessSignature, i + 1, 1))
    BitnessHexStr = BitnessHexStr & ByteToHex(ByteCode)
Next

BinaryStream.Close

If BitnessHexStr = "504500004C01" Then
  PrintOrEchoLine "32"
ElseIf BitnessHexStr = "504500006486" Then
  PrintOrEchoLine "64"
End If
