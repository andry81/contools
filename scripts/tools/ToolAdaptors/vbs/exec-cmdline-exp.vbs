''' Calls a command line using "<ScriptName>.cmdline" file to build it.
''' The shell does a built in %-variable expansion for the command line.
'''
''' Detects `%?NN%` character sequences to create respective environment
''' variables to use as ASCII values in `cmd.exe`-like command line expansion.

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

Const ForReading = 1

Dim shell_obj : Set shell_obj = WScript.CreateObject("WScript.Shell")
Dim fso_obj : Set fso_obj = CreateObject("Scripting.FileSystemObject")

Dim script_path_obj : Set script_path_obj = fso_obj.GetFile(Wscript.ScriptFullName)
Dim script_dir : script_dir  = fso_obj.GetParentFolderName(script_path_obj)

Dim cmdline_file : cmdline_file = script_dir & "\" & Wscript.ScriptName & ".cmdline"
Dim cmdline_file_obj

Dim QuoteArg
Dim AlwaysQuoteSeparatorChar : AlwaysQuoteSeparatorChar = ""
Dim AlwaysQuoteSeparatorChars : AlwaysQuoteSeparatorChars = " ,"

Dim IsCmdArg : IsCmdArg = True
Dim cmdline : cmdline = ""
Dim line
Dim i, j

' Load command line from file if exist
If fso_obj.FileExists(cmdline_file) Then
  Set cmdline_file_obj = fso_obj.OpenTextFile(script_dir & "\" & Wscript.ScriptName & ".cmdline", ForReading)

  Do Until cmdline_file_obj.AtEndOfStream
    line = cmdline_file_obj.Readline

    QuoteArg = False
    If InStr(line, Chr(34)) = 0 Then
      If IsCmdArg Or Len(line & "") = 0 Then
        QuoteArg = True
      Else
        QuoteArg = False
        For j = 1 To Len(AlwaysQuoteSeparatorChars)
          AlwaysQuoteSeparatorChar = Mid(AlwaysQuoteSeparatorChars, j, 1)
          If AlwaysQuoteSeparatorChar <> Space(1) Then
            If InStr(line, AlwaysQuoteSeparatorChar) <> 0 Then
              QuoteArg = True
            End If
          Else
            If InStr(line, Space(1)) <> 0 Or InStr(line, vbTab) <> 0 Then ' together with tabulation character
              QuoteArg = True
            End If
          End If
        Next
      End If
    End If

    If IsCmdArg Then
      If "/" = Left(line, 1) Then
        ' is relative to the script directory
        line = fso_obj.GetAbsolutePathName(script_dir & line)
      End If
    End If

    If QuoteArg Then
      line = Chr(34) & line & Chr(34)
    End If

    If Len(cmdline) > 0 Then
      cmdline = cmdline & " " & line
    Else
      cmdline = line
    End If

    If IsCmdArg Then IsCmdArg = False
  Loop
End If

Dim arg

' Append arguments
For i = 0 To WScript.Arguments.Count - 1
  arg = WScript.Arguments(i)

  If InStr(arg, Chr(34)) = 0 Then
    If Len(arg & "") = 0 Then
      QuoteArg = True
    Else
      QuoteArg = False
      For j = 1 To Len(AlwaysQuoteSeparatorChars)
        AlwaysQuoteSeparatorChar = Mid(AlwaysQuoteSeparatorChars, j, 1)
        If AlwaysQuoteSeparatorChar <> Space(1) Then
          If InStr(arg, AlwaysQuoteSeparatorChar) <> 0 Then
            QuoteArg = True
          End If
        Else
          If InStr(arg, Space(1)) <> 0 Or InStr(arg, vbTab) <> 0 Then ' together with tabulation character
            QuoteArg = True
          End If
        End If
      Next
    End If

    If QuoteArg Then
      arg = Chr(34) & arg & Chr(34)
    End If
  End If

  If Len(cmdline) > 0 Then
    cmdline = cmdline & " " & arg
  Else
    cmdline = arg
  End If
Next

' MsgBox cmdline

Dim PrevStr : PrevStr = cmdline
'Dim NextStr
'Dim PrevMatchIndex : PrevMatchIndex = 1
'Dim NextMatchIndex : NextMatchIndex = -1

' detect `%?NN%` character sequences to create respective environment variables to use as ASCII code character place holders in `cmd.exe` like command lines
Dim env_obj : Set env_obj = shell_obj.Environment("Process")

Dim CharHex
Dim Char

Dim objVarPlaceHoldersRE : Set objVarPlaceHoldersRE = New RegExp
objVarPlaceHoldersRE.Global = True
objVarPlaceHoldersRE.Pattern = "%\?[0-9a-zA-Z]{2}%"

Dim objVarPlaceHolderMatches : Set objVarPlaceHolderMatches = objVarPlaceHoldersRE.Execute(PrevStr)

For Each objVarPlaceHolderMatch In objVarPlaceHolderMatches
  'NextMatchIndex = objVarPlaceHolderMatch.FirstIndex + 6
  'WScript.Echo CStr(NextMatchIndex) & " = " & objVarPlaceHolderMatch.Value
  CharHex = Mid(objVarPlaceHolderMatch.Value, 3, 2)
  Char = Chr(CInt("&H" & CharHex))
  env_obj("?" & CharHex) = Char
  'NextStr = NextStr & Mid(PrevStr, PrevMatchIndex, objVarPlaceHolderMatch.FirstIndex + 1 - PrevMatchIndex) & Char
  'PrevMatchIndex = NextMatchIndex
Next

'If PrevMatchIndex > 0 Then
'  NextStr = NextStr & Mid(PrevStr, PrevMatchIndex)
'End If

'WScript.Echo ">" & NextStr

WScript.Quit shell_obj.Run(cmdline, 1, True)
