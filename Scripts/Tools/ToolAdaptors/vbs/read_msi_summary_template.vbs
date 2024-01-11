''' Read a binary file MSI summary PID_TEMPLATE.

''' USAGE:
'''   read_msi_summary_template.vbs <FilePath>

''' DESCRIPTION:
'''   <FilePath>
'''     Path to binary file to read.

' Can check if an MSI package has 32 bit (x86) or 64 bit (x64) bitness.

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

' create installer object
Dim objInstaller : Set objInstaller = CreateObject("WindowsInstaller.Installer")

' open msi in read-only mode
Dim objMsiDB : Set objMsiDB = objInstaller.OpenDatabase(FilePathToOpen, 0)

Dim objMsiDBStream : Set objMsiDBStream = objMsiDB.SummaryInformation(0) ' 0 = read only

' Details: https://learn.microsoft.com/en-us/windows/win32/msi/template-summary

' read PID_TEMPLATE (template summary)
PrintOrEchoLine objMsiDBStream.Property(7)

' For an installation package, the Template Summary property indicates the
' platform and language versions that are compatible with this installation
' database. The syntax of the Template Summary property information for an
' installation database is the following:
'
' [platform property];[language id][,language id][,...].
'
' The following examples are valid values for the Template Summary property:
'
'     x64;1033
'     Intel;1033
'     Intel64;1033
'     ;1033
'     Intel ;1033,2046
'     Intel64;1033,2046
'     Intel;0
'     Arm;1033,2046
'     Arm;0
'     Arm64;1033,2046
'     Arm64;0
'
' The Template Summary property of a transform indicates the platform and
' language versions compatible with the transform. In a transform file, only
' one language may be specified. The specified platform and language determine
' whether a transform can be applied to a particular database. The platform
' property and the language property can be left blank if no transform
' restriction relies on them to validate the transform.
'
' The Template Summary property of a patch package is a semicolon-delimited
' list of the product codes that can accept the patch. If you use Msimsp.exe
'  and Patchwiz.dll to generate the patch package, this list is obtained from
' the TargetImages table of the patch creation file.
'
' This summary property is required.
' Remarks
'
' If the current platform does not match one of the platforms specified in the
' Template Summary property then the installer does not process the package.
'
' If the platform specification is missing in the Template Summary property
' value, the installer assumes the Intel architecture.
'
' If this is a 64-bit Windows Installer package being run on an Intel64
' (Itanium) platform, enter Intel64 in the Template Summary property.
'
' If this is a 64-bit Windows Installer package being run on a x64 platform,
' enter x64 in the Template Summary property.
'
' If this is a 64-bit Windows Installer package being run on an Arm64 platform,
' enter Arm64 in the Template Summary property.
'
' A Windows Installer package cannot be marked as supporting both Intel64 and
' x64; for example, the Template Summary property value of Intel64,x64 is
' invalid.
'
' A Windows Installer package cannot be marked as supporting both 32-bit and
' 64-bit platforms; for example, Template Summary property values such as
' Intel,x64 or Intel,Intel64 are invalid.
'
' Entering 0 (zero) in the language ID field of the Template Summary property,
' or leaving this field empty, indicates that the package is language neutral.
'
' If this is a Windows Installer package being run on Windows RT, enter the
' value Arm in the Template Summary property.
'
' Merge Modules are the only packages that may have multiple languages. Only
' one language can be specified in a source installer database.
' For more information, see Multiple Language Merge Modules.
'
' The Alpha platform is not supported by Windows Installer.
'
' Windows Installer: The following syntax is not supported:
'
' [platform property][,platform property][,...][language id][,language id][,...].
'
' The following examples are not valid values for the Template Summary property:
'
'     Alpha,Intel;1033
'     Intel,Alpha;1033
'     Alpha;1033
'     Alpha;1033,2046
'