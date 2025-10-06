''' Reads a binary file MSI summary PID_TEMPLATE.
''' Can check MSI package bitness.

''' USAGE:
'''   read_msi_summary_template.vbs <FilePath>

''' DESCRIPTION:
'''   <FilePath>
'''     Path to binary file to read.

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

Function GetFile(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  If Not Left(PathAbs, 4) = "\\?\" Then
    Set GetFile = objFS.GetFile("\\?\" & PathAbs)
  Else
    Set GetFile = objFS.GetFile(PathAbs)
  End If
End Function

Function GetFolder(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFolder` error: `Path not found`.
  If Not Left(PathAbs, 4) = "\\?\" Then
    Set GetFolder = objFS.GetFolder("\\?\" & PathAbs & "\")
  Else
    Set GetFolder = objFS.GetFolder(PathAbs)
  End If
End Function

Function FileExists(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `FileExists` error: `File not found`.
  If Not Left(PathAbs, 4) = "\\?\" Then
    FileExists = objFS.FileExists("\\?\" & PathAbs)
  Else
    FileExists = objFS.FileExists(PathAbs)
  End If
End Function

Function FolderExists(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `FolderExists` error: `Path not found`.
  If Not Left(PathAbs, 4) = "\\?\" Then
    FolderExists = objFS.FolderExists("\\?\" & PathAbs & "\")
  Else
    FolderExists = objFS.FolderExists(PathAbs)
  End If
End Function

Function FileExistsNoPrefix(PathAbs)
  If Left(PathAbs, 4) = "\\?\" Then
    FileExistsNoPrefix = objFS.FileExists(Mid(PathAbs, 5))
  Else
    FileExistsNoPrefix = objFS.FileExists(PathAbs)
  End If
End Function

Function FolderExistsNoPrefix(PathAbs)
  If Left(PathAbs, 4) = "\\?\" Then
    FolderExistsNoPrefix = objFS.FolderExists(Mid(PathAbs, 5))
  Else
    FolderExistsNoPrefix = objFS.FolderExists(PathAbs)
  End If
End Function

' Detects Win32 Namespace object path.
Function IsWin32NamespaceObjectPath(PathAbs)
  ' NOTE: does not check the drive letter
  If Left(PathAbs, 4) = "\\?\" Then
    If Mid(PathAbs, 6, 1) = ":" And InStr(1, "\/", Mid(PathAbs, 7, 1), vbTextCompare) Then
      IsWin32NamespaceObjectPath = False
    Else
      IsWin32NamespaceObjectPath = True
    End If
  ElseIf Mid(PathAbs, 2, 1) = ":" And InStr(1, "\/", Mid(PathAbs, 3, 1), vbTextCompare) Then
    IsWin32NamespaceObjectPath = False
  ElseIf InStr(1, PathAbs, ":", vbTextCompare) Or InStr(1, PathAbs, "?", vbTextCompare) Or InStr(1, PathAbs, "*", vbTextCompare) Then
    IsWin32NamespaceObjectPath = True
  Else
    IsWin32NamespaceObjectPath = False
  End If
End Function

Function RemoveWin32NamespacePathPrefix(PathAbs)
  ' CAUTION:
  '   Avoid to remove path prefixes started by `\\`:
  '     * UNC: \\domain...
  '     * Volume: \\?\Volume{...
  '
  If Left(PathAbs, 4) = "\\?\" And Mid(PathAbs, 6, 1) = ":" And InStr(1, "\/", Mid(PathAbs, 7, 1), vbTextCompare) Then
    RemoveWin32NamespacePathPrefix = Mid(PathAbs, 5)
  Else
    RemoveWin32NamespacePathPrefix = PathAbs
  End If
End Function

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

If IsEmptyArg(cmd_args, 0) Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <FilePath> is empty"
  WScript.Quit 1
End If

Dim FilePath : FilePath = cmd_args(0)

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

Dim IsObjPath : IsObjPath = IsWin32NamespaceObjectPath(FilePath)

If IsObjPath Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: <FilePath> is not valid:" & vbCrLf & _
    WScript.ScriptName & ": info: FilePath=`" & FilePath & "`"
  WScript.Quit 2
End If

Dim FilePathAbs
Dim IsFileExist
Dim IsFolderExist : IsFolderExist = False

FilePathAbs = objFS.GetAbsolutePathName(FilePath) ' CAUTION: can alter a path character case if path exists

FilePathAbs = RemoveWin32NamespacePathPrefix(FilePathAbs)

' test on path existence including long path
IsFileExist = FileExists(FilePathAbs)
If Not IsFileExist Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: <FilePath> does not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: FilePath=`" & FilePathAbs & "`"
  WScript.Quit 3
End If

Dim FilePathToOpen

' test on long path existence
If FileExistsNoPrefix(FilePathAbs) Then
  ' is not long path
  FilePathToOpen = FilePathAbs
Else
  ' translate into short path

  Dim File : Set File = GetFile(FilePathAbs)
  Dim FileShortPath : FileShortPath = File.ShortPath
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