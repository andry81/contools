''' Reads a Windows shortcut file property.

''' CAUTION:
'''   WScript.Shell can not handle all Unicode characters in path properties, including characters in the path to a shortcut file.
'''   Details: https://stackoverflow.com/questions/39365489/how-do-you-keep-diacritics-in-shortcut-paths
'''

''' USAGE:
'''   read_shortcut.vbs
'''     [-u] [-q]
'''     [-E[0 | p]]
'''     [-use-getlink | -g] [-print-remapped-names | -k]
'''     [-p <PropertyPattern>]
'''     [--]
'''       <ShortcutFilePath>

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
'''     Alternative interface to assign path properties with Unicode
'''     characters.
'''   -print-remapped-names | -k
'''     Print remapped key names instead of `CreateShortcut` method object
'''     names.
'''     Has no effect if `-use-getlink` flag is not used.
'''
'''   -p <PropertyPattern>
'''     List of shortcut property names to read, separated by `|` character.

''' NOTE:
'''   See more details and examples in the `make_shortcut.vbs` script.

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

Dim ErrNumber, ErrSource, ErrDesc, ErrHelpFile, ErrHelpContext

Function CopyError()
  ErrNumber = Err.Number
  ErrSource = Err.Source
  ErrDesc = Err.Description
  ErrHelpFile = Err.HelpFile
  ErrHelpContext = Err.HelpContext
End Function

Function HasProperty(ObjName, PropertyName)
  On Error Resume Next
  Eval(ObjName & "." & PropertyName)
  If err = 0 Then
    HasProperty = True
    On Error Goto 0
  ElseIf err = 424 Then ' Object required
    HasProperty = False
    On Error Goto 0
  Else
    CopyError()
    On Error Goto 0
    err.Raise ErrNumber, ErrSource, ErrDesc, ErrHelpFile, ErrHelpContext ' rethrow
  End If
End Function

Function GetProperty(ObjName, PropertyName)
  On Error Resume Next
  GetProperty = Eval(ObjName & "." & PropertyName)
  If err = 0 Then
    On Error Goto 0
  ElseIf err = 424 Then ' Object required
    On Error Goto 0
  Else
    CopyError()
    On Error Goto 0
    err.Raise ErrNumber, ErrSource, ErrDesc, ErrHelpFile, ErrHelpContext ' rethrow
  End If
End Function

Function GetObjectProperty(ObjName, PropertyName)
  On Error Resume Next
  Set GetObjectProperty = Eval(ObjName & "." & PropertyName)
  If err = 0 Then
    On Error Goto 0
  ElseIf err = 424 Then ' Object required
    On Error Goto 0
  Else
    CopyError()
    On Error Goto 0
    err.Raise ErrNumber, ErrSource, ErrDesc, ErrHelpFile, ErrHelpContext ' rethrow
  End If
End Function

Function IsNothing(obj)
  If IsEmpty(obj) Then
    IsNothing = True
    Exit Function
  End If
  If obj Is Nothing Then ' TypeName(obj) = "Nothing"
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

