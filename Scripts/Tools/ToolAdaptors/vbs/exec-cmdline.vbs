''' Call a command line using "<ScriptName>.cmdline" file to build it.

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

WScript.Quit shell_obj.Run(cmdline, 1, True)
