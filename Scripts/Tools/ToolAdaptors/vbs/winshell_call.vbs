''' Call an executable through the `Shell.Application.ShellExecute` function.

''' USAGE:
'''   winshell_call.vbs
'''     [-D <CurrentDirectoryPath>]
'''     [-verb <ShellVerb>]
'''     [-showas <ShowWindowAsNumber>]
'''     [-u[<N>]] [-q[a]]
'''     [-nowait] [-nowindow]
'''     [-make_temp_dir_as_cwd <CwdPlaceholder>] [-wait_delete_cwd] [--wait_on_file_exist]
'''     [-E[a | <N>]]
'''     [-re[a | <N>] <from> <to>] [-r[a | <N>] <from> <to>]
'''     [-v <name> <value>]
'''     [--]
'''       <CommandLine>
'''
''' DESCRIPTION:
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''   -D <CurrentDirectoryPath>
'''     Changes current directory to <CurrentDirectoryPath> before the execution.
'''
'''   -verb <ShellVerb>
'''     Run with specific <ShellVerb> operation, these are:
'''       edit
'''         Launches an editor and opens the document for editing.
'''         If the first argument of <CommandLine> is not a document file, the
'''         function will fail.
'''       explore
'''         Explores a folder specified by the first argumnet of <CommandLine>.
'''       find
'''         Initiates a search beginning in the directory specified by
'''         <CurrentDirectoryPath>.
'''       open
'''         Opens the item specified by the first argument of <CommandLine>
'''         parameter. The item can be a file or folder.
'''       print
'''         Prints the file specified by the first argument of <CommandLine>.
'''         If it is not a document file, the function fails.
'''       properties
'''         Displays the file or folder's properties.
'''       runas
'''         Launches an application as Administrator. User Account Control
'''         (UAC) will prompt the user for consent to run the application
'''         elevated or enter the credentials of an administrator account used
'''         to run the application.
'''
'''   -showas <ShowWindowAsNumber>
''''     Handles a child process window show state.
'''
'''      CreateProcess or ShellExecute
'''        0 = SW_HIDE
'''          Don't show window.
'''        1 = SW_SHOWNORMAL
'''          Activates and displays a window. If the window is minimized or
'''          maximized, the system restores it to its original size and
'''          position. An application should specify this flag when displaying
'''          the window for the first time.
'''        2 = SW_SHOWMINIMIZED
'''          Activates the window and displays it as a minimized window.
'''        3 = SW_SHOWMAXIMIZED
'''          Activates the window and displays it as a maximized window.
'''        4 = SW_SHOWNOACTIVATE
'''          Displays a window in its most recent size and position. This value
'''          is similar to SW_SHOWNORMAL, except that the window is not
'''          activated.
'''        5 = SW_SHOW
'''          Activates the window and displays it in its current size and
'''          position.
'''        6 = SW_MINIMIZE
'''          Minimizes the specified window and activates the next top-level
'''          window in the Z order.
'''        7 = SW_SHOWMINNOACTIVE
'''          Displays the window as a minimized window. This value is similar
'''          to SW_SHOWMINIMIZED, except the window is not activated.
'''        8 = SW_SHOWNA
'''          Displays the window in its current size and position. This value
'''          is similar to SW_SHOW, except that the window is not activated.
'''        9 = SW_RESTORE
'''          Activates and displays the window. If the window is minimized or
'''          maximized, the system restores it to its original size and
'''          position. An application should specify this flag when restoring
'''          a minimized window.
'''        11 = SW_FORCEMINIMIZE
'''          Minimizes a window, even if the thread that owns the window is not
'''          responding. This flag should only be used when minimizing windows
'''          from a different thread.
'''
'''      The flags that specify how an application is to be displayed when it
'''      is opened. If the first argument of <CommandLine> specifies a document
'''      file, the flag is simply passed to the associated application. It is
'''      up to the application to decide how to handle it.
'''
'''      See detailed documentation in MSDN for the function `ShowWindow`.
'''
'''   -u
'''     Unescape %xx or %uxxxx sequences.
'''   -u<N>
'''     Unescape %xx or %uxxxx sequences only in the <N>th argument, where
'''     N >= 0.
'''   -q
'''     Always quote arguments (if already has no quote characters).
'''   -qa
'''     Always quote tail positional parameters (if already has no quote
'''     characters).
'''   -q-sep <chars>
'''     Explicit set of command line argument separator characters for all
'''     arguments to trigger an argument quoting.
'''     By default, only the space and the tabulation characters does trigger
'''     an argument quoting.
'''     If an argument already has a quote character, then an argument quoting
'''     is ignored.
'''     CAUTION:
'''       The parameter redefines the characters set, so the space character
'''       must be issued to leave the default behaviour as is.
'''   -nowait
'''     Does not wait child process exit.
'''   -nowindow
'''     Hide child process window upon child process creation.
''''  -make_temp_dir_as_cwd <CwdPlaceholder>
'''     Make Current Working Directory as unique subdirectry in the temporary
'''     directories storage. Replace all <CwdPlaceholder> strings in all
'''     arguments by absolute path to Current Working Directory.
''''  -wait_delete_cwd
'''     Delete CWD before exit or wait until deleted.
''''  -wait_on_file_exist <File>
'''     Wait before exit while <File> is exist.
'''   -E
'''     Expand environment variables in all arguments
'''   -Ea
'''     Expand environment variables only in the tail arguments.
'''   -E<N>
'''     Expand environment variables only in the <N>th argument, where N >= 0.
'''   -r <from> <to>
'''     Replace <from> string to <to> string in all arguments.
'''     The replace does execute after %-unescape and $-environment variables
'''     expand.
'''   -re <from> <to>
'''     Replace early <from> string to <to> string in all arguments.
'''     The replace does execute before %-unescape and $-environment variables
'''     expand.
'''   -ra <from> <to>
'''     Replace <from> string to <to> string in tail arguments.
'''     The replace does execute after %-unescape and $-environment variables
'''     expand.
'''   -rea <from> <to>
'''     Replace early <from> string to <to> string in tail arguments.
'''     The replace does execute before %-unescape and $-environment variables
'''     expand.
'''   -r<N> <from> <to>
'''     Replace <from> string to <to> string only in the <N>th argument, where
'''     N >= 0.
'''     The replace does execute after %-unescape and $-environment variables
'''     expand.
'''   -re<N> <from> <to>
'''     Replace early <from> string to <to> string only in the <N>th argument,
'''     where N >= 0.
'''     The replace does execute after %-unescape and $-environment variables
'''     expand.
'''   -v <name> <value>
'''     Create environment variable with name <name> and value <value>.
'''
''' CAUTION:
'''   This implementation has issues which can not be fixed at all (by design).
'''   There is a better implementation through a standalone executable, see
'''   the `contools--utils` project.
'''
''' CAUTION:
'''   The list of issues around `winshell_call.vbs` implementation:
'''
'''   PROS:
'''     * Can run a child process elevated or as Administrator.
'''     * Can be run from any Windows version including Windows XP.
'''     * No need to recompile or rebuild sources to run a `.vbs` script, so
'''       can be included as a part into another project.
'''
'''   CONS:
'''     * By default does not wait a child process exit. You have to use
'''       `winshell_call.vbs` with `-make_temp_dir_as_cwd` and
'''       `-wait_delete_cwd` options together with the `call.vbs` to achieve a
'''       child process exit wait while being run as Administrator.
'''     * A `.vbs` script can not use all windows functionality/features and
'''       has a lack of functionality by design.
'''     * Windows antivirus software in some cases reports a `.vbs` script as
'''       not safe or requests an explicit action on each `.vbs` script
'''       execution.
'''     * Nested quote characters can not be escaped and must be replaced by
'''       string `%22` with the usage of the `-q` flag or it's derivatives.
'''
''' KNOWN ISSUES:
'''
'''   * The `cmd.exe` command line parser use %-character expansion for all
'''     parameters.
'''     You must use, for example, the `-ra "%" "%?01%" -v "?01" "%"` options
'''     to workaround the issue for the `cmd.exe` command line.
'''   * The `cmd.exe` command line parser treats the `,` character as command
'''     line parameters separator additionally to the space character.
'''     You must use the `-q-sep " ,"` option to workaround the issue for the
'''     `cmd.exe` command line.
'''

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
Dim ExpandTailArgs : ExpandTailArgs = False

Dim ExpandArgs : ExpandArgs = Array()
Dim ExpandArgs_size : ExpandArgs_size = 0

Dim QuoteArg
Dim AlwaysQuoteSeparatorChar : AlwaysQuoteSeparatorChar = ""
Dim AlwaysQuoteSeparatorChars : AlwaysQuoteSeparatorChars = " "

Dim AlwaysQuote : AlwaysQuote = False
Dim AlwaysQuoteTailPosParams : AlwaysQuoteTailPosParams = False

Dim NoWindow : NoWindow = False
Dim MakeTempDirAsCWD : MakeTempDirAsCWD = ""
Dim WaitDeleteCWD : WaitDeleteCWD = 0
Dim WaitOnFileExist : WaitOnFileExist = ""

''' early replace
Dim from_str_early_replace_indexed_arr : from_str_early_replace_indexed_arr = Array()
Dim to_str_early_replace_indexed_arr : to_str_early_replace_indexed_arr = Array()
Dim str_early_replace_index_arr : str_early_replace_index_arr = Array()
Dim str_early_replace_index_arr_size : str_early_replace_index_arr_size = 0
Dim from_str_early_replace_arr, to_str_early_replace_arr, str_early_replace_arr_size

''' late replace
Dim from_str_late_replace_indexed_arr : from_str_late_replace_indexed_arr = Array()
Dim to_str_late_replace_indexed_arr : to_str_late_replace_indexed_arr = Array()
Dim str_late_replace_index_arr : str_late_replace_index_arr = Array()
Dim str_late_replace_index_arr_size : str_late_replace_index_arr_size = 0
Dim from_str_late_replace_arr, to_str_late_replace_arr, str_late_replace_arr_size

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

For i = 0 To WScript.Arguments.Count - 1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Mid(arg, 1, 1) = "-" Then
      If arg = "-u" Then ' Unescape %xx or %uxxxx
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
      ElseIf arg = "-verb" Then ' Shell Verb
        i = i + 1
        Verb = WScript.Arguments(i)
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
      ElseIf arg = "-q-sep" Then ' command line arguments separator characters
        i = i + 1
        AlwaysQuoteSeparatorChars =  WScript.Arguments(i)
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
      ElseIf arg = "-wait_delete_cwd" Then ' delete or wait to delete of the current working directory, because the Windows locks current directory for a process being ran
        WaitDeleteCWD = 1
      ElseIf arg = "-wait_on_file_exist" Then
        i = i + 1
        WaitOnFileExist = WScript.Arguments(i)
      ElseIf Left(arg, 3) = "-re" Then
        str_early_replace_index_arr_size = str_early_replace_index_arr_size + 1

        GrowArr from_str_early_replace_indexed_arr, str_early_replace_index_arr_size
        i = i + 1
        from_str_early_replace_indexed_arr(str_early_replace_index_arr_size - 1) = WScript.Arguments(i)

        GrowArr to_str_early_replace_indexed_arr, str_early_replace_index_arr_size
        i = i + 1
        to_str_early_replace_indexed_arr(str_early_replace_index_arr_size - 1) = WScript.Arguments(i)

        GrowArr str_early_replace_index_arr, str_early_replace_index_arr_size
        If arg = "-re" Then
          str_early_replace_index_arr(str_early_replace_index_arr_size - 1) = -1 ' all
        ElseIf arg = "-rea" Then
          str_early_replace_index_arr(str_early_replace_index_arr_size - 1) = -2 ' greater or equal to 1
        Else
          arg = Mid(arg, 4)
          If IsNumeric(arg) And CDbl(arg) <= 2147483647 And CDbl(arg) >= -2147483648 And CStr(CLng(arg)) = CStr(arg) Then
            str_early_replace_index_arr(str_early_replace_index_arr_size - 1) = CLng(arg) ' exact index
          else
            str_early_replace_index_arr(str_early_replace_index_arr_size - 1) = ""
          End If
        End If
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

      ''' early replace
      ReDim Preserve from_str_early_replace_indexed_arr(str_early_replace_index_arr_size - 1)
      ReDim Preserve to_str_early_replace_indexed_arr(str_early_replace_index_arr_size - 1)
      ReDim Preserve str_early_replace_index_arr(str_early_replace_index_arr_size - 1)

      ''' late replace
      ReDim Preserve from_str_late_replace_indexed_arr(str_late_replace_index_arr_size - 1)
      ReDim Preserve to_str_late_replace_indexed_arr(str_late_replace_index_arr_size - 1)
      ReDim Preserve str_late_replace_index_arr(str_late_replace_index_arr_size - 1)

      ReDim Preserve from_str_expand_arr(str_expand_arr_size - 1)
      ReDim Preserve to_str_expand_arr(str_expand_arr_size - 1)

      If arg = "--" Then Exit Do
    End If
  End If

  If Not ExpectFlags Then
    ''' early replace
    If str_early_replace_index_arr_size > 0 Then
      from_str_early_replace_arr = Array()
      to_str_early_replace_arr = Array()
      str_early_replace_arr_size = 0

      ''' collect all replace parameters for the same argument
      For k = 0 To str_early_replace_index_arr_size - 1
        index = str_early_replace_index_arr(k)
        if index = "" Then index = -1
        If index < 0 Then
          If index = -1 Or j >= -1 - index Then
            str_early_replace_arr_size = str_early_replace_arr_size + 1

            GrowArr from_str_early_replace_arr, str_early_replace_arr_size
            from_str_early_replace_arr(str_early_replace_arr_size - 1) = from_str_early_replace_indexed_arr(k)

            GrowArr to_str_early_replace_arr, str_early_replace_arr_size
            to_str_early_replace_arr(str_early_replace_arr_size - 1) = to_str_early_replace_indexed_arr(k)
          End If
        Else
          If j = index Then
            str_early_replace_arr_size = str_early_replace_arr_size + 1

            GrowArr from_str_early_replace_arr, str_early_replace_arr_size
            from_str_early_replace_arr(str_early_replace_arr_size - 1) = from_str_early_replace_indexed_arr(k)

            GrowArr to_str_early_replace_arr, str_early_replace_arr_size
            to_str_early_replace_arr(str_early_replace_arr_size - 1) = to_str_early_replace_indexed_arr(k)
          End If
        End If
      Next

      If str_early_replace_arr_size > 0 Then
        ReDim Preserve from_str_early_replace_arr(str_early_replace_arr_size - 1)
        ReDim Preserve to_str_early_replace_arr(str_early_replace_arr_size - 1)

        arg = ReplaceStringArr(arg, Len(arg), str_early_replace_arr_size, from_str_early_replace_arr, to_str_early_replace_arr)
      End If
    End If

    ''' %-unescape
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

    ''' $-environment variables expand
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

    If MakeTempDirAsCWD <> "" Then
      arg = Replace(arg, MakeTempDirAsCWD, ChangeCurrentDirectory, 1, -1, vbBinaryCompare)
    End If

    ''' late replace
    If str_late_replace_index_arr_size > 0 Then
      from_str_late_replace_arr = Array()
      to_str_late_replace_arr = Array()
      str_late_replace_arr_size = 0

      ''' collect all replace parameters for the same argument
      For k = 0 To str_late_replace_index_arr_size - 1
        index = str_late_replace_index_arr(k)
        if index = "" Then index = -1
        If index < 0 Then
          If index = -1 Or j >= -1 - index Then
            str_late_replace_arr_size = str_late_replace_arr_size + 1

            GrowArr from_str_late_replace_arr, str_late_replace_arr_size
            from_str_late_replace_arr(str_late_replace_arr_size - 1) = from_str_late_replace_indexed_arr(k)

            GrowArr to_str_late_replace_arr, str_late_replace_arr_size
            to_str_late_replace_arr(str_late_replace_arr_size - 1) = to_str_late_replace_indexed_arr(k)
          End If
        Else
          If j = index Then
            str_late_replace_arr_size = str_late_replace_arr_size + 1

            GrowArr from_str_late_replace_arr, str_late_replace_arr_size
            from_str_late_replace_arr(str_late_replace_arr_size - 1) = from_str_late_replace_indexed_arr(k)

            GrowArr to_str_late_replace_arr, str_late_replace_arr_size
            to_str_late_replace_arr(str_late_replace_arr_size - 1) = to_str_late_replace_indexed_arr(k)
          End If
        End If
      Next

      If str_late_replace_arr_size > 0 Then
        ReDim Preserve from_str_late_replace_arr(str_late_replace_arr_size - 1)
        ReDim Preserve to_str_late_replace_arr(str_late_replace_arr_size - 1)

        arg = ReplaceStringArr(arg, Len(arg), str_late_replace_arr_size, from_str_late_replace_arr, to_str_late_replace_arr)
      End If
    End If

    If InStr(arg, Chr(34)) = 0 Then
      If AlwaysQuote Or Len(arg & "") = 0 Then
        QuoteArg = True
      Else
        QuoteArg = False
        For k = 1 To Len(AlwaysQuoteSeparatorChars)
          AlwaysQuoteSeparatorChar = Mid(AlwaysQuoteSeparatorChars, k, 1)
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

      If QuoteArg Or (Not IsCmdArg And AlwaysQuoteTailPosParams And Left(arg, 1) <> "-") Then
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
Loop While False : Next

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
