Sub GrowArr(arr, size)
    Dim reserve : reserve = UBound(arr) + 1
    If reserve < size Then
        Do
            If reserve <> 0 Then
                reserve = reserve * 2
            Else
                reserve = 16
            End If
        Loop While reserve < size
        ReDim Preserve arr(reserve - 1) ' upper bound instead of reserve size
    End If
End Sub

Function ReplaceStringArr(str, str_len, str_replace_arr_size, from_str_replace_arr, to_str_replace_arr)
  Dim escaped_str
  Dim str_to_replace, from_str_replace, from_str_replace_len
  Dim i, j, is_found_replace_str

  If str_replace_arr_size > 0 Then
    escaped_str = ""

    For i = 1 To str_len
      is_found_replace_str = False

      For j = 0 To str_replace_arr_size - 1
        from_str_replace = from_str_replace_arr(j)
        from_str_replace_len = Len(from_str_replace)

        str_to_replace = Mid(str, i, from_str_replace_len)

        If from_str_replace = str_to_replace Then
          escaped_str = escaped_str & to_str_replace_arr(j)
          i = i + from_str_replace_len - 1
          is_found_replace_str = True
          Exit For
        End If
      Next

      If Not is_found_replace_str Then
        escaped_str = escaped_str & Mid(str, i, 1)
      End IF
    Next
  Else
    escaped_str = str
  End If

  ReplaceStringArr = escaped_str
End Function

Dim cmd_arg
Dim param_args : param_args = Array()
If WScript.Arguments.Count > 1 Then
  ReDim param_args(WScript.Arguments.Count - 2)
End If

Dim ExpectFlags : ExpectFlags = True

Dim UnescapeAllArgs : UnescapeAllArgs = False
Dim UnescapeArgs : UnescapeArgs = Array()
Dim UnescapeArgs_size : UnescapeArgs_size = 0

Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim Verb : Verb = "open"
Dim ShowAs : ShowAs = 1

Dim ExpandAllArgs : ExpandAllArgs = False
Dim ExpandArg0 : ExpandArg0 = False
Dim ExpandTailArgs : ExpandTailArgs = False

Dim AlwaysQuote : AlwaysQuote = False
Dim AlwaysQuoteTailPosParams : AlwaysQuoteTailPosParams = False

Dim NoWindow : NoWindow = False
Dim MakeTempDirAsCWD : MakeTempDirAsCWD = ""
Dim WaitDeleteCWD : WaitDeleteCWD = 0
Dim WaitOnFileExist : WaitOnFileExist = ""

Dim from_str_replace_indexed_arr : from_str_replace_indexed_arr = Array()
Dim to_str_replace_indexed_arr : to_str_replace_indexed_arr = Array()
Dim str_replace_index_arr : str_replace_index_arr = Array()

Dim str_replace_index_arr_size : str_replace_index_arr_size = 0

Dim from_str_replace_arr, to_str_replace_arr, str_replace_arr_size

Dim from_str_expand_arr : from_str_expand_arr = Array()
Dim to_str_expand_arr : to_str_expand_arr = Array()

Dim str_expand_arr_size : str_expand_arr_size = 0

Dim now_obj, timer_obj

Dim shell_obj : Set shell_obj = WScript.CreateObject("WScript.Shell")
Dim winshell_obj : Set winshell_obj = WScript.CreateObject("Shell.Application")
Dim fs_obj : Set fs_obj = CreateObject("Scripting.FileSystemObject")

Dim arg, index
Dim IsCmdArg : IsCmdArg = True
Dim i, j, k : j = 0

