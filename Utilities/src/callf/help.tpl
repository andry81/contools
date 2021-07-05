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
        Has priority over all others `/ret-*` flags.

      /ret-win-error
        Return Win32 error code.
        Has priority over `/ret-child-exit` flag.
        Has no effect if `/ret-create-proc` flag is defined.

      /win-error-langid <LANGID>
        Language ID to format Win32 error messages.

      /ret-child-exit
        Return child process exit code (if has no `/no-wait` flag).
        Has no effect if any other `/ret-*` flag is defined.

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
        Has no effect if idle execution is used.

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

      /shell-exec-expand-env
        CreateProcess
          Has no effect.
        ShellExecute
          Use SEE_MASK_DOENVSUBST flag.
          Expand any environment variables specified in the string given by
          the <CurrentDirectory> or <FilePathFormatString> parameter.

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

        Has no effect if a tee is used.
        Overrides `/wait-child-start` flag.

      /no-window
        Don't show a child process window.

        Overrides `/showas` flag.

      /no-expand-env
        Don't expand `${...}` environment variables.

      /no-subst-vars
        Don't substitute `{...}` variables (command line parameters).

      /no-std-inherit
        Prevent standard handles inheritance into child process.

      /pipe-stdin-to-stdout
        Pipe the process stdin into stdout. This additionally disables
        standard handles inheritance (applies the `/no-std-inherit` flag).

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
          Has no effect, always waits by default if `/no-wait` flag is not
          used.
        ShellExecute
          Use SEE_MASK_NOASYNC and SEE_MASK_FLAG_DDEWAIT flags.
          Wait for the execute operation to complete before returning. This
          flag should be used by callers that are using ShellExecute forms
          that might result in an asynchronous activation, for example DDE,
          and create a process that might be run on background.

        The `/no-wait` flag has priority over this flag.

      /elevate or /elevate{ <ParentFlags> }[{ <ChildFlags> }]
        Self elevate process upto Administrator privileges.
        If the current `callf.exe` process has no Administrator privileges,
        then does use ShellExecute with elevation to start new `callf.exe`
        process with the same command line but different options and flags
        before run a child process. If the current `callf.exe` process already
        has Administrator privileges, then has no effect.
        Silently overrides the same regular flags.

        ParentFlags:
          Limited set of flags to pass exceptionally into the parent
          (not elevated) `callf.exe` process.

          /ret-create-proc
          /ret-win-error
          /no-wait
          /no-window
          /init-com
          /showas
          /reopen-std[in|out|err]*
          /std[in|out|err]-*
          /output-*
          /inout-*
          /create-[in|out]outbound-*
          /mutex-std-*
          /create-child-console
          /create-console
          /create-console-title
          /own-console-title
          /console-title
          /stdin-echo
          /eval-backslash-esc or /e
          /eval-dbl-backslash-esc or /e\\

        ChildFlags:
          Limited set of flags to pass exceptionally into the child
          (elevated) `callf.exe` process.

          /reopen-std[in|out|err]*
          /std[in|out|err]-*
          /output-*
          /inout-*
          /mutex-std-*
          /attach-parent-console

        All flags has no effect if elevation is not executed.
        In that case you should use either regular flags and options or
        `/promote*{ ... }` option.

      /promote{ <Flags> }
        In case if `/elevate*` flag or option is used and executed, then does
        declare `<Flags>` for both the parent (not elevated) `callf.exe`
        process and the child (elevated) `callf.exe` process.
        In case if `/elevate*` flag or option is not used or is not executed,
        then does declare `<Flags>` for the parent `callf.exe` process only.
        The same flag can not be used together with `/promote-parent{ ... }`
        option. Silently overrides the same regular flags.

        Flags:
          /chcp-in
          /chcp-out
          /win-error-langid
          /print-win-error-string
          /print-shell-error-string
          /no-print-gen-error-string
          /no-sys-dialog-ui
          /attach-parent-console
          /disable-conout-reattach-to-visible-console
          /disable-conout-duplicate-to-parent-console-on-error

      /promote-parent{ <Flags> }
        Does declare `<Flags>` for the parent `callf.exe` process only
        independently to the `/elevate*` flag or option.
        The same flag can not be used together with `/promote{ ... }`
        option. Silently overrides the same regular flags.

        Flags:
          /chcp-in
          /chcp-out
          /tee-std[in|out|err]*
          /tee-output*
          /tee-inout*
          /mutex-tee-*
          /attach-parent-console
          /disable-conout-reattach-to-visible-console
          /disable-conout-duplicate-to-parent-console-on-error

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
        Reopen stdin as a `<file>` to read from.
        Can be used to read from a file instead from the stdin.
        Can not be used together with another `/reopen-stdin-as-*` option.

      /reopen-stdin-as-server-pipe <pipe>
        Reopen stdin as inbound server pipe `<pipe>` to read from.
        Can be used to read from a named pipe instead of the stdin.
        Can not be used together with the `/reopen-stdin` or another
        `/reopen-stdin-as-*` option.

      /reopen-stdin-as-server-pipe-connect-timeout <timeout>
        Timeout in milliseconds to wait for an outbound client named pipe
        `<pipe>` connection to an inbound server named pipe attached to the
        process stdin. By default 30 seconds timeout is used.

      /reopen-stdin-as-server-pipe-in-buf-size <size>
        Inbound server named pipe `<pipe>` input buffer size in bytes have
        used to reopen the process stdin.

      /reopen-stdin-as-server-pipe-out-buf-size <size>
        Inbound server named pipe `<pipe>` output buffer size in bytes have
        used to reopen the process stdin.

      /reopen-stdin-as-client-pipe <pipe>
        Reopen stdin as inbound client named pipe `<pipe>` to read from.
        Can be used to read from a named pipe instead of the stdin.
        Can not be used together with the `/reopen-stdin` or another
        `/reopen-stdin-as-*` option.

      /reopen-stdin-as-client-pipe-connect-timeout <timeout>
        Timeout in milliseconds to wait for an inbound client named pipe
        `<pipe>` connection to an outbound server named pipe, where the client
        named pipe end is attached to the process stdin.
        By default 30 seconds timeout is used.

      /reopen-std[out|err] <file>
        Reopen stdout/stderr as a `<file>` to write to.
        Can be used to write to a file instead to the stdout/stderr.
        Can be used together with `/tee-std[out|err]*` options.
        Can not be used together with another `/reopen-std[out|err]-as-*`
        option.
        Can not be used together with the `/std[out|err]-dup` option.

      /reopen-std[out|err]-as-server-pipe <pipe>
        Reopen stdout/stderr as outbound server pipe `<pipe>` to write to.
        Can be used to write to a named pipe instead of the stdout/stderr.
        Can not be used together with the `/reopen-std[out|err]` or another
        `/reopen-std[out|err]-as-*` option.
        Can not be used together with the `/std[out|err]-dup` option.

      /reopen-std[out|err]-as-server-pipe-connect-timeout <timeout>
        Timeout in milliseconds to wait for an inbound client named pipe
        `<pipe>` connection to an outbound server named pipe attached to the
        process stdout/stderr. By default 30 seconds timeout is used.

      /reopen-std[out|err]-as-server-pipe-in-buf-size <size>
        Outbound server named pipe `<pipe>` input buffer size in bytes have
        used to reopen the process stdout/stderr.

      /reopen-std[out|err]-as-server-pipe-out-buf-size <size>
        Outbound server named pipe `<pipe>` output buffer size in bytes have
        used to reopen the process stdout/stderr.

      /reopen-std[out|err]-as-client-pipe <pipe>
        Reopen stdout/stderr as outbound client named pipe `<pipe>` to write
        to.
        Can be used to write to a named pipe instead of the stdout/stderr.
        Can not be used together with the `/reopen-std[out|err]` or
        another `/reopen-std[out|err]-as-*` option.
        Can not be used together with the `/std[out|err]-dup` option.

      /reopen-std[out|err]-as-client-pipe-connect-timeout <timeout>
        Timeout in milliseconds to wait for an outbound server named pipe
        `<pipe>` connection to an inbound client named pipe, where the server
        named pipe end is attached to the process stdout/stderr.
        By default 30 seconds timeout is used.

      /reopen-std[out|err]-file-truncate
        Truncate instead of append on stdout/stderr reopen.
        Has no effect on not a file.

      /std[out|err]-dup <fileno>
        Duplicate the standard respective handle from another one, where the
        `<fileno>` is the source handle index:
          1 = stdout, 2 = stderr.
        If is used after a respective `/reopen-std[out|err] <file>` option,
        then has the same behaviour as a sequence of respective
        `/reopen-stdout` or `/reopen-stderr` options with the same `<file>`
        and so can be used instead.
        Can not be used together with the same `/reopen-std[out|err]` option.

      /stdin-output-flush
        Flush after each write into an output handle connected with the
        process stdin. Basically used if the process stdin is redirected from
        a file or an anonymous/named pipe. Has no effect if the process stdin
        is a console (character) handle (not redirected).

      /std[out|err]-flush
        Flush after each write into the process stdout/stderr.

      /output-flush
        Flush after each write into the process stdout and stderr.

      /inout-flush
        Flush after each write into an output handle connected with the
        process stdin and into the process stdout and stderr. The same as the
        `/stdin-output-flush` plus after each write into the process
        stdout and stderr.

      /create-outbound-server-pipe-from-stdin <pipe>
        Create outbound server named pipe `<pipe>` instead of anonymous as by
        default to write into a child process stdin from the process stdin.
        Useful to write stream to elevated or another child `callf.exe`
        process.

      /create-outbound-server-pipe-from-stdin-connect-timeout <timeout>
        Timeout in milliseconds to wait for an inbound client named pipe
        `<pipe>` connection to an outbound server named pipe connected with
        the process stdin. By default 30 seconds timeout is used.

      /create-outbound-server-pipe-from-stdin-in-buf-size <size>
        Outbound server named pipe `<pipe>` input buffer size in bytes have
        used to write into from the process stdin.

      /create-outbound-server-pipe-from-stdin-out-buf-size <size>
        Outbound server named pipe `<pipe>` output buffer size in bytes have
        used to write into from the process stdin.

      /create-inbound-server-pipe-to-std[out|err] <pipe>
        Create inbound server named pipe `<pipe>` instead of anonymous as by
        default to read from a child process stdout/stderr to write into
        the process stdout/stderr.
        Useful to read stream from elevated or another child `callf.exe`
        process.

      /create-inbound-server-pipe-to-std[out|err]-connect-timeout <timeout>
        Timeout in milliseconds to wait for an outbound client named pipe
        `<pipe>` connection to an inbound server named pipe connected with
        the process stdout/stderr. By default 30 seconds timeout is used.

      /create-inbound-server-pipe-to-std[out|err]-in-buf-size <size>
        Inbound server named pipe `<pipe>` input buffer size in bytes have
        used to read from into the process stdout/stderr.

      /create-inbound-server-pipe-to-std[out|err]-out-buf-size <size>
        Inbound server named pipe `<pipe>` output buffer size in bytes have
        used to read from into the process stdout/stderr.

      /tee-std[in|out|err] <file>
        Duplicate standard stream to a tee file `<file>`.
        Can be used together with another `/tee-std[in|out|err]-to-*` flag.

      /tee-std[in|out|err]-to-server-pipe <pipe>
        Duplicate standard stream to a tee outbound server named pipe `<pipe>`
        to write to. Can be used together with `/tee-std[in|out|err]` option.
        Can not be used together with the
        `/tee-std[in|out|err]-to-server-pipe` option.
        Can not be used together with the `/tee-std[in|out|err]-dup` option.

      /tee-std[in|out|err]-to-server-pipe-connect-timeout <timeout>
        Timeout in milliseconds to wait for an outbound server named pipe
        `<pipe>` connection to an inbound client named pipe, where the server
        named pipe end is connected with the process standard handle as
        source. By default 30 seconds timeout is used.

      /tee-std[in|out|err]-to-server-pipe-in-buf-size <size>
        Outbound server named pipe `<pipe>` input buffer size in bytes have
        used to duplicate the process standard handle as source.

      /tee-std[in|out|err]-to-server-pipe-out-buf-size <size>
        Outbound server named pipe `<pipe>` output buffer size in bytes have
        used to duplicate the process standard handle as source.

      /tee-std[in|out|err]-to-client-pipe <pipe>
        Duplicate standard stream to a tee outbound client named pipe `<pipe>`
        to write to. Can be used together with `/tee-std[in|out|err]` option.
        Can not be used together with the
        `/tee-std[in|out|err]-to-server-pipe` option.
        Can not be used together with the `/tee-std[in|out|err]-dup` option.

      /tee-std[in|out|err]-to-client-pipe-connect-timeout <timeout>
        Timeout in milliseconds to wait for an outbound client named pipe
        `<pipe>` connection to an inbound server named pipe, where the client
        named pipe end is connected with the process standard handle as
        source. By default 30 seconds timeout is used.

      /tee-std[in|out|err]-dup <fileno>
        Duplicate the tee respective handle from another one, where the
        `<fileno>` is the source handle index:
          0 = stdin, 1 = stdout, 2 = stderr.
        Must be used after a respective `/tee-std[in|out|err] <file>` option.
        Has the same behaviour as a sequence of respective `/tee-stdin`,
        `/tee-stdout` or `/tee-stderr` options with the same `<file>` and so
        can be used instead.

      /tee-std[in|out|err]-file-truncate
        Truncate instead of append on a tee file `<file>` open.

      /tee-std[in|out|err]-file-flush
        Flush after each write into a tee file `<file>`.

      /tee-std[in|out|err]-pipe-flush
        Flush after each write into a tee named pipe `<pipe>`.

      /tee-std[in|out|err]-flush
        Flush after each write into a tee file `<file> or a tee named pipe
        `<pipe>` have used to split output from the process
        stdin/stdout/stderr.

      /tee-output-flush
        Flush after each write into a tee file `<file> or a named pipe
        `<pipe>` have used to split output from the process stdout and stderr.

      /tee-inout-flush
        Flush after each write into a tee file `<file> or a named pipe
        `<pipe>` have used to split output from the process stdin and stdout
        and stderr.

      /tee-std[in|out|err]-pipe-buf-size <size>
        Anonymous pipe buffer size in bytes attached directly to the child
        process stdin/stdout/stderr.
        Has no effect if a respective named pipe is used.

      /tee-std[in|out|err]-read-buf-size <size>
        Buffer size in bytes to read from the process stdin.
        Buffer size in bytes to read from a child process stdout/stderr.

      /mutex-std-writes
        In case of a write into reopened standard handle opened from a file
        does mutual excluded write into the same file from different
        processes.
        Each unique absolute file path (case insensitive) associated with an
        unique mutex.
        The handle file pointer moves to the end each time after the mutex is
        locked to guarantee write into the file end between processes.
        Has no effect in case of a write into not reopened (inherited)
        standard handle. In this case synchronization depends on the Win32 API
        and basically happens when all writes does perform on the same handle
        (for example, when stderr has duplicated from stdout). If handles are
        different (each opened separately from the same file), then the
        process tries to hash absolute lower cased file path and detect file
        path equality to invoke a file handle duplication instead of initiate
        a file open.

      /mutex-tee-file-writes
        Does mutual excluded write into the same file from different
        processes.
        Each unique absolute file path (case insensitive) associated with an
        unique mutex.
        The handle file pointer moves to the end each time after the mutex is
        locked to guarantee write into the file end between processes.
        Synchronization depends on the Win32 API and basically happens when
        all writes does perform on the same handle (for example, when stderr
        has duplicated from stdout). If handles are different (each opened
        separately from the same file), then the process tries to hash
        absolute lower cased file path and detect file path equality to invoke
        a file handle duplication instead of initiate a file open.

      /create-child-console
        CreateProcess
          Create new console for a child process instead of reuse the process
          console if exists (inheritance).
        ShellExecute
          Removes usage of the SEE_MASK_NO_CONSOLE flag.
          Without this flag a child inherits the process console if exists.

      /create-console
        Create current process console if not exists. If current process
        console exists, owned and not visible, then shows it.
        If current process console exists and not owned (inherited), then
        creates new console. Has no effect if current process console already
        exists, owned and visible.
        Has priority over the `/attach-parent-console` flag.

      /attach-parent-console
        Attach console from a parent process or it's ancestors. If the current
        process console is owned, then detaches it at first. Has no effect if
        the current process console exists but not owned (inherited).
        Has no effect if the `/create-console` is used.

      /create-console-title <title>
        Change console window title on the current process console creation or
        recreation. Has no effect if the current process console is not owned.
        Overrides the `/console-title` option.
        Can be used together with `/own-console-title` option.

      /own-console-title <title>
        Change console window title if the current process console is owned.
        Overrides the `/console-title` option.
        Can be used together with `/create-console-title` option.
        Has no effect on inherited console.

      /console-title <title>
        Change console window title. Applies only if non of
        `/create-console-title` and `/own-console-title` is applied.

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
        In case if the current process console is not visible and a parent
        process console is visible, then before print any output the
        application tries to attach to the parent process console to enable
        the user to read futher output into console before a child process
        start. To disable that use this flag.

      /disable-conout-duplicate-to-parent-console-on-error
        In case if the current process has own the console window, then the
        application tries to save all the output to the stdout/stderr to
        duplicate it later to the parent process console in case of
        application early exit just before a child process start. This
        happens because the leaf process owned console window does close upon
        the process exit and the user won't see the stdout/stderr output.
        Saved content print on process exit just before a child process start
        and is not happen if an error is not happened before a child process
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

    CreateProcess:
      <ApplicationNameFormatString>, <CommandLineFormatString>:
        Respective CreateProcess parameters.

      The <ApplicationNameFormatString> can be empty, then the
      <CommandLineFormatString> must have an application file path in the
      first argument. See detailed documentation in MSDN for the function
      `CreateProcess`.

    ShellExecute:
      <FilePathFormatString>, <ParametersFormatString>:
        Respective ShellExecute parameters.

    Idle execution:
      If <ApplicationNameFormatString> is `.`, then the idle execution is
      used. In that case not CreateProcess nor ShellExecute is used.
      The process loops stdin into stdout until EOF or a pipe close.
      The process does wait only if stdin is a file or a pipe, otherwise a
      call has no effect. Stderr does not used on idle execution and all
      operations over it has no effect.

    Name string placeholders:
      {pid}     - current process identifier as decimal number
      {ppid}    - parent process identifier as decimal number

    In case of ShellExecute the <ParametersFormatString> must contain only a
    command line arguments, but not the path to the executable (or document)
    itself which is part of <CommandLineFormatString>!

    If <CurrentDirectory> is not defined, then the current working directory
    is used.

  Return codes if `/ret-*` option is not defined:
   -255 - unspecified error
   -128 - help output
   -7   - named pipe connection timeout
   -6   - named pipe connection error
   -5   - input/output error
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

  Examples (CreateProcess/ShellExecute, with named pipes and idle execution with stdin-to-stdout piping):
    1. callf.exe /reopen-stdin 0.in .
    2. callf.exe /reopen-stdin 0.in "" "cmd.exe /k"

    3. callf.exe /reopen-stdin 0.in /reopen-stdout-as-server-pipe test123_{pid} /pipe-stdin-to-stdout "" "callf.exe /reopen-stdin-as-client-pipe test123_{ppid} ."
    4. callf.exe /reopen-stdin 0.in /reopen-stdout-as-server-pipe test123_{pid} /pipe-stdin-to-stdout "" "callf.exe /reopen-stdin-as-client-pipe test123_{ppid} \"\" \"cmd.exe /k\""

    5. callf.exe /reopen-stdin 0.in /reopen-stdout-as-server-pipe test123_{pid} /pipe-stdin-to-stdout /shell-exec runas /no-sys-dialog-ui /no-window "callf.exe" "/attach-parent-console /reopen-stdin-as-client-pipe test123_{ppid} ."
    6. callf.exe /reopen-stdin 0.in /reopen-stdout-as-server-pipe test123_{pid} /pipe-stdin-to-stdout /shell-exec runas /no-sys-dialog-ui /no-window "callf.exe" "/attach-parent-console /reopen-stdin-as-client-pipe test123_{ppid} \"\" \"cmd.exe /k\""

    Example #1 prints content of the `0.in` file to the console.
    Example #2 writes content of the `0.in` file to the `cmd.exe /k` process
    input.

    Example #3 writes content of the `0.in` file into the `test123` named
    pipe, where it being read and print to the console by the child process.
    Example #4 writes content of the `0.in` file into the `test123` named
    pipe, where it being read and write to the `cmd.exe /k` process input.

    Example #5 writes the content of the `0.in` file into the `test123` named
    pipe through the Administrator privileges isolation, where it being read
    and print to the existing (parent) console by the child process
    `callf.exe`.
    Example #6 writes content of the `0.in` file into the `test123` named pipe
    through the Administrator privileges isolation, where it being read and
    write to the `cmd.exe /k` process input with the output has connected back
    to the child process `callf.exe` which prints to the existing (parent)
    console.
