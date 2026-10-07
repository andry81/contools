''' Prints property names and values of all class instances.

''' USAGE:
'''   print_wmi_class_all_obj_props.vbs [--] <ClassName> [<prop>...]

''' Examples:
'''   >
'''   print_wmi_class_all_obj_props.vbs Win32_Volume BlockSize

''' CAUTION:
'''   The `WScript.std[out|err].WriteLine STR` functions has issue with the
'''   last line desynchronization between streams.
'''   To workaround use `WScript.std[out|err].Write STR & vbCrLf` instead.

Function NumArgs(args)
  ''' Based on: https://stackoverflow.com/questions/4466967/how-can-i-determine-if-a-dynamic-array-has-not-be-dimensioned-in-vbscript/4469121#4469121
  On Error Resume Next
  Dim args_ubound : args_ubound = UBound(args)
  If Err = 0 Then
    NumArgs = args_ubound + 1
  Else
    ' Workaround for `WScript.Arguments`
    Err.Clear
    NumArgs = args.count
    If Err <> 0 Then NumArgs = 0
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
  WScript.stdout.Write str & vbCrLf
  If err = 5 Then ' Access is denied
    WScript.stdout.Write FixStrToPrint(str) & vbCrLf
  ElseIf err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

Sub PrintOrEchoErrorLine(str)
  On Error Resume Next
  WScript.stderr.Write str & vbCrLf
  If err = 5 Then ' Access is denied
    WScript.stderr.Write FixStrToPrint(str) & vbCrLf
  ElseIf err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

Function HasProperty(obj, PropName)
  On Error Resume Next

  Dim Value : Value = Eval("obj." & PropName)

  If Err.Number = 0 Then
    HasProperty = True
  Else
    HasProperty = False
  End If

  On Error GoTo 0
End Function

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim arg
Dim i, j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Left(arg, 1) = "-" Then
      PrintOrEchoErrorLine WScript.ScriptName & ": error: unknown flag: `" & arg & "`"
      WScript.Quit 255
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

Dim num_args : num_args = NumArgs(cmd_args)

Dim ClassName : ClassName = WScript.Arguments(0)

Dim objClass : Set objClass = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2:" & ClassName)
Dim objWMI : Set objWMI = GetObject("winmgmts:")
Dim objSet : Set objSet = objWMI.InstancesOf(ClassName)

Dim obj, objClassProp
Dim index, DoPrintProp : index = 0
Dim HasNameProp : HasNameProp = False

For Each objClassProp In objClass.Properties_
  If objClassProp.Name = "Name" Then
    HasNameProp = True
    Exit For
  End If
Next

' On Error Resume Next

For Each obj in objSet
  If HasNameProp Then
    PrintOrEchoLine "[" & index & "][" & obj.Name & "]"
  Else
    PrintOrEchoLine "[" & index & "]"
  End If

  For Each objClassProp In objClass.Properties_
    If num_args > 1 Then
      DoPrintProp = False

      For i = 1 To num_args-1
        If cmd_args(i) = objClassProp.Name Then
          DoPrintProp = True
          Exit For
        End If
      Next
    Else
      DoPrintProp = True
    End If

    If DoPrintProp Then
      On Error Resume Next

      Err.Clear

      PrintOrEchoLine objClassProp.Name & "=" & Eval("obj." & objClassProp.Name)

      If Err.Number <> 0 Then
        ' print `<error>` on value query error
        PrintOrEchoLine objClassProp.Name & "=<error>"
      End If

      On Error GoTo 0
    End If
  Next

  PrintOrEchoLine ""

  index = index + 1
Next