For i = 0 To WScript.Arguments.Count - 1
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If Mid(arg, 1, 1) = "-" Then
      If arg = "-u" Then ' Unescape %xx or %uxxxx
        UnescapeAllArgs = True
      ElseIf Left(arg, 2) = "-u" Then
        arg = Mid(arg, 3)
        If IsNumeric(arg) And CDbl(Number) <= 2147483647 And CDbl(Number) >= -2147483648 And CStr(CLng(arg)) = CStr(arg) Then
          UnescapeArgs_size = UnescapeArgs_size + 1
          GrowArr UnescapeArgs, UnescapeArgs_size
          UnescapeArgs(UnescapeArgs_size - 1) = CLng(arg)
        End If
      ElseIf arg = "-D" Then ' Change current directory
        i = i + 1
        ChangeCurrentDirectory =  WScript.Arguments(i)
      ElseIf arg = "-verb" Then ' Shell Verb
        i = i + 1
        Verb = WScript.Arguments(i)
      ElseIf arg = "-showas" Then ' Show window as
        i = i + 1
        ShowAs = CInt(WScript.Arguments(i))
      ElseIf arg = "-E" Then ' Expand environment variables in all arguments
        ExpandAllArgs = True
      ElseIf arg = "-E0" Then ' Expand environment variables only in the first argument
        ExpandArg0 = True
      ElseIf arg = "-Ea" Then ' Expand environment variables only in the tail arguments
        ExpandTailArgs = True
      ElseIf arg = "-q" Then ' Always quote arguments (if already has no quote characters)
        AlwaysQuote = True
      ElseIf arg = "-qa" Then ' Always quote non flag tail positional parameters (if already has no quote characters)
        AlwaysQuoteTailPosParams = True
      ElseIf arg = "-nowindow" Then
        NoWindow = True
      ElseIf arg = "-make_temp_dir_as_cwd" Then
        i = i + 1
        MakeTempDirAsCWD = WScript.Arguments(i)
        now_obj = Now
        timer_obj = Timer
        ChangeCurrentDirectory = fs_obj.GetSpecialFolder(2) & "\" & _
          Year(now_obj) & "'" & Right("0" & Month(now_obj),2) & "'" & Right("0" & Day(now_obj),2) & "." & _
          Right("0" & Hour(now_obj),2) & "'" & Right("0" & Minute(now_obj),2) & "'" & Right("0" & Second(now_obj),2) & "''" & Right("0" & Int((timer_obj - Int(timer_obj)) * 1000),3) & "." & _
          "winshell_call"
      ElseIf arg = "-wait_delete_cwd" Then ' ShellExecute current working directory, because the Windows locks current directory for a process being ran
        WaitDeleteCWD = 1
      ElseIf arg = "-wait_on_file_exist" Then
        i = i + 1
        WaitOnFileExist = WScript.Arguments(i)
      ElseIf Left(arg, 2) = "-r" Then
        str_replace_index_arr_size = str_replace_index_arr_size + 1

        GrowArr from_str_replace_indexed_arr, str_replace_index_arr_size
        i = i + 1
        from_str_replace_indexed_arr(str_replace_index_arr_size - 1) = WScript.Arguments(i)

        GrowArr to_str_replace_indexed_arr, str_replace_index_arr_size
        i = i + 1
        to_str_replace_indexed_arr(str_replace_index_arr_size - 1) = WScript.Arguments(i)

        GrowArr str_replace_index_arr, str_replace_index_arr_size
        If arg = "-r" Then
          str_replace_index_arr(str_replace_index_arr_size - 1) = -1 ' all
        ElseIf arg = "-ra" Then
          str_replace_index_arr(str_replace_index_arr_size - 1) = -2 ' greater or equal to 1
        Else
          arg = Mid(arg, 3)
          If IsNumeric(arg) And CDbl(Number) <= 2147483647 And CDbl(Number) >= -2147483648 And CStr(CLng(arg)) = CStr(arg) Then
            str_replace_index_arr(str_replace_index_arr_size - 1) = CLng(arg) ' exact index
          else
            str_replace_index_arr(str_replace_index_arr_size - 1) = ""
          End If
        End If
      ElseIf arg = "-v" Then
        str_expand_arr_size = str_expand_arr_size + 1

        GrowArr from_str_expand_arr, str_expand_arr_size
        i = i + 1
        from_str_expand_arr(str_expand_arr_size - 1) = WScript.Arguments(i)

        GrowArr to_str_expand_arr, str_expand_arr_size
        i = i + 1
        to_str_expand_arr(str_expand_arr_size - 1) = WScript.Arguments(i)
      End If
    Else
      ExpectFlags = False
      ReDim Preserve UnescapeArgs(UnescapeArgs_size - 1)
      ReDim Preserve from_str_replace_indexed_arr(str_replace_index_arr_size - 1)
      ReDim Preserve to_str_replace_indexed_arr(str_replace_index_arr_size - 1)
      ReDim Preserve str_replace_index_arr(str_replace_index_arr_size - 1)
      ReDim Preserve from_str_expand_arr(str_expand_arr_size - 1)
      ReDim Preserve to_str_expand_arr(str_expand_arr_size - 1)
    End If
  End If

  If Not ExpectFlags Then
    If UnescapeAllArgs Then
      arg = Unescape(arg)
    ElseIf UnescapeArgs_size > 0 Then
      For k = 0 To UnescapeArgs_size - 1
        If UnescapeArgs(k) = j Then
          arg = Unescape(arg)
          Exit For
        End If
      Next
    End If

    If ExpandAllArgs Then
      arg = shell_obj.ExpandEnvironmentStrings(arg)
    ElseIf ExpandArg0 And j = 0 Then
      arg = shell_obj.ExpandEnvironmentStrings(arg)
    ElseIf ExpandTailArgs And j > 0 Then
      arg = shell_obj.ExpandEnvironmentStrings(arg)
    End If

    If MakeTempDirAsCWD <> "" Then
      arg = Replace(arg, MakeTempDirAsCWD, ChangeCurrentDirectory, 1, -1, vbBinaryCompare)
    End If

    If str_replace_index_arr_size > 0 Then
      from_str_replace_arr = Array()
      to_str_replace_arr = Array()
      str_replace_arr_size = 0

      For k = 0 To str_replace_index_arr_size - 1
        index = str_replace_index_arr(k)
        if index = "" Then index = -1
        If index < 0 Then
          If index = -1 Or j >= -1 - index Then
            str_replace_arr_size = str_replace_arr_size + 1

            GrowArr from_str_replace_arr, str_replace_arr_size
            from_str_replace_arr(str_replace_arr_size - 1) = from_str_replace_indexed_arr(k)

            GrowArr to_str_replace_arr, str_replace_arr_size
            to_str_replace_arr(str_replace_arr_size - 1) = to_str_replace_indexed_arr(k)
          End If
        Else
          If j = index Then
            str_replace_arr_size = str_replace_arr_size + 1

            GrowArr from_str_replace_arr, str_replace_arr_size
            from_str_replace_arr(str_replace_arr_size - 1) = from_str_replace_indexed_arr(k)

            GrowArr to_str_replace_arr, str_replace_arr_size
            to_str_replace_arr(str_replace_arr_size - 1) = to_str_replace_indexed_arr(k)
          End If
        End If
      Next

      If str_replace_arr_size > 0 Then
        ReDim Preserve from_str_replace_arr(str_replace_arr_size - 1)
        ReDim Preserve to_str_replace_arr(str_replace_arr_size - 1)

        arg = ReplaceStringArr(arg, Len(arg), str_replace_arr_size, from_str_replace_arr, to_str_replace_arr)
      End If
    End If

    If InStr(arg, Chr(34)) = 0 Then
      If (AlwaysQuote Or Len(arg & "") = 0 Or InStr(arg, Space(1)) <> 0 Or InStr(arg, vbTab) <> 0) Or _
         (Not IsCmdArg And AlwaysQuoteTailPosParams And Left(arg, 1) <> "-") Then
        arg = Chr(34) & arg & Chr(34)
      End If
    End If

    If Not IsCmdArg Then
      param_args(j - 1) = arg
    Else
      cmd_arg = arg
      IsCmdArg = False
    End If

    j = j + 1
  End If
