''' Read an MSI/MSP file summary all property values.

''' USAGE:
'''   read_msi_summary_all_props.vbs
'''     [-u[rl-encode]]
'''     [-msp]
'''     [--]
'''       <FilePath>

''' DESCRIPTION:
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''
'''   -u[rl-encode]
'''     URL encode property value characters in form of `%NN` in case if
'''     ASCII value < 32 OR > 127 OR = &H25 OR = &H3F, where:
'''       `&H3F` - is not printable unicode origin character which may not pass
'''                through the stdout redirection.
'''       `&H25` - `%`.
'''
'''   -msp
'''     Open <FilePath> as MSP file.
'''
'''   <FilePath>
'''     Path to MSI/MSP file to read.

''' Error codes:
'''   255 - unspecified error
'''   128 - <FilePath> is not WindowsInstaller.Installer object
'''   1   - <FilePath> is not defined or not exist
'''   0   - Success

''' Documentation and samples:
'''   https://learn.microsoft.com/windows/win32/msi/summaryinfo-summaryinfo
'''   https://learn.microsoft.com/windows/win32/msi/windows-installer-scripting-examples (`WiSumInf.vbs` script)
'''   https://github.com/Microsoft/Windows-classic-samples/tree/HEAD/Samples/Win7Samples/sysmgmt/msi/scripts
'''

Function IsNothing(obj)
  If IsEmpty(obj) Then
    IsNothing = True
    Exit Function
  End If
  If obj Is Nothing Then
    IsNothing = True
  Else
    IsNothing = False
  End If
End Function