Function GetFile(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  If Not Left(PathAbs, 4) = "\\?\" Then
    Set GetFile = objFS.GetFile("\\?\" & PathAbs)
  Else
    Set GetFile = objFS.GetFile(PathAbs)
  End If
End Function

'Function GetFolder(PathAbs)
'  ' WORKAROUND:
'  '   We use `\\?\` to bypass `GetFolder` error: `Path not found`.
'  If Not Left(PathAbs, 4) = "\\?\" Then
'    Set GetFolder = objFS.GetFolder("\\?\" & PathAbs & "\")
'  Else
'    Set GetFolder = objFS.GetFolder(PathAbs)
'  End If
'End Function

Function FileExists(PathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `FileExists` error: `File not found`.
  If Not Left(PathAbs, 4) = "\\?\" Then
    FileExists = objFS.FileExists("\\?\" & PathAbs)
  Else
    FileExists = objFS.FileExists(PathAbs)
  End If
End Function

'Function FolderExists(PathAbs)
'  ' WORKAROUND:
'  '   We use `\\?\` to bypass `FolderExists` error: `Path not found`.
'  If Not Left(PathAbs, 4) = "\\?\" Then
'    FolderExists = objFS.FolderExists("\\?\" & PathAbs & "\")
'  Else
'    FolderExists = objFS.FolderExists(PathAbs)
'  End If
'End Function

Function FileExistsNoPrefix(PathAbs)
  If Left(PathAbs, 4) = "\\?\" Then
    FileExistsNoPrefix = objFS.FileExists(Mid(PathAbs, 5))
  Else
    FileExistsNoPrefix = objFS.FileExists(PathAbs)
  End If
End Function

'Function FolderExistsNoPrefix(PathAbs)
'  If Left(PathAbs, 4) = "\\?\" Then
'    FolderExistsNoPrefix = objFS.FolderExists(Mid(PathAbs, 5))
'  Else
'    FolderExistsNoPrefix = objFS.FolderExists(PathAbs)
'  End If
'End Function

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

Function GetParentFolderName(PathAbs)
  If IsWin32NamespaceObjectPath(PathAbs) Then
    Dim ParentPathAbs : ParentPathAbs = objFS.GetParentFolderName(PathAbs)
    If Len(ParentPathAbs) > 0 Then
      If Left(ParentPathAbs, 4) <> "\\?\" Then
        GetParentFolderName = "\\?\" & ParentPathAbs ' restores `\\?\` prefix
      Else
        GetParentFolderName = ParentPathAbs
      End If
    Else
      GetParentFolderName = PathAbs ' parent of an object string root is the object string root
    End If
  Else
    GetParentFolderName = objFS.GetParentFolderName(PathAbs) ' can be empty
  End If
End Function

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

If IsEmptyArg(cmd_args, 0) Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <ShortcutFilePath> is empty."
  WScript.Quit 255
End If

' additional functions

Function GetShortcut(ShortcutFilePathToOpen)
  If Not UseGetLink Then
    ' CAUTION:
    '   Base `CreateShortcut` method does not support all Unicode characters.
    '   Use `GetLink` property (`-use-getlink` flag) instead to workaround that.
    '
    Set GetShortcut = objShell.CreateShortcut(ShortcutFilePathToOpen)
  Else
    Dim objShellApp : Set objShellApp = CreateObject("Shell.Application")
    Dim ShortcutParentPath : ShortcutParentPath = GetParentFolderName(ShortcutFilePathToOpen)
    Dim objNamespace, objFile
    If Len(ShortcutParentPath) > 0 Then
      Set objNamespace = objShellApp.Namespace(ShortcutParentPath)
      If Not IsNothing(objNamespace) Then
        Set objFile = objNamespace.ParseName(objFS.GetFileName(ShortcutFilePathToOpen))
      End If
    Else
      Set objNamespace = objShellApp.Namespace(ShortcutFilePathToOpen)
      If Not IsNothing(objNamespace) Then
        If HasProperty("objNamespace", "Self") Then
          Set objFile = objNamespace.Self
        Else
          objFile = GetObjectProperty("objNamespace", "Items().Item()")
        End If
      End If
    End if

    If IsNothing(objFile) Then
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": error: <Path> is not parsed." & vbCrLf & _
        WScript.ScriptName & ": info: Path=`" & ShortcutFilePathToOpen & "`"
      WScript.Quit 128
    End If

    If objFile.IsLink Then
      Set GetShortcut = objFile.GetLink
    Else
      PrintOrEchoErrorLine _
        WScript.ScriptName & ": error: <Path> is not a shortcut." & vbCrLf & _
        WScript.ScriptName & ": info: Path=`" & ShortcutFilePathToOpen & "`"
      WScript.Quit 129
    End If
  End If
End Function

Function GetShortcutProperty(PropertyName)
  Dim PropertyName_ : PropertyName_ = PropertyName

  If UseGetLink Then
    ' remap property name
    If PropertyName = "TargetPath" Then
      PropertyName_ = "Path"
    ElseIf PropertyName = "TargetArgs" Then ' alternative name
      PropertyName_ = "Arguments"
    ElseIf PropertyName = "WindowStyle" Then
      PropertyName_ = "ShowCommand"
    End If

    If Not (PropertyName_ = "IconLocation") Then
      GetShortcutProperty = Eval("objSC." & PropertyName_)
    Else
      GetShortcutProperty = objSC.Path & "," & objSC.GetIconLocation(objSC.Path)
    End If
  Else
    GetShortcutProperty = Eval("objSC." & PropertyName_)
  End If
End Function

Function GetShortcutPropertyNameToPrint(PropertyName)
  Dim PropertyName_ : PropertyName_ = PropertyName

  If UseGetLink And PrintRemappedNames Then
    ' remap property name
    If PropertyName = "TargetPath" Then
      PropertyName_ = "Path"
    ElseIf PropertyName = "TargetArgs" Then ' alternative name
      PropertyName_ = "Arguments"
    ElseIf PropertyName = "WindowStyle" Then
      PropertyName_ = "ShowCommand"
    End If
  End If

  GetShortcutPropertyNameToPrint = PropertyName_
End Function

Dim ShortcutFilePath : ShortcutFilePath = cmd_args(0)

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

Dim IsObjPath : IsObjPath = IsWin32NamespaceObjectPath(ShortcutFilePath)

If IsObjPath Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: <Path> is not valid:" & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & ShortcutFilePath & "`"
  WScript.Quit 10
End If

Dim ShortcutFilePathAbs : ShortcutFilePathAbs = objFS.GetAbsolutePathName(ShortcutFilePath) ' CAUTION: can alter a path character case if path exists

ShortcutFilePathAbs = RemoveWin32NamespacePathPrefix(ShortcutFilePathAbs)

' test on path existence including long path
Dim IsShortcutFileExist : IsShortcutFileExist = FileExists(ShortcutFilePathAbs)
If Not IsShortcutFileExist Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: <Path> does not exist:" & vbCrLf & _
    WScript.ScriptName & ": info: Path=`" & ShortcutFilePathAbs & "`"
  WScript.Quit 11
End If

Dim ShortcutFilePathToOpen

' test on long path existence
If FileExistsNoPrefix(ShortcutFilePathAbs) Then
  ' is not long path
  ShortcutFilePathToOpen = ShortcutFilePathAbs
Else
  ' translate into short path

  Dim ShortcutFile : Set ShortcutFile = GetFile(ShortcutFilePathAbs)
  Dim ShortcutFileShortPath : ShortcutFileShortPath = ShortcutFile.ShortPath
  If Left(ShortcutFileShortPath, 4) = "\\?\" Then
    ShortcutFileShortPath = Mid(ShortcutFileShortPath, 5)
  End If

  ShortcutFilePathToOpen = ShortcutFileShortPath
End If

Dim objSC : Set objSC = GetShortcut(ShortcutFilePathToOpen)

Dim PropertyArr : PropertyArr = Split(PropertyPattern, "|", -1, vbTextCompare)

Dim PropertyArrUbound : PropertyArrUbound = UBound(PropertyArr)

Dim PropertyName, PropertyValue

' MsgBox "Link=" & ShortcutFilePath & vbCrLf & GetShortcutPropertyNameToPrint("TargetPath") & "=" & GetShortcutProperty("TargetPath") & vbCrLf & "WorkingDirectory=" & objSC.WorkingDirectory

For i = 0 To PropertyArrUbound
  PropertyName = PropertyArr(i)
  PropertyValue = GetShortcutProperty(PropertyName)

  If ExpandShortcutProperty Then
    PropertyValue = objShell.ExpandEnvironmentStrings(PropertyValue)
  End If

  PrintOrEchoLine GetShortcutPropertyNameToPrint(PropertyName) & "=" & PropertyValue
Next