Next

If NoWindow Then ShowAs = 0

' upper bound instead of reserve size
ReDim Preserve param_args(j - 1)

' MsgBox cmd_arg & " " & Join(param_args, " ")

If MakeTempDirAsCWD <> "" Then
  fs_obj.CreateFolder ChangeCurrentDirectory
End If

Dim PrevCurrentDirectory : PrevCurrentDirectory = shell_obj.CurrentDirectory

If ChangeCurrentDirectory <> "" Then
  shell_obj.CurrentDirectory = ChangeCurrentDirectory
End If

If str_expand_arr_size > 0 Then
  Dim env_obj : Set env_obj = shell_obj.Environment("Process")

  For k = 0 To str_expand_arr_size - 1
    env_obj(from_str_expand_arr(k)) = to_str_expand_arr(k)
  Next
End If

winshell_obj.ShellExecute cmd_arg, Join(param_args, " "), ChangeCurrentDirectory, Verb, ShowAs

If WaitDeleteCWD And ChangeCurrentDirectory <> "" Then
  ' ShellExecute startup synchronization timeout
  WScript.Sleep 1000
End If

If ChangeCurrentDirectory <> "" Then
  shell_obj.CurrentDirectory = PrevCurrentDirectory
End If

If WaitDeleteCWD And ChangeCurrentDirectory <> "" Then
  Do Until Not fs_obj.FolderExists(ChangeCurrentDirectory)
    On Error Resume Next
    fs_obj.DeleteFolder ChangeCurrentDirectory, False
    On Error Goto 0
    WScript.Sleep 20
  Loop
End If

If WaitOnFileExist <> "" Then
  Do Until Not fs_obj.FileExists(WaitOnFileExist)
    WScript.Sleep 20
  Loop
End If

' cleanup
If MakeTempDirAsCWD <> "" And Not WaitDeleteCWD And ChangeCurrentDirectory <> "" Then
  If fs_obj.FolderExists(ChangeCurrentDirectory) Then
    On Error Resume Next
    fs_obj.DeleteFolder ChangeCurrentDirectory, False
    On Error Goto 0
  End If
End If
