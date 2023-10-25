''' Read a Windows shortcut file property.

''' CAUTION:
'''   WScript.Shell can not handle all Unicode characters in path properties, including characters in the path to a shortcut file.
'''   Details: https://stackoverflow.com/questions/39365489/how-do-you-keep-diacritics-in-shortcut-paths
'''

''' USAGE:
'''   read_shortcut.vbs
'''     [-u] [-q]
'''     [-E[0 | t | a]]
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
'''     Expand environment variables in all arguments.
'''   -E0
'''     Expand environment variables only in the first argument.
'''   -Ep
'''     Expand environment variables only in the property object.
'''
'''   -p <PropertyPattern>
'''     List of shortcut property names to read, separated by `|` character.

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

Dim ExpectFlags : ExpectFlags = True

Dim UnescapeAllArgs : UnescapeAllArgs = False

Dim ExpandAllArgs : ExpandAllArgs = False
Dim ExpandArg0 : ExpandArg0 = False
Dim ExpandShortcutProperty : ExpandShortcutProperty = False

Dim PropertyPattern
Dim PropertyArr

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

PropertyArr = Split(PropertyPattern, "|", -1, vbTextCompare)

Dim ShortcutFilePath : ShortcutFilePath = cmd_args(0)

Set objSC = objShell.CreateShortcut(ShortcutFilePath)

Dim PropertyArrUbound : PropertyArrUbound = UBound(PropertyArr)

Dim PropertyName
Dim PropertyValue

' MsgBox "Link=" & ShortcutFilePath & vbCrLf & "TargetPath=" & objSC.TargetPath & vbCrLf & "WorkingDirectory=" & objSC.WorkingDirectory

For i = 0 To PropertyArrUbound
  PropertyName = PropertyArr(i)
  PropertyValue = Eval("objSC." & PropertyName)

  If ExpandShortcutProperty Then
    PropertyValue = objShell.ExpandEnvironmentStrings(PropertyValue)
  End If

  PrintOrEchoLine PropertyName & "=" & PropertyValue
Next
