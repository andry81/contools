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

ReDim args(WScript.Arguments.Count - 1)

Dim RunSubst : RunSubst = False

Dim ExpectFlags : ExpectFlags = True

Dim UnescapeAllArgs : UnescapeAllArgs = False
Dim UnescapeArgs : UnescapeArgs = Array()
Dim UnescapeArgs_size : UnescapeArgs_size = 0

Dim ChangeCurrentDirectory : ChangeCurrentDirectory = ""
Dim ShowAs : ShowAs = 1

Dim ExpandAllArgs : ExpandAllArgs = False
Dim ExpandTailArgs : ExpandTailArgs = False

Dim ExpandArgs : ExpandArgs = Array()
Dim ExpandArgs_size : ExpandArgs_size = 0

Dim AlwaysQuote : AlwaysQuote = False
Dim AlwaysQuoteTailPosParams : AlwaysQuoteTailPosParams = False
Dim NoWait : NoWait = False
Dim NoWindow : NoWindow = False

Dim from_str_replace_indexed_arr : from_str_replace_indexed_arr = Array()
Dim to_str_replace_indexed_arr : to_str_replace_indexed_arr = Array()
Dim str_replace_index_arr : str_replace_index_arr = Array()

Dim str_replace_index_arr_size : str_replace_index_arr_size = 0

Dim from_str_replace_arr, to_str_replace_arr, str_replace_arr_size

Dim from_str_expand_arr : from_str_expand_arr = Array()
Dim to_str_expand_arr : to_str_expand_arr = Array()

Dim str_expand_arr_size : str_expand_arr_size = 0

Dim shell_obj : Set shell_obj = WScript.CreateObject("WScript.Shell")

Dim arg, index
Dim IsCmdArg : IsCmdArg = True
Dim i, j, k : j = 0

For i = 0 To WScript.Arguments.Count - 1
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If Mid(arg, 1, 1) = "-" Then
      If arg = "-s" Then ' Enable variables substitution in the `WScript.Shell.Run` function, by default is disabled through the `.` environment variable usage
        RunSubst = True
      ElseIf arg = "-u" Then ' Unescape %xx or %uxxxx
        UnescapeAllArgs = True
      ElseIf Left(arg, 2) = "-u" Then
        arg = Mid(arg, 3)
        If IsNumeric(arg) And CDbl(arg) <= 2147483647 And CDbl(arg) >= -2147483648 And CStr(CLng(arg)) = CStr(arg) Then
          UnescapeArgs_size = UnescapeArgs_size + 1
          GrowArr UnescapeArgs, UnescapeArgs_size
          UnescapeArgs(UnescapeArgs_size - 1) = CLng(arg)
        End If
      ElseIf arg = "-D" Then ' Change current directory
        i = i + 1
        ChangeCurrentDirectory =  WScript.Arguments(i)
      ElseIf arg = "-showas" Then ' Show window as
        i = i + 1
        ShowAs = CInt(WScript.Arguments(i))
      ElseIf Left(arg, 2) = "-E" Then
        arg = Mid(arg, 3)
        If arg = "" Then        ' Expand environment variables in all arguments
          ExpandAllArgs = True
        ElseIf arg = "a" Then   ' Expand environment variables only in the tail arguments
          ExpandTailArgs = True
        ElseIf IsNumeric(arg) And CDbl(arg) <= 2147483647 And CDbl(arg) >= -2147483648 And CStr(CLng(arg)) = CStr(arg) Then
          ExpandArgs_size = ExpandArgs_size + 1
          GrowArr ExpandArgs, ExpandArgs_size
          ExpandArgs(ExpandArgs_size - 1) = CLng(arg)
        End If
      ElseIf arg = "-q" Then ' Always quote arguments (if already has no quote characters)
        AlwaysQuote = True
      ElseIf arg = "-qa" Then ' Always quote non flag tail positional parameters (if already has no quote characters)
        AlwaysQuoteTailPosParams = True
      ElseIf arg = "-nowait" Then
        NoWait = True
      ElseIf arg = "-nowindow" Then
        NoWindow = True
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
          If IsNumeric(arg) And CDbl(arg) <= 2147483647 And CDbl(arg) >= -2147483648 And CStr(CLng(arg)) = CStr(arg) Then
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
    ElseIf ExpandTailArgs And j > 0 Then
      arg = shell_obj.ExpandEnvironmentStrings(arg)
    Else
      For k = 0 To ExpandArgs_size - 1
        If ExpandArgs(k) = j Then
          arg = shell_obj.ExpandEnvironmentStrings(arg)
          Exit For
        End If
      Next
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

    args(j) = arg

    j = j + 1

    If IsCmdArg Then IsCmdArg = False
  End If
Next

If NoWindow Then ShowAs = 0

' upper bound instead of reserve size
ReDim Preserve args(j - 1)

' MsgBox Join(args, " -- ")

If ChangeCurrentDirectory <> "" Then
  shell_obj.CurrentDirectory = ChangeCurrentDirectory
End If

If (Not RunSubst) Or str_expand_arr_size > 0 Then
  Dim env_obj : Set env_obj = shell_obj.Environment("Process")
End If

If str_expand_arr_size > 0 Then
  For k = 0 To str_expand_arr_size - 1
    env_obj(from_str_expand_arr(k)) = to_str_expand_arr(k)
  Next
End If

If RunSubst Then
  WScript.Quit shell_obj.Run(Join(args, " "), ShowAs, Not NoWait)
Else
  env_obj("?.") = Join(args, " ") ' a kind of unique or internal variable name

  WScript.Quit shell_obj.Run("%?.%", ShowAs, Not NoWait)
End If
