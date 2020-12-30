Dim cmd_arg
Dim param_args
If WScript.Arguments.Count > 1 Then
  ReDim param_args(WScript.Arguments.Count - 2)
End If

Dim ExpectFlags : ExpectFlags = True
Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim Verb : Verb = "open"
Dim ShowAs : ShowAs = 1
Dim ExpandArgs : ExpandArgs = False
Dim AlwaysQuote : AlwaysQuote = False
Dim NoWindow : NoWindow = False

Dim arg
Dim IsCmdArg : IsCmdArg = True
Dim i, j : j = 0

Set objShell = WScript.CreateObject("WScript.Shell")
Dim objWinShell : Set objWinShell = WScript.CreateObject("Shell.Application")

For i = 0 To WScript.Arguments.Count-1
  If ExpectFlags Then
    If Mid(WScript.Arguments(i), 1, 1) = "-" Then
      If WScript.Arguments(i) = "-D" Then ' Change current directory
        i = i + 1
        ChangeCurrentDirectory =  WScript.Arguments(i)
      ElseIf WScript.Arguments(i) = "-verb" Then ' Shell Verb
        i = i + 1
        Verb = WScript.Arguments(i)
      ElseIf WScript.Arguments(i) = "-showas" Then ' Show window as
        i = i + 1
        ShowAs = CInt(WScript.Arguments(i))
      ElseIf WScript.Arguments(i) = "-E" Then ' Expand environment variables
        ExpandArgs = True
      ElseIf WScript.Arguments(i) = "-q" Then ' Always quote arguments (if already has no quote characters)
        AlwaysQuote = True
      ElseIf WScript.Arguments(i) = "-nowindow" Then
        NoWindow = True
      End If
    Else
      ExpectFlags = False
    End If
  End If

  If Not ExpectFlags Then
    If Not ExpandArgs Then
      arg = WScript.Arguments(i)
      If InStr(arg, Chr(34)) = 0 Then
        If AlwaysQuote Or Len(arg & "") = 0 Or InStr(arg, Space(1)) <> 0 Or InStr(arg, vbTab) <> 0 Then
          arg = Chr(34) & arg & Chr(34)
        End If
      End If
    Else
      arg = objShell.ExpandEnvironmentStrings(WScript.Arguments(i))
      If InStr(arg, Chr(34)) = 0 Then
        If AlwaysQuote Or Len(arg & "") = 0 Or InStr(arg, Space(1)) <> 0 Or InStr(arg, vbTab) <> 0 Then
          arg = Chr(34) & arg & Chr(34)
        End If
      End If
    End If

    If Not IsCmdArg Then
      param_args(j) = arg
      j = j + 1
    Else
      cmd_arg = arg
      IsCmdArg = False
    End If
  End If
Next

If NoWindow Then ShowAs = 0

ReDim Preserve param_args(j - 1)

' MsgBox cmd_arg & " " & Join(param_args, " ")

objWinShell.ShellExecute cmd_arg, Join(param_args, " "), ChangeCurrentDirectory, Verb, ShowAs
