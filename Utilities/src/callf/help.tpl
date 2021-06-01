[+ AutoGen5 template txt=%s.txt +]
callf.exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Create process or Shell execute in style of c-function printf.

Usage: callf.exe [/?] [<Flags>] [//] <ApplicationNameFormatString> [<CommandLineFormatString> [<Arg1> [<Arg2> ... [<ArgN>]]]]
       callf.exe [/?] [<Flags>] /shell-exec <Verb> [//] <FilePathFormatString> [<ParametersFormatString> [<Arg1> [<Arg2> ... [<ArgN>]]]]
  Description:
    /?
    This help.

    //:
    Character sequence to stop parse <Flags> command line parameters.

    Flags:
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
          Has no effect.
        ShellExecute
          Print ShellExecute specific error string.

      /no-print-gen-error-string
        Don't print generic error string.

      /no-sys-dialog-ui
        CreateProcess
          Has no effect.
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
          Has no effect.
        ShellExecute
          Use SEE_MASK_DOENVSUBST flag.
          Expand any environment variables specified in the string given by
          the <CurrentDirectory> or <FilePathFormatString> parameter.

      /init-com
        CreateProcess
          Has no effect.
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

      /reopen-stdin <file>
        Reopen stdin as a `<file>`.
        Can be used to read from a file instead from the stdin.
        Can not be used together with another `/reopen-stdin-*` option.

      /reopen-stdout <file>
        Reopen stdout as a `<file>`.
        Can be used to write to a file instead to the stdout.
        Can be used together with `/tee-stdout*` flags.
        Can not be used together with another `/reopen-stdout-as-*` option.
        Can not be used together with the `/stdout-dup` option.

      /reopen-stderr <file>
        Reopen stderr as a `<file>`.
        Can be used to write to a file instead to the stderr.
        Can be used together with `/tee-stderr*` flags.
        Can not be used together with another `/reopen-stderr-as-*` option.
        Can not be used together with the `/stderr-dup` option.

      /reopen-std[out|err]-truncate
        Truncate instead of append on stdout/stderr reopen.

      /std[out|err]-dup <fileno>
        Duplicate the standard respective handle from another one, where the
        `<fileno>` is the source handle index:
          1 = stdout, 2 = stderr.
        If is used after a respective `/reopen-std[out|err] <file>` option,
        then has the same behaviour as a sequence of respective
        `/reopen-stdout` or `/reopen-stderr` options with the same `<file>`
        and so can be used instead.

        Can not be used together with the same `/reopen-std[out|err]`
        option.

      /stdin-output-flush
        Flush after each write into an output handle connected with the
        process stdin.

      /std[out|err]-flush
        Flush after each write into the process stdout/stderr.

      /output-flush
        Flush after each write into the process stdout or stderr.

      /inout-flush
        Flush after each write into an output handle connected with the
        process stdin or into the process stdout or stderr.

      /tee-std[in|out|err] <file>
        Duplicate standard stream to a tee file `<file>`.
        Can be used together with another `/tee-std[in|out|err]-to-*` flag.

      /tee-std[in|out|err]-truncate
        Truncate instead of append on a tee file `<file>` open.

      /tee-std[in|out|err]-file-flush
        Flush after each write into a tee file `<file>.

      /tee-output-flush
        Flush after each write into a tee file `<file> connected with the
        process stdout or stderr.

      /tee-inout-flush
        Flush after each write into a tee file `<file> connected with the
        process stdin or stdout or stderr.

      /tee-std[in|out|err]-pipe-buf-size <size>
        Anonymous pipe buffer size in bytes attached directly to the
        child process stdin/stdout/stderr.

      /tee-std[in|out|err]-read-buf-size <size>
        Buffer size in bytes to read from parent process stdin.
        Buffer size in bytes to read from child process stdout/stderr.

      /tee-std[in|out|err]-dup <fileno>
        Duplicate the tee respective handle from another one, where the
        `<fileno>` is the source handle index:
          0 = stdin, 1 = stdout, 2 = stderr.
        Must be used after a respective `/tee-std[in|out|err] <file>` option.
        Has the same behaviour as a sequence of respective `/tee-stdin`,
        `/tee-stdout` or `/tee-stderr` options with the same `<file>` and so
        can be used instead.

      /mutex-std-writes
        In case of a write into reopened standard handle opened from a file
        does mutual excluded write into the same file from different
        processes.
        Each unique absolute file path associated with an unique mutex.
        The handle moves to the end each time after the mutex is locked to
        guarantee write into the file end between processes.
        Has no effect in case of a write into not reopened (inherited)
        standard handle. In this case synchronization depends on the Win32 API
        and basically happens when all writes does perform on the same handle
        (for example, when stderr has duplicated from stdout). If handles are
        different (each opened separately from the same file), then there is
        can be non synchronized writes.

      /mutex-tee-file-writes
        Does mutual excluded write into the same file from different
        processes.
        Each unique absolute file path associated with an unique mutex.
        The handle moves to the end each time after the mutex is locked to
        guarantee write into the file end between processes.

      /create-child-console
        CreateProcess
          Create new console for a child process instead of reuse the parent
          process console if exists.
        ShellExecute
          Removes usage of the SEE_MASK_NO_CONSOLE flag.
          Without this flag a child inherits the parent's console.

      /create-console
        Create current process console if not exists. If current process
        console exists, owned and not visible, then recreates console.
        If current process console exists and not owned (inherited), then
        creates new console. Has no effect if current process console already
        exists, owned and visible.
        Has priority over the `/attach-parent-console` flag.

      /create-console-title <title>
        Change console window title on the current process console creation or
        recreation. Has no effect if the current process console is not owned.

      /own-console-title <title>
        Change console window title if the current process console is owned.
        Has no effect on inherited console.

      /attach-parent-console
        Attach console from the parent process or it's ancestors. If the
        current process console is owned, then detaches it at first. Has no
        effect if the current process exists but not owned (inherited).
        Has no effect if the `/create-console` is used.

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

    Special flags:
      /disable-conout-reattach-to-visible-console
        In case if the current process console is not visible and parent
        process console is visible, then before print any output the
        application tries to attach to the parent process console to enable
        the user to read futher output into console before a child process
        start. To disable that use this flag.

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
    1. callf.exe /shell-exec open /no-sys-dialog-ui "${COMSPEC}" "/k"
    2. callf.exe /shell-exec open /no-sys-dialog-ui /attach-parent-console "${COMSPEC}" "/k"
    3. callf.exe /shell-exec open /no-sys-dialog-ui /create-child-console "${COMSPEC}" "/k"
    4. callf.exe /shell-exec open /no-sys-dialog-ui "callf.exe" "/create-console \"\" \"\\\"${COMSPEC}\\\" /k"

    5. callf.exe /shell-exec runas /no-sys-dialog-ui "${COMSPEC}" "/k"
    6. callf.exe /shell-exec runas /no-sys-dialog-ui /attach-parent-console "${COMSPEC}" "/k"
    7. callf.exe /shell-exec runas /no-sys-dialog-ui /no-window "callf.exe" "\"\" \"\\\"${COMSPEC}\\\" /k"
    8. callf.exe /shell-exec runas /no-sys-dialog-ui /no-window "callf.exe" "/attach-parent-console \"\" \"\\\"${COMSPEC}\\\" /k"

    Example #1 and #2 must be run in the same console.

    Example #3 and #4 must be run in the new (child) console.

    Example #5 and #6 must request the Administrator permission to execute in
    the new (child) console.

    Example #7 and #8 must request the Administrator permission to execute in
    the existing (parent) console.
