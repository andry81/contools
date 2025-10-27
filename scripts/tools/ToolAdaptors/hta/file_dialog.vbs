''' Opens the Open File dialog window to request a file path to be returned
''' back into standard output.

''' USAGE:
'''   file_dialog.vbs [--] [<FileFilter> [<FileTypes> [<StartFolder> [<Title>]]]]

''' DESCRIPTION:
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''
'''   <FileFilter>:
'''     File filter in format "*.ext"
'''     (default: "*.*")
'''
'''   <FileTypes>:
'''     File type(s) in format "description (*.ext)|*.ext" or just "*.ext"
'''     (default: "All files (*.*)|*.*")
'''
'''   <StartFolder>:
'''     The Initial folder the dialog will show on opening
'''     (default: current directory)
'''
'''   <Title>:
'''     The caption in the dialog's title bar
'''     (default: "Open")

''' Error codes:
'''   255 - unspecified error
'''   1   - <StartFolder> is defined but not exists
'''   0   - Success

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

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Mid(arg, 1, 1) = "-" Then
      'If arg = "-..." Or arg = "-." Then
      'Else
        PrintOrEchoErrorLine WScript.ScriptName & ": error: unknown flag: `" & arg & "`"
        WScript.Quit 255
      'End If
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

Dim FileFilter, FileTypes, StartFolder, Title

If Not IsEmptyArg(cmd_args, 0) Then
  FileFilter = cmd_args(0)
End If

If Not IsEmptyArg(cmd_args, 1) Then
  FileTypes = cmd_args(1)
End If

If Not IsEmptyArg(cmd_args, 2) Then
  StartFolder = cmd_args(2)
End If

If Not IsEmptyArg(cmd_args, 3) Then
  Title = cmd_args(3)
End If

If Not Len(FileFilter) > 0 Then
  FileFilter = "*.*"
End If

If Not Len(FileTypes) > 0 Then
  FileTypes = "All files (*.*)|*.*"
End If

If Not Len(Title) > 0 Then
  Title = "Open"
End If

If Len(StartFolder) > 0 Then
  Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

  Dim StartFolderAbs : StartFolderAbs = objFS.GetAbsolutePathName(StartFolder) ' CAUTION: can alter a path character case if path exists

  ' remove `\\?\` prefix
  If Left(StartFolderAbs, 4) = "\\?\" Then
    StartFolderAbs = Mid(StartFolderAbs, 5)
  End If

  ' test on path existence including long path
  Dim IsDirExist : IsDirExist = objFS.FolderExists("\\?\" & StartFolderAbs)
  If Not IsDirExist Then
    PrintOrEchoErrorLine _
      WScript.ScriptName & ": error: directory does not exist:" & vbCrLf & _
      WScript.ScriptName & ": info: StartFolder=`" & StartFolderAbs & "`"
    WScript.Quit 1
  End If

  ' test on long path existence
  If Not objFS.FolderExists(StartFolderAbs) Then
    ' translate into short path

    ' WORKAROUND:
    '   We use `\\?\` to bypass `GetFolder` error: `Path not found`.
    Dim Folder : Set Folder = objFS.GetFolder("\\?\" & StartFolderAbs & "\")
    Dim FolderShortPath : FolderShortPath = Folder.ShortPath
    If Left(FolderShortPath, 4) = "\\?\" Then
      FolderShortPath = Mid(FolderShortPath, 5)
    End If

    StartFolderAbs = FolderShortPath
  End If
End If

Dim objShell : Set objShell = WScript.CreateObject("WScript.Shell")

Function ShellExecMshtaFileDlg(FileFilter, FileTypes, StartFolder, Title)
  Dim FileFilter_

  If Len(StartFolder) > 0 Then
    If Not Right(StartFolder, 1) = "\" Then
      FileFilter_ = StartFolder & "\" & FileFilter
    Else
      FileFilter_ = StartFolder & FileFilter
    End If
  Else
    FileFilter_ = FileFilter
  End If

  FileFilter_ = Replace(FileFilter_, "\", "\\")

  ' javascript shell code for stdin
  Dim ShellCode : ShellCode = "var FileFilter='" & FileFilter_ & "';var FileTypes='" & FileTypes & "';var Title='" & Title & "';"

  Dim objShellExec : Set objShellExec = _
    objShell.Exec("""%SystemRoot%\System32\mshta.exe"" " & _
      """about:<object id=d classid=clsid:3050f4e1-98b5-11cf-bb82-00aa00bdce0b></object>" & _
      "<script>moveTo(0,-9999);var objFS = new ActiveXObject('Scripting.FileSystemObject');" & _
        "eval(objFS.GetStandardStream(0).Read(" & Len(ShellCode) & "));" & _
        "function window.onload(){var p=/[^\0]*/;objFS.GetStandardStream(1).Write(p.exec(d.object.openfiledlg(FileFilter, null, FileTypes, Title)));close();}" & _
      "</script><hta:application showintaskbar=no />""")

  ' write shell code
  objShellExec.StdIn.Write ShellCode

  ShellExecMshtaFileDlg = Array(objShellExec.ExitCode, objShellExec.StdOut.ReadAll)
End Function

Dim arrFileDlg : arrFileDlg = ShellExecMshtaFileDlg(FileFilter, FileTypes, StartFolder, Title)

PrintOrEchoLine(arrFileDlg(1))

WScript.Quit arrFileDlg(0)