Function IsEmptyArg(args, index)
  ''' Based on: https://stackoverflow.com/questions/4466967/how-can-i-determine-if-a-dynamic-array-has-not-be-dimensioned-in-vbscript/4469121#4469121
  On Error Resume Next
  Dim args_ubound : args_ubound = UBound(args)
  If Err = 0 Then
    If args_ubound >= index Then
      ' CAUTION:
      '   Must be a standalone condition.
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
        '   Must be a standalone condition.
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

Function GetMsiSummaryInfoPropIndexName(index)
  Select Case index
    Case 0:  GetMsiSummaryInfoPropIndexName = "Dictionary"      ' PID_DICTIONARY: Special format, not support by SummaryInfo object
    Case 1:  GetMsiSummaryInfoPropIndexName = "Codepage"        ' "ANSI codepage of text strings in summary information only"
    Case 2:  GetMsiSummaryInfoPropIndexName = "Title"           ' "Package type, e.g. Installation Database"
    Case 3:  GetMsiSummaryInfoPropIndexName = "Subject"         ' "Product full name or description"
    Case 4:  GetMsiSummaryInfoPropIndexName = "Author"          ' "Creator, typically vendor name"
    Case 5:  GetMsiSummaryInfoPropIndexName = "Keywords"        ' "List of keywords for use by file browsers"
    Case 6:  GetMsiSummaryInfoPropIndexName = "Comments"        ' "Description of purpose or use of package"
    Case 7:  GetMsiSummaryInfoPropIndexName = "Template"        ' "Target system: Platform(s);Language(s)"
    Case 8:  GetMsiSummaryInfoPropIndexName = "LastAuthor"      ' "Used for transforms only: New target: Platform(s);Language(s)"
    Case 9:  GetMsiSummaryInfoPropIndexName = "Revision"        ' "Package code GUID, for transforms contains old and new info"
    Case 10: GetMsiSummaryInfoPropIndexName = "Edited"          '
    Case 11: GetMsiSummaryInfoPropIndexName = "Printed"         ' "Date and time of installation image, same as Created if CD"
    Case 12: GetMsiSummaryInfoPropIndexName = "Created"         ' "Date and time of package creation"
    Case 13: GetMsiSummaryInfoPropIndexName = "Saved"           ' "Date and time of last package modification"
    Case 14: GetMsiSummaryInfoPropIndexName = "Pages"           ' "Minimum Windows Installer version required: Major * 100 + Minor"
    Case 15: GetMsiSummaryInfoPropIndexName = "Words"           ' "Source flags: 1=short names, 2=compressed, 4=network image"
    Case 16: GetMsiSummaryInfoPropIndexName = "Characters"      ' "Used for transforms only: validation and error flags"
    Case 17: GetMsiSummaryInfoPropIndexName = "Thumbnail"       '
    Case 18: GetMsiSummaryInfoPropIndexName = "Application"     ' "Application associated with file, ""Windows Installer"" for MSI"
    Case 19: GetMsiSummaryInfoPropIndexName = "Security"        ' "0=Read/write 1=Readonly recommended 2=Readonly enforced"

    Case Else: GetMsiSummaryInfoPropIndexName = ""
  End Select
End Function

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim UrlEncode : UrlEncode = False
Dim OpenAsMSP : OpenAsMSP = False

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Mid(arg, 1, 1) = "-" Then
      If arg = "-url-encode" Or arg = "-u" Then
        UrlEncode = True
      ElseIf arg = "-msp" Then
        OpenAsMSP = True
      Else
        PrintOrEchoErrorLine WScript.ScriptName & ": error: unknown flag: `" & arg & "`"
        WScript.Quit 255
      End If
    Else
      ExpectFlags = False

      If arg = "--" Then Exit Do
    End If
  End If

  If Not ExpectFlags Then
    cmd_args(j) = arg

    j = j + 1
  End If
Loop While False : Next

ReDim Preserve cmd_args(j - 1)

' MsgBox Join(cmd_args, " ")

If IsEmptyArg(cmd_args, 0) Then
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

' create installer object
Dim objInstaller : Set objInstaller = CreateObject("WindowsInstaller.Installer")
Dim objMsiDB

Const MSIOPENDATABASEMODE_PATCHFILE = 32

' open msi in read-only mode
If Not OpenAsMSP Then
  Set objMsiDB = objInstaller.OpenDatabase(FilePathToOpen, 0)
Else
  Set objMsiDB = objInstaller.OpenDatabase(FilePathToOpen, MSIOPENDATABASEMODE_PATCHFILE)
End If

If IsNothing(objMsiDB) Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: file path is not parsed." & vbCrLf & _
    WScript.ScriptName & ": info: FilePath=`" & FilePathAbs & "`"
  WScript.Quit 128
End If

Dim objMsiDBStream : Set objMsiDBStream = objMsiDB.SummaryInformation(0) ' 0 = read only

Dim LastError

Dim FilePropName, FilePropValue, FilePropEncodedValue, Char, CharAsc, CharHex
Dim FilePropIndex : FilePropIndex = 0
Dim FilePropIndexStr

' 99 - maximum
For FilePropIndex = 0 To 99 : Do ' empty `Do-Loop` to emulate `Continue`
  On Error Resume Next
  FilePropValue = objMsiDBStream.Property(FilePropIndex)
  LastError = Err
  On Error Goto 0

  If LastError = &h80004005& Then ' E_FAIL
    Exit Do ' continue on unexisted property index
  End If

  If Not (Len(FilePropValue) > 0) Then Exit Do ' continue on empty property name

  FilePropName = GetMsiSummaryInfoPropIndexName(FilePropIndex)

  ' CAUTION:
  '   `Len(...) > 0` is not equal here to `Not IsEmpty(...)`:
  '   https://stackoverflow.com/questions/40600276/using-empty-vs-to-define-or-test-a-variable-in-vbscript/40600539#40600539
  '
  FilePropIndexStr = CStr(FilePropIndex)

  If UrlEncode Then
    FilePropEncodedValue = ""

    For i = 1 To Len(FilePropValue)
      Char = Mid(FilePropValue, i, 1)
      CharAsc = Asc(Char)

      ' NOTE:
      '   `&H3F` - is not printable unicode origin character which may not pass through the stdout redirection.
      '   `&H25` - `%`.
      If CharAsc < 32 Or CharAsc > 127 Or CharAsc = &H25 Or CharAsc = &H3F Then
        CharHex = Hex(CharAsc)
        FilePropEncodedValue = FilePropEncodedValue & "%" & Left("00", 2 - Len(CStr(CharHex))) & CStr(CharHex)
      Else
        FilePropEncodedValue = FilePropEncodedValue & Char
      End If
    Next

    FilePropValue = FilePropEncodedValue
  End If

  PrintOrEchoLine "[" & Left("000", 3 - Len(FilePropIndexStr)) & FilePropIndexStr & "] " & FilePropName & "=`" & FilePropValue & "`"
Loop While False : Next
