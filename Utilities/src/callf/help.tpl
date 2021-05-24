[+ AutoGen5 template txt=%s.txt +]
callf.exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Create process or Shell execute in style of c-function printf.

Usage: callf.exe [/?] [<Flags>] [//] <ApplicationNameFormatString> [<CommandLineFormatString> [<Arg1> [<Arg2> ... [<ArgN>]]]]
       callf.exe [/?] [<Flags>] /shell-exec <Verb> [//] <FilePathFormatString> [<ParametersFormatString> [<Arg1> [<Arg2> ... [<ArgN>]]]]
  Description:
    Flags:
      /?
        This help.

      //:
        Character sequence to stop parse <Flags> command line parameters.

      /chcp-in <codepage>
        Console input code page.

      /chcp-out <codepage>
        Console output code page.

      /ret-create-proc
        Return CreateProcess or ShellExecute return code.

      /ret-win-error
        Return Win32 error code.

      /win-error-langid <LANGID>
        Language ID to format Win32 error messages.

      /ret-child-exit
        Return child process exit code (if has no `/no-wait` flag).

      /print-win-error-string
        Print Win32 error string (even if `/ret-win-error` flag is not set).

      /print-shell-error-string
        CreateProcess
          Has no meaning.
        ShellExecute
          Print ShellExecute specific error string.

      /no-print-gen-error-string
        Don't print generic error string.

      /no-sys-dialog-ui
        CreateProcess
          Has no meaning.
        ShellExecute
          Use SEE_MASK_FLAG_NO_UI flag.
          Do not display an error message box if an error occurs.

      /shell-exec <Verb>
        Call to ShellExecute instead of CreateProcess.

        <Verb>:
          edit
            Launches an editor and opens the document for editing.
            If <FilePathFormatString> is not a document file, the function
            will fail.
          explore
            Explores a folder specified by <FilePathFormatString>.
          find
            Initiates a search beginning in the directory specified by
            <CurrentDirectory>.
          open
            Opens the item specified by the <FilePathFormatString> parameter.
            The item can be a file or folder.
          print
            Prints the file specified by <FilePathFormatString>.
            If <FilePathFormatString> is not a document file, the function
            fails.
          properties
            Displays the file or folder's properties.
          runas
            Launches an application as Administrator. User Account Control
            (UAC) will prompt the user for consent to run the application
            elevated or enter the credentials of an administrator account used
            to run the application.

      /D <CurrentDirectory>
        CreateProcess
          Use <CurrentDirectory> as parameter in call to CreateProcess.
        ShellExecute
          Use <CurrentDirectory> as parameter in call to Shellexecute.

      /no-wait
        CreateProcess
          Don't wait a child process to exit.
        ShellExecute
          Use SEE_MASK_ASYNCOK flag.
          The execution can be performed on a background thread and the call
          should return immediately without waiting for the background thread
          to finish. Note that in certain cases ShellExecuteEx ignores this
          flag and waits for the process to finish before returning.

        Overrides `/wait-child-start` flag.

      /no-window
        Don't show a child process window.
        Overrides `/showas` flag.

      /no-expand-env
        Don't expand `${...}` environment variables.

      /no-subst-vars
        Don't substitute `{...}` variables (command line parameters).

      /shell-exec-expand-env
        CreateProcess
          Has no meaning.
        ShellExecute
          Use SEE_MASK_DOENVSUBST flag.
          Expand any environment variables specified in the string given by
          the <CurrentDirectory> or <FilePathFormatString> parameter.

      /init-com
        CreateProcess
          Has no meaning.
        ShellExecute
          Call CoInitializeEx before call to ShellExecute.
          Because ShellExecute can delegate execution to Shell extensions
          (data sources, context menu handlers, verb implementations) that are
          activated using Component Object Model (COM), COM should be
          initialized before ShellExecute is called. Some Shell extensions
          require the COM single-threaded apartment (STA) type.

      /wait-child-start
        CreateProcess
          Has no meaning, always waits by default if `/no-wait` flag is not
          defined.
        ShellExecute
          Use SEE_MASK_NOASYNC and SEE_MASK_FLAG_DDEWAIT flags.
          Wait for the execute operation to complete before returning. This
          flag should be used by callers that are using ShellExecute forms
          that might result in an async activation, for example DDE, and
          create a process that might be run on background.

        The `/no-wait` flag has priority over this flag.

      /showas <ShowWindowAsNumber>
        Handles a child process window show state.

        CreateProcess or ShellExecute
          0 = SW_HIDE
            Don't show window.
          1 = SW_SHOWNORMAL
            Activates and displays a window. If the window is minimized or
            maximized, the system restores it to its original size and
            position. An application should specify this flag when displaying
            the window for the first time.
          2 = SW_SHOWMINIMIZED
            Activates the window and displays it as a minimized window.
          3 = SW_SHOWMAXIMIZED
            Activates the window and displays it as a maximized window.
          4 = SW_SHOWNOACTIVATE
            Displays a window in its most recent size and position. This value
            is similar to SW_SHOWNORMAL, except that the window is not
            activated.
          5 = SW_SHOW
            Activates the window and displays it in its current size and
            position.
          6 = SW_MINIMIZE
            Minimizes the specified window and activates the next top-level
            window in the Z order.
          7 = SW_SHOWMINNOACTIVE
            Displays the window as a minimized window. This value is similar
            to SW_SHOWMINIMIZED, except the window is not activated.
          8 = SW_SHOWNA
            Displays the window in its current size and position. This value
            is similar to SW_SHOW, except that the window is not activated.
          9 = SW_RESTORE
            Activates and displays the window. If the window is minimized or
            maximized, the system restores it to its original size and
            position. An application should specify this flag when restoring
            a minimized window.
          11 = SW_FORCEMINIMIZE
            Minimizes a window, even if the thread that owns the window is not
            responding. This flag should only be used when minimizing windows
            from a different thread.

        The flags that specify how an application is to be displayed when it
        is opened. If <FilePathFormatString> specifies a document file, the
        flag is simply passed to the associated application. It is up to the
        application to decide how to handle it.

        See detailed documentation in MSDN for the function `ShowWindow`.

      /reopen-stdin-as <file>
        Reopen stdin as a `<file>`.

      /reopen-stdout-as <file>
        Reopen stdout as a `<file>`.

      /reopen-stderr-as <file>
        Reopen stderr as a `<file>`.

      /tee-std[in|out|err] <file>
        Duplicate stream to `<file>`.

      /tee-std[in|out|err]-append
        Append instead of rewrite into `<file>`.

      /tee-std[in|out|err]-flush
        Flush after each write into `<file>`.

      /tee-std[in|out|err]-pipe-buf-size <size>
        Pipe buffer size in bytes.

      /tee-std[in|out|err]-read-buf-size <size>
        Buffer size in bytes to read into from the standard stream pipe.

      /use-parent-console
        CreateProcess
          Has no meaning.
        ShellExecute
          Use SEE_MASK_NO_CONSOLE flag.
          Use to inherit the parent's console for the new process instead of
          having it create a new console.

        Overrides `/create-child-console` flag.

      /create-child-console
        CreateProcess
          Create new console for a child process instead of reuse the parent
          process console if exists.
        ShellExecute
          Avoid use

      /detach-parent-console
        Detach console from parent process before call to CreateProcess or
        ShellExecute.

      /stdin-echo <0|1>
        Explicitly enable or disable console input buffer echo before start
        of a child process.

      /eval-backslash-esc or /e
        Evaluate escape characters:
          \a = \x07 = alert (bell)
          \b = \x08 = backspace
          \t = \x09 = horizontal tab
          \n = \x0A = newline or line feed
          \v = \x0B = vertical tab
          \f = \00C = form feed
          \r = \x0D = carriage return
          \e = \x1B = escape (non-standard GCC extension)

          \" = quotation mark
          \' = apostrophe
          \? = question mark
          \\ = backslash

          \N or \NN or \NNN or .. or \NNNNNNNNNN - octal number
          \xN or \xNN or \xNNN or .. or \xNNNNNNNN - hexidecimal number

      /eval-dbl-backslash-esc or /e\\
        Evaluate double backslash escape characters:
          \\ = backslash

    <ApplicationNameFormatString>, <CommandLineFormatString>,
    <FilePathFormatString>, <ParametersFormatString>,
    <ArgN> placeholders:
      ${<VarName>} - <VarName> environment variable value.
      {0}    - first argument value.
      {N}    - N'th argument value.
      {0hs}  - first arguments hexidecimal string (00-FF per character).
      {Nhs}  - N'th arguments hexidecimal string (00-FF per character).
      \{     - '{' character escape

    CreateProcess
      <ApplicationNameFormatString>, <CommandLineFormatString>:
        Respective CreateProcess parameters.

      The <ApplicationNameFormatString> can be empty, then the
      <CommandLineFormatString> must have an application file path in the
      first argument. See detailed documentation in MSDN for the function
      `CreateProcess`.

    ShellExecute
      <FilePathFormatString>, <ParametersFormatString>:
        Respective ShellExecute parameters.

    In case of ShellExecute the <ParametersFormatString> must contain only a
    command line arguments, but not the path to the executable (or document)
    itself which is part of <CommandLineFormatString>!

    If <CurrentDirectory> is not defined, then the current working directory
    is used.

  Return codes if `/ret-*` option is not defined:
   -255 - unspecified error
   -128 - help output
   -4   - Win32 or COM error
   -2   - invalid format
   -1   - both <ApplicationNameFormatString> and <CommandLineFormatString>
          are empty or <FilePathFormatString> is empty.
    0   - succeded

  Examples (CreateProcess, no recursion):
    1. callf.exe "${WINDIR}\system32\cmd.exe" "{0} {1}" "/c" "echo.Hello World!"
    2. callf.exe "${COMSPEC}" "{0} {1}" "/c" "echo.Hello World!"
    3. callf.exe "{0}" "\"{1}\" {2}" "${COMSPEC}" "/c" "echo.Hello World!"
    4. callf.exe "" "\"{0}\" {1} {2}" "cmd.exe" "/c" "echo.Hello World!"
    5. callf.exe "" "\"{0}\" {1} {2}" "${WINDIR}\system32\cmd.exe" "/c" "echo.Hello World!"

    6. callf.exe "${COMSPEC}" "/c (echo.Special case characters: ^|^&""|& ^ |&""^|^& ^^ ^|^&""|& ^ |&""^|^&)&pause"
    7. callf.exe "${COMSPEC}" "/c (echo.Special case characters: ^|^&\"^|^& ^^ ^|^&\"^|^& ^^ ^|^&\"^|^& ^^ ^|^&\"^|^&)&pause"

    First 5 examples should print:
      Hello World!

    Last 2 examples should print and pause after:
      Special case characters: |&"|& ^ |&"|& ^ |&"|& ^ |&"|&

  Examples (CreateProcess, with recursion):
    1. callf.exe "" "\"${COMSPEC}\" /c echo.{0}" "%%TIME%%"
    2. callf.exe "" "callf.exe \"\" \"\\\"$\{COMSPEC}\\\" /c echo.{0}\" \"%%TIME%%\""
    3. callf.exe "" "callf.exe \"\" \"callf.exe \\\"\\\" \\\"\\\\\\\"$\\{COMSPEC}\\\\\\\" /c echo.{0}\\\" \\\"%%TIME%%\\\"\""

    4. callf.exe "" "\"${COMSPEC}\" /c echo.{0}" "%TIME%"
    5. callf.exe "" "callf.exe \"\" \"\\\"$\{COMSPEC}\\\" /c echo.{0}\" \"%TIME%\""
    6. callf.exe "" "callf.exe \"\" \"callf.exe \\\"\\\" \\\"\\\\\\\"$\\{COMSPEC}\\\\\\\" /c echo.{0}\\\" \\\"%TIME%\\\"\""

    First 3 examples must be run from the cmd.exe batch file (.bat).

    Last 3 examples must be typed in the cmd.exe console window.

  Examples (ShellExecute):
    1. callf.exe /shell-exec open /no-sys-dialog-ui /use-parent-console "${COMSPEC}" "/k"

    2. callf.exe /shell-exec runas /no-sys-dialog-ui "${COMSPEC}" "/k"

    First 1 example must be run in the same console.

    Last 1 example must request the Administrator permission to execute.
