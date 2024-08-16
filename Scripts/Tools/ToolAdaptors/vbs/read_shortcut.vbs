''' Reads a Windows shortcut file property.

''' CAUTION:
'''   WScript.Shell can not handle all Unicode characters in path properties, including characters in the path to a shortcut file.
'''   Details: https://stackoverflow.com/questions/39365489/how-do-you-keep-diacritics-in-shortcut-paths
'''

''' USAGE:
'''   read_shortcut.vbs
'''     [-u] [-q]
'''     [-E[0 | p]]
'''     [-p <PropertyPattern>]
'''     [--]
'''     <ShortcutFilePath>

''' DESCRIPTION:
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''   -u
'''     Unescape %xx or %uxxxx sequences.
'''   -E
'''     Expand environment variables in all shortcut arguments.
'''   -E0
'''     Expand environment variables only in the first argument.
'''   -Ep
'''     Expand environment variables only in the property object.
'''
'''   -use-getlink | -g
'''     Use `GetLink` property instead of `CreateShortcut` method.
'''     Alternative interface to assign path properties with Unicode characters.
'''   -print-remapped-names | -k
'''     Print remapped key names instead of `CreateShortcut` method object
'''     names.
'''     Has effect if `-use-getlink` flag is used.
'''
'''   -p <PropertyPattern>
'''     List of shortcut property names to read, separated by `|` character.

''' Related resources:
'''   https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-shllink
'''   https://github.com/libyal/liblnk/blob/main/documentation/Windows%20Shortcut%20File%20(LNK)%20format.asciidoc

''' CAUTION:
'''   Base `CreateShortcut` method does not support all Unicode characters.
'''   Use `GetLink` property (`-use-getlink` flag) instead to workaround that.

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

Dim ExpectFlags : ExpectFlags = True

Dim UnescapeAllArgs : UnescapeAllArgs = False

Dim ExpandAllArgs : ExpandAllArgs = False
Dim ExpandArg0 : ExpandArg0 = False
Dim ExpandShortcutProperty : ExpandShortcutProperty = False

Dim UseGetLink : UseGetLink = False
Dim PrintRemappedNames : PrintRemappedNames = False

Dim PropertyPattern

Dim objShell : Set objShell = WScript.CreateObject("WScript.Shell")

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Mid(arg, 1, 1) = "-" Then
      If arg = "-u" Then ' Unescape %xx or %uxxxx
        UnescapeAllArgs = True
      ElseIf arg = "-E" Then ' Expand environment variables in all arguments
        ExpandAllArgs = True
      ElseIf arg = "-E0" Then ' Expand environment variables only in the first argument
        ExpandArg0 = True
      ElseIf arg = "-Ep" Then ' Expand environment variables only in the property object
        ExpandShortcutProperty = True
      ElseIf arg = "-use-getlink" Or arg = "-g" Then
        UseGetLink = True
      ElseIf arg = "-print-remapped-names" Or arg = "-k" Then
        PrintRemappedNames = True
      ElseIf arg = "-p" Then
        i = i + 1
        PropertyPattern = WScript.Arguments(i)
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
    If UnescapeAllArgs Then
      arg = Unescape(arg)
    End If

    If ExpandAllArgs Then
      arg = objShell.ExpandEnvironmentStrings(arg)
    ElseIf ExpandArg0 And j = 0 Then
      arg = objShell.ExpandEnvironmentStrings(arg)
    End If

    cmd_args(j) = arg

    j = j + 1
  End If
Loop While False : Next

ReDim Preserve cmd_args(j - 1)

' MsgBox Join(cmd_args, " ")

Dim cmd_args_ubound : cmd_args_ubound = UBound(cmd_args)

If cmd_args_ubound < 0 Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <ShortcutFilePath> argument is not defined."
  WScript.Quit 1
End If

' functions

Function MakeShortcut(ShortcutFilePathToOpen)
  If Not UseGetLink Then
    ' CAUTION:
    '   Base `CreateShortcut` method does not support all Unicode characters.
    '   Use `GetLink` property (`-use-getlink` flag) instead to workaround that.
    '
    Set MakeShortcut = objShell.CreateShortcut(ShortcutFilePathToOpen)
  Else
    Dim objShellApp : Set objShellApp = CreateObject("Shell.Application")
    Dim ShortcutParentPath : ShortcutParentPath = objFS.GetParentFolderName(ShortcutFilePathToOpen)
    Dim objNamespace, objFile
    If Len(ShortcutParentPath) > 0 Then
      Set objNamespace = objShellApp.Namespace(ShortcutParentPath)
      Set objFile = objNamespace.ParseName(objFS.GetFileName(ShortcutFilePathToOpen))
    Else
      Set objNamespace = objShellApp.Namespace(ShortcutFilePathToOpen)
      Set objFile = objNamespace.Self
    End if

    If IsNothing(objFile) Then
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": error: path is not parsed." & vbCrLf & _
        WScript.ScriptName & ": info: Path=`" & ShortcutFilePathAbs & "`"
      WScript.Quit 128
    End If

    Set MakeShortcut = objFile.GetLink
  End If
End Function

Function GetShortcutProperty(PropertyName)
  Dim PropertyMapName : PropertyMapName = PropertyName

  If UseGetLink Then
    ' remap property name
    If PropertyName = "TargetPath" Then
      PropertyMapName = "Path"
    End If
  End If

  GetShortcutProperty = Eval("objSC." & PropertyMapName)
End Function

Function GetShortcutPropertyName(PropertyName)
  If UseGetLink And PrintRemappedNames Then
    ' remap property name
    If PropertyName = "TargetPath" Then
      PropertyName = "Path"
    End If
  End If

  GetShortcutPropertyName = PropertyName
End Function

Dim ShortcutFilePath : ShortcutFilePath = cmd_args(0)

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

Dim ShortcutFilePathAbs : ShortcutFilePathAbs = objFS.GetAbsolutePathName(ShortcutFilePath) ' CAUTION: can alter a path character case if path exists

' remove `\\?\` prefix
If Left(ShortcutFilePathAbs, 4) = "\\?\" Then
  ShortcutFilePathAbs = Mid(ShortcutFilePathAbs, 5)
End If

' test on path existence including long path
Dim IsShortcutFileExist : IsShortcutFileExist = objFS.FileExists("\\?\" & ShortcutFilePathAbs)
If Not IsShortcutFileExist Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: shortcut file does not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: ShortcutFilePath=`" & ShortcutFilePathAbs & "`"
  WScript.Quit 1
End If

Dim ShortcutFilePathToOpen

' test on long path existence
If objFS.FileExists(ShortcutFilePathAbs) Then
  ' is not long path
  ShortcutFilePathToOpen = ShortcutFilePathAbs
Else
  ' translate into short path

  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  Dim ShortcutFile : Set ShortcutFile = objFS.GetFile("\\?\" & ShortcutFilePathAbs)
  Dim ShortcutFileShortPath : ShortcutFileShortPath = ShortcutFile.ShortPath
  If Left(ShortcutFileShortPath, 4) = "\\?\" Then
    ShortcutFileShortPath = Mid(ShortcutFileShortPath, 5)
  End If

  ShortcutFilePathToOpen = ShortcutFileShortPath
End If

Dim objSC : Set objSC = MakeShortcut(ShortcutFilePathToOpen)

Dim PropertyArr : PropertyArr = Split(PropertyPattern, "|", -1, vbTextCompare)

Dim PropertyArrUbound : PropertyArrUbound = UBound(PropertyArr)

Dim PropertyName, PropertyValue

' MsgBox "Link=" & ShortcutFilePath & vbCrLf & "TargetPath=" & objSC.TargetPath & vbCrLf & "WorkingDirectory=" & objSC.WorkingDirectory

For i = 0 To PropertyArrUbound
  PropertyName = PropertyArr(i)
  PropertyValue = GetShortcutProperty(PropertyName)

  If ExpandShortcutProperty Then
    PropertyValue = objShell.ExpandEnvironmentStrings(PropertyValue)
  End If

  PrintOrEchoLine GetShortcutPropertyName(PropertyName) & "=" & PropertyValue
Next
