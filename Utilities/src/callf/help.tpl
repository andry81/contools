[+ AutoGen5 template txt=%s.txt +]
[+ AppModuleName +].exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Create process or Shell execute in style of c-function printf.

Usage: [+ AppModuleName +].exe [/?] [<Flags>] [//] <ApplicationNameFormatString> [<CommandLineFormatString> [<Arg1> [<Arg2> ... [<ArgN>]]]]
       [+ AppModuleName +].exe [/?] [<Flags>] /shell-exec <Verb> [//] <FilePathFormatString> [<ParametersFormatString> [<Arg1> [<Arg2> ... [<ArgN>]]]]
  Description:
    /?
    This help.

    //:
    Character sequence to stop parse <Flags> command line parameters.

    <Flags>:
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
        /unelevate-2
        /unelevate-by-shell-exec-from-explorer
          Print related COM error string.

      /no-print-gen-error-string
        Don't print generic error string.

      /no-sys-dialog-ui
        CreateProcess
          Has no effect.
        ShellExecute
          Uses SEE_MASK_FLAG_NO_UI flag.
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

      /shell-exec-unelevate-from-explorer
        Call to IShellDispatch2::ShellExecute instead of CreateProcess to
        unelevate the child process.

        CAUTION:
          Implementation does use IShellDispatch2::ShellExecute interface
          function which does not return a child process handle to wait on.
          So this-parent will not wait a child process to close and a parent
          process of a child will be the Windows Shell process instead of the
          this-process.

        Can not be used together with another `/shell-exec*` and
        `/unelevate-by-shell-exec-from-explorer` options.

        Has no effect if idle execution is used.

      /shell-exec-expand-env
        CreateProcess
          Has no effect.
        ShellExecute
          Uses SEE_MASK_DOENVSUBST flag.
          Expand any environment variables specified in the string given by
          the <CurrentDirectory> or <FilePathFormatString> parameter.

      /D <CurrentDirectory>
        CreateProcess
          Uses <CurrentDirectory> as parameter in call to CreateProcess.
        ShellExecute
          Uses <CurrentDirectory> as parameter in call to Shellexecute.

        If `<CurrentDirectory>` is `.`, then it has special meaning to pass
        current directory into child process.

      /no-wait
        CreateProcess
          Don't wait a child process to exit.
        ShellExecute
          Uses SEE_MASK_ASYNCOK flag.
          The execution can be performed on a background thread and the call
          should return immediately without waiting for the background thread
          to finish. Note that in certain cases ShellExecuteEx ignores this
          flag and waits for this-process to finish before returning.

        Has no effect if a tee is used.

        Overrides `/wait-child-start` flag.

      /no-window
        Hide a child process window including console window.

        CreateProcess
          Overrides `/showas` option with `SW_HIDE` value.
        ShellExecute
          By default uses the SEE_MASK_NO_CONSOLE flag.

        Overrides `/showas` flag.

      /no-window-console
        Create child process with hidden console window.

        CreateProcess
          Uses CREATE_NO_WINDOW flag.
        ShellExecute
          Removes usage of the SEE_MASK_NO_CONSOLE flag.
          Implies `/no-window` flag.

        Can not be used together with `/detach-child-console` flag.

        Has no effect if `/create-child-console` flag is used.

      /pause-on-exit-if-error-before-exec
        Pause on exit if an error happened before a command line application
        execution. By default it prints "Press any key to continue . . ."
        message to the stdout.
        This-process must be attached to a console, otherwise the pause would
        be skipped.

      /pause-on-exit-if-error
        Pause on exit if an error happened. By default it prints
        "Press any key to continue . . ." message to the stdout.
        This-process must be attached to a console, otherwise the pause would
        be skipped.

      /pause-on-exit
        Pause on exit. By default it prints "Press any key to continue . . ."
        message to the stdout.
        This-process must be attached to a console, otherwise the pause would
        be skipped.

      /skip-pause-on-detached-console
        By default all `/pause*` flags does restore console if was detached
        before. The console window search of does the same way as like for the
        `/attach-parent-console` flag.
        Use this flag if you want to skip the pause in such case.

        Has no effect if `/pause*` flag is not used.

      /no-expand-env
        Don't expand `${...}` environment variables.

        Can not be used together with `/allow-expand-unexisted-env` flag.

        Has effect on `{*}` and `{@}` variable values.

      /no-subst-vars
        Don't substitute all `{...}` variables (command line arguments).
        Additionally disables `\{` escape sequence expansion.

        Can not be used together with `/no-subst-pos-vars`,
        `/allow-subst-empty-args` flags.

      /no-subst-pos-vars
        Don't substitute positional `{...}` variables (command line arguments).

        Does not disable `\{` escape sequence expansion.

        Can not be used together with `/no-subst-vars`,
        `/allow-subst-empty-args` flags.

        Has no effect on `{*}` and `{@}` variables (not positional).

      /no-subst-empty-tail-vars
        Don't substitute empty `{*}` and `{@}` variables.

        Can be used together with `/allow-subst-empty-args` flag.

      /expand-env-arg<N>
      /E<N>
        Expand `${...}` environment variables exclusively for `<N>` command
        line argument, where `<N>` >= 0. This turns off the expansion for the
        rest of arguments if not specifically enabled.
        Unexisted environment variables is not expanded by default, use the
        `/EE<N>` flag instead to specifically allow it.

        Can not be used together with `/no-expand-env`, `/EE<N>` flags.

        Can be used together with `/allow-expand-unexisted-env` flag.

        Has no effect on `{*}` and `{@}` variable values.

      /EE<N>
        The same as `/E<N>` but additionally allows expansion of unexisted
        `${...}` environment variables.

        Can not be used together with `/no-expand-env`,
        `/allow-expand-unexisted-env`, `/expand-env-arg<N>`, `/E<N>` flags.

      /subst-vars-arg<N>
      /S<N>
        Substitute `{...}` variables exclusively for `<N>` command line
        argument, where `<N>` >= 0. This turns off the substitution for the
        rest of arguments if not specifically enabled.
        Empty arguments is not substituted by default, use `/SE<N>` flag
        instead to specifically allow it.

        Can not be used together with `/no-subst-vars`, `/no-subst-pos-vars`,
        `/SE<N>` flags.

        Can be used together with `/allow-subst-empty-args` flag.

        Has no effect on `{*}` and `{@}` variable values.

      /SE<N>
        The same as `/S<N>` but additionally allows substitution of empty
        `{...}` variables.
        Still can not apply to command line arguments which does not exist,
        so to avoid that do use quotes without an argument.

        Can not be used together with `/no-subst-vars`, `/no-subst-pos-vars`,
        `/allow-subst-empty-args`, `/subst-vars-arg<N>`, `/S<N>` flags.

      /allow-throw-seh-except
        Allow to throw SEH exceptions out of process. By default all SEH
        exceptions does intercept and convert into specific error code.

      /allow-expand-unexisted-env
        Allow expansion of unexisted `${...}` environment variables in
        all command line arguments.

        Can not be used together with `/no-expand-env`, `/EE<N>` flags.

        Has effect on `{*}` and `{@}` variable values.

      /allow-subst-empty-args
        Allow substitution of empty `{...}` variables in all command line
        arguments.
        Still can not apply to command line arguments which does not exist,
        so to avoid that do use quotes without an argument.

        Can not be used together with `/no-subst-vars`, `/no-subst-pos-vars`,
        `/SE<N>` flags.

        Has effect on `{*}` and `{@}` variable values, but not on the variable
        placeholders, because they always substitutes.

      /load-parent-proc-init-env-vars
        Loads environment variables existed on the moment of a process
        initialization in the parent or ancestor process with internal shared
        memory name (by default in the `callf` or `callfg` process).
        Intermediate processes can exist between an ancestor and this-process
        and does not affect on loading if did not allocate a shared memory
        with internal name.

      /no-std-inherit
        Prevent all standard handles inheritance into child process.

        Can not be used together with `/no-stdin-inherit`,
        `/no-stdout-inherit`, `/no-stderr-inherit` flags.

      /no-stdin-inherit
        Prevent stdin handle inheritance into child process.

        Can not be used together with `/no-std-inherit` flag.

      /no-stdout-inherit
        Prevent stdout handle inheritance into child process.

        Can not be used together with `/no-std-inherit` flag.

      /no-stderr-inherit
        Prevent stderr handle inheritance into child process.

        Can not be used together with `/no-std-inherit` flag.

      /pipe-stdin-to-child-stdin
        Pipe this-process stdin into child stdin. This additionally disables
        stdin handle inheritance.

        Can not be used together with `/pipe-stdin-to-stdout`,
        `/write-console-stdin-back` flags.

        Has no effect if idle execution is used.

      /pipe-child-stdout-to-stdout
        Pipe child stdout to this-process stdout. This additionally disables
        stdout handle inheritance.

        Can not be used together with `/pipe-stdin-to-stdout` flag.

        Has no effect if idle execution is used.

      /pipe-child-stderr-to-stderr
        Pipe child stderr to this-process stderr. This additionally disables
        stderr handle inheritance.

        Can not be used together with `/pipe-stdin-to-stdout` flag.

        Has no effect if idle execution is used.

      /pipe-inout-child
        Implies `/pipe-stdin-to-child-stdin`, `/pipe-child-stdout-to-stdout`,
        `/pipe-child-stderr-to-stderr` flags altogether.

        Can not be used together with `/pipe-out-child`,
        `/pipe-stdin-to-stdout`, `/write-console-stdin-back` flags.

        Has no effect if idle execution is used.

      /pipe-out-child
        Implies `/pipe-child-stdout-to-stdout`, `/pipe-child-stderr-to-stderr`
        flags altogether.

        Can not be used together with `/pipe-inout-child`,
        `/pipe-stdin-to-stdout` flag.

        Has no effect if idle execution is used.

      /pipe-stdin-to-stdout
        Pipe this-process stdin into stdout. This additionally disables
        standard handles inheritance (implies `/no-stdin-inherit` and
        `/no-stdout-inherit` flags).

        Automatically implies if idle execution is used.
        Can not be used together with `/pipe-stdin-to-child-stdin`,
        `/pipe-child-stdout-to-stdout`, `/pipe-child-stderr-to-stderr`,
        `/pipe-inout-child`, `/pipe-out-child`, `/write-console-stdin-back`
        flags.

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

      /wait-child-first-time-timeout <timeout>
        Child first time wait timeout in milliseconds.

        Has no effect if `/no-wait` flag is used.

      /elevate
      /elevate{ <ParentFlags> }[{ <ChildFlags> }]
        Self elevate process upto elevated privileges.
        If this-process has no elevated privileges, then does use
        ShellExecute with elevation to start new this-process with the same
        command line but different options and flags before run a child
        process.
        If this-process already has elevated privileges, then has no effect.
        Silently overrides the same regular flags.

        Can not be used together with `/unelevate*`, `/demote*` options and
        flags.

        <ParentFlags>:
          Limited set of flags to pass exceptionally into the this-parent
          (not elevated) process.

          /no-sys-dialog-ui
          /no-wait
          /no-window
          /no-window-console
          /init-com
          /showas
          /use-stdin-as-piped-from-conin
          /reopen-std[in|out|err]*
          /std[in|out|err]-* (except std[out|err]-vt100)
          /output-*          (except output-vt100)
          /inout-*
          /create-[in|out]outbound-*
          /mutex-std-*
          /create-console-title
          /own-console-title
          /console-title
          /stdin-echo
          /no-stdin-echo
          /eval-backslash-esc or /e
          /eval-dbl-backslash-esc or /e\\

        <ChildFlags>:
          Limited set of flags to pass exceptionally into the this-child
          (elevated) process.

          /no-expand-env
          /load-parent-proc-init-env-vars
          /use-stdin-as-piped-from-conin
          /reopen-std[in|out|err]*
          /std[in|out|err]-* (except std[out|err]-vt100)
          /output-*          (except output-vt100)
          /inout-*
          /mutex-std-*
          /attach-parent-console
          /create-console-title
          /own-console-title
          /console-title

        In that case you should use either regular flags and options or
        `/promote*{ ... }` option.

        All nested flags has no effect if elevation is not executed.

      /promote{ <Flags> }
        In case if `/elevate*` flag or option is used and executed, then does
        declare `<Flags>` for both the this-parent (not elevated) process and
        the this-child (elevated) process.
        In case if `/elevate*` flag or option is not used or is not executed,
        then does declare `<Flags>` for the this-process only.

        The same flag can not be used together with `/promote-parent{ ... }`
        option. Silently overrides the same regular flags.

        Can not be used together with `/unelevate*`, `/demote*` options and
        flags.

        <Flags>:
          /ret-create-proc
          /ret-win-error
          /ret-child-exit
          /print-win-error-string
          /print-shell-error-string
          /no-print-gen-error-string
          /pause-on-exit-if-error-before-exec
          /pause-on-exit-if-error
          /pause-on-exit
          /skip-pause-on-detached-console
          /load-parent-proc-init-env-vars
          /wait-child-first-time-timeout
          /allow-throw-seh-except
          /create-console
          /detach-console
          /detach-inherited-console-on-wait
          /attach-parent-console
          /disable-wow64-fs-redir
          /disable-ctrl-signals
          /disable-ctrl-c-signal
          /allow-gui-autoattach-to-parent-console
          /disable-conout-reattach-to-visible-console
          /allow-conout-attach-to-invisible-parent-console
          /disable-conout-duplicate-to-parent-console-on-error

      /promote-parent{ <Flags> }
        Does declare `<Flags>` for the this-parent or this-process only
        independently to `/elevate*` flag or option. The same as
        `/promote{ ... }` option but does not affect child this-process.

        The same flag can not be used together with `/promote{ ... }`
        option. Silently overrides the same regular flags.

        Can not be used together with `/unelevate*`, `/demote*` options and
        flags.

        <Flags>:
          /ret-create-proc
          /ret-win-error
          /ret-child-exit
          /pause-on-exit-if-error-before-exec
          /pause-on-exit-if-error
          /pause-on-exit
          /skip-pause-on-detached-console
          /load-parent-proc-init-env-vars
          /no-std*-inherit
          /wait-child-first-time-timeout
          /allow-throw-seh-except
          /use-stdin-as-piped-from-conin
          /reopen-std[in|out|err]*
          /std[in|out|err]-*
          /output-*
          /inout-*
          /tee-std[in|out|err]*
          /tee-conout-dup
          /tee-output*
          /tee-inout*
          /mutex-std-*
          /mutex-tee-*
          /create-console
          /detach-console
          /detach-inherited-console-on-wait
          /attach-parent-console
          /disable-wow64-fs-redir
          /disable-ctrl-signals
          /disable-ctrl-c-signals
          /allow-gui-autoattach-to-parent-console
          /disable-conout-reattach-to-visible-console
          /allow-conout-attach-to-invisible-parent-console
          /disable-conout-duplicate-to-parent-console-on-error
          /write-console-stdin-back

      /unelevate
      /unelevate{ <ParentFlags> }[{ <ChildFlags> }]
        Self unelevate process downfrom elevated privileges account to an
        unelevated original user account.

        If this-process has elevated privileges, then use a call to
        CreateProcessWithToken to start new this-process with the same
        command line but different options and flags before run a child
        process.
        If this-process already has no elevated privileges, then has no
        effect.

        The default method has used is described for `/unelevate-1` option.

        Can not be used together with `/elevate*`, `/promote*` and others
        `/unelevate*` options and flags.

        All the rest options has the same meaning as for `/elevate*` option.

      /unelevate-1
      /unelevate-1{ <ParentFlags> }[{ <ChildFlags> }]
      /unelevate-by-search-proc-to-adjust-token
      /unelevate-by-search-proc-to-adjust-token{ <ParentFlags> }[{ <ChildFlags> }]
        Shortcut to SearchProcToAdjustToken method of unelevation.

        If this-process has elevated privileges, then does search for an
        original user process token to adjust it to an unelevated process
        token to use it in a call to CreateProcessWithToken to start new
        this-process with the same command line but different options and
        flags before run a child process.
        If this-process already has no elevated privileges, then has no
        effect.

        Can not be used together with `/elevate*`, `/promote*` and others
        `/unelevate*` options and flags.

        All the rest options has the same meaning as for `/elevate*` option.

      /unelevate-2
      /unelevate-2{ <ParentFlags> }[{ <ChildFlags> }]
      /unelevate-by-shell-exec-from-explorer
      /unelevate-by-shell-exec-from-explorer{ <ParentFlags> }[{ <ChildFlags> }]
        Shortcut to ShellExecuteFromExplorer method of unelevation.

        If this-process has elevated privileges, then does use SaferAPI to
        compute the token to use it in a call to CreateProcessWithToken to
        start new this-process with the same command line but different
        options and flags before run a child process.
        If this-process already has no elevated privileges, then has no
        effect.

        CAUTION:
          Implementation does use IShellDispatch2::ShellExecute interface
          function which does not return a child process handle to wait on.
          So this-parent will not wait this-child process to close and a
          parent process of the this-child will be the Windows Shell process
          instead of the this-process.

        Can not be used together with `/shell-exec-unelevate-from-explorer`,
        `/elevate*`, `/promote*` and others `/unelevate*` options and flags.

        All the rest options has the same meaning as for `/elevate*` option.

      /demote{ <Flags> }
        In case if `/unelevate*` flag or option is used and executed, then
        does declare `<Flags>` for both the this-parent (elevated) process and
        the this-child (unelevated) process.
        In case if `/unelevate*` flag or option is not used or is not
        executed, then does declare `<Flags>` for the this-process only.

        The same flag can not be used together with `/deomote-parent{ ... }`
        option. Silently overrides the same regular flags.

        Can not be used together with `/elevate*` and `/promote*` options and
        flags.

        All the rest options has the same meaning as for `/promote{ ... }`
        option.

      /demote-parent{ <Flags> }
        Does declare `<Flags>` for the this-parent or this-process only
        independently to `/unelevate*` flag or option. The same as
        `/demote{ ... }` option but does not affect child this-process.

        The same flag can not be used together with `/demote{ ... }`
        option. Silently overrides the same regular flags.

        Can not be used together with `/elevate*`, `/promote*` options and
        flags.

        All the rest options has the same meaning as for
        `/promote-parent{ ... }` option.

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

      /use-stdin-as-piped-from-conin
        Treat initial this-process stdin pipe handle as pipe from the console
        input and close on this-process exit both the initial stdin handle and
        the stdin pipe end process console input handle to trigger the
        ReadConsole function.

        ex: `type con | callf /use-stdin-as-piped-from-conin "" "cmd.exe /k"`

        CAUTION: stdin pipe end process injection is not implemented

      /reopen-stdin <file>
        Reopen stdin as a `<file>` to read from.

        Can not be used together with another `/reopen-stdin-as-*` option.

        Can be used to read from a file instead from the stdin.

      /reopen-stdin-as-server-pipe <pipe>
        Reopen stdin as inbound server pipe `<pipe>` to read from.

        Can not be used together with `/reopen-stdin` or another
        `/reopen-stdin-as-*` option.

        Can be used to read from a named pipe instead from the stdin.

      /reopen-stdin-as-server-pipe-connect-timeout <timeout>
        Timeout in milliseconds to wait for an outbound client named pipe
        `<pipe>` connection to an inbound server named pipe attached to
        this-process stdin. By default 30 seconds timeout is used.

      /reopen-stdin-as-server-pipe-in-buf-size <size>
        Inbound server named pipe `<pipe>` input buffer size in bytes have
        used to reopen this-process stdin.

      /reopen-stdin-as-server-pipe-out-buf-size <size>
        Inbound server named pipe `<pipe>` output buffer size in bytes have
        used to reopen this-process stdin.

      /reopen-stdin-as-client-pipe <pipe>
        Reopen stdin as inbound client named pipe `<pipe>` to read from.

        Can not be used together with `/reopen-stdin` or another
        `/reopen-stdin-as-*` option.

        Can be used to read from a named pipe instead from the stdin.

      /reopen-stdin-as-client-pipe-connect-timeout <timeout>
        Timeout in milliseconds to wait for an outbound server named pipe
        `<pipe>` connection to an inbound client named pipe attached to
        this-process stdin. By default 30 seconds timeout is used.

      /reopen-std[out|err] <file>
        Reopen stdout/stderr as a `<file>` to write to.

        Can not be used together with another `/reopen-std[out|err]-as-*`
        option.

        Can not be used together with the same `/std[out|err]-dup` option.

        Can be used to write to a file instead to the stdout/stderr.

        Can be used together with `/tee-std[out|err]*` options.

      /reopen-std[out|err]-as-server-pipe <pipe>
        Reopen stdout/stderr as outbound server pipe `<pipe>` to write to.

        Can not be used together with `/reopen-std[out|err]` or another
        `/reopen-std[out|err]-as-*` option.

        Can not be used together with the same `/std[out|err]-dup` option.

        Can be used to write to a named pipe instead of the stdout/stderr.

      /reopen-std[out|err]-as-server-pipe-connect-timeout <timeout>
        Timeout in milliseconds to wait for an inbound client named pipe
        `<pipe>` connection from an outbound server named pipe attached to
        this-process stdout/stderr. By default 30 seconds timeout is used.

      /reopen-std[out|err]-as-server-pipe-in-buf-size <size>
        Outbound server named pipe `<pipe>` input buffer size in bytes have
        used to reopen this-process stdout/stderr.

      /reopen-std[out|err]-as-server-pipe-out-buf-size <size>
        Outbound server named pipe `<pipe>` output buffer size in bytes have
        used to reopen this-process stdout/stderr.

      /reopen-std[out|err]-as-client-pipe <pipe>
        Reopen stdout/stderr as outbound client named pipe `<pipe>` to write
        to.

        Can not be used together with `/reopen-std[out|err]` or
        another `/reopen-std[out|err]-as-*` option.

        Can not be used together with the same `/std[out|err]-dup` option.

        Can be used to write to a named pipe instead to the stdout/stderr.

      /reopen-std[out|err]-as-client-pipe-connect-timeout <timeout>
        Timeout in milliseconds to wait for an inbound server named pipe
        `<pipe>` connection from an outbound client named pipe attached to
        this-process stdout/stderr. By default 30 seconds timeout is used.

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
        Flush after each write into an output handle attached to this-process
        stdin. Basically used if this-process stdin is redirected
        from a file or an anonymous/named pipe.
        
        Has no effect if this-process stdin is a console (character) handle
        (not redirected).

      /std[out|err]-flush
        Flush after each write into this-process stdout/stderr.

      /output-flush
        Flush after each write into this-process stdout and stderr.

      /inout-flush
        Flush after each write into an output handle attached to this-process
        stdin or write into this-process stdout/stderr. The same as
        `/stdin-output-flush` plus after each write into this-process
        stdout/stderr.

      /stdout-vt100
        Enable processing VT100 and similar control character sequences on
        stdout.

        Can not be used together with `/output-vt100` flag.

        Has no effect on Windows lower than Windows 10 build 10586.

      /stderr-vt100
        Enable processing VT100 and similar control character sequences on
        stderr.

        Can not be used together with `/output-vt100` flag.

        Has no effect on Windows lower than Windows 10 build 10586.

      /output-vt100
        Enable processing VT100 and similar control character sequences on
        stdout and stderr.

        Can not be used together with `/stdout-vt100` and `/stderr-vt100`
        flags.

        Has no effect on Windows lower than Windows 10 build 10586.

      /create-outbound-server-pipe-from-stdin <pipe>
        Create outbound server named pipe `<pipe>` instead of anonymous as by
        default to write into a child process stdin from this-process stdin.
        Useful to write stream to (un)elevated this-child process or a child
        (un)elevated process.

      /create-outbound-server-pipe-from-stdin-connect-timeout <timeout>
        Timeout in milliseconds to wait for an inbound client named pipe
        `<pipe>` connection from an outbound server named pipe attached to
        this-process stdin. By default 30 seconds timeout is used.

      /create-outbound-server-pipe-from-stdin-in-buf-size <size>
        Outbound server named pipe `<pipe>` input buffer size in bytes have
        used to write into from this-process stdin.

      /create-outbound-server-pipe-from-stdin-out-buf-size <size>
        Outbound server named pipe `<pipe>` output buffer size in bytes have
        used to write into from this-process stdin.

      /create-inbound-server-pipe-to-std[out|err] <pipe>
        Create inbound server named pipe `<pipe>` instead of anonymous as by
        default to read from a child process stdout/stderr to write into
        this-process stdout/stderr.
        Useful to read stream from (un)elevated this-child process or a child
        (un)elevated process.

      /create-inbound-server-pipe-to-std[out|err]-connect-timeout <timeout>
        Timeout in milliseconds to wait for an outbound client named pipe
        `<pipe>` connection to an inbound server named pipe attached to
        this-process stdout/stderr. By default 30 seconds timeout is used.

      /create-inbound-server-pipe-to-std[out|err]-in-buf-size <size>
        Inbound server named pipe `<pipe>` input buffer size in bytes have
        used to read from into this-process stdout/stderr.

      /create-inbound-server-pipe-to-std[out|err]-out-buf-size <size>
        Inbound server named pipe `<pipe>` output buffer size in bytes have
        used to read from into this-process stdout/stderr.

      /tee-stdin <file>
        Duplicate stdin to a tee file `<file>`.

        Can be used together with another `/tee-stdin-to-*` flag.

        DOES NOT imply `/pipe-stdin-to-child-stdin` flag.

        To pipe input into a child process you have explicitly use one of
        these flags:
          /pipe-stdin-to-child-stdin
          /write-console-stdin-back

      /tee-std[out|err] <file>
        Duplicate standard output stream to a tee file `<file>`.

        Can be used together with another `/tee-std[out|err]-to-*` flag.

        DOES imply respective `/pipe-child-std[out|err]-to-std[out|err]` flag.

      /tee-std[in|out|err]-to-server-pipe <pipe>
        Duplicate standard stream to a tee outbound server named pipe `<pipe>`
        to write to.

        Can not be used together with the
        `/tee-std[in|out|err]-to-server-pipe` option.

        Can not be used together with the same `/tee-std[in|out|err]-dup`
        option.

        Can be used together with `/tee-std[in|out|err]` option.

      /tee-std[in|out|err]-to-server-pipe-connect-timeout <timeout>
        Timeout in milliseconds to wait for an inbound client named pipe
        `<pipe>` connection from an outbound server named pipe attached to
        this-process stdin/stdout/stderr as source. By default 30 seconds
        timeout is used.

      /tee-std[in|out|err]-to-server-pipe-in-buf-size <size>
        Outbound server named pipe `<pipe>` input buffer size in bytes have
        used to duplicate this-process stdin/stdout/stderr as source.

      /tee-std[in|out|err]-to-server-pipe-out-buf-size <size>
        Outbound server named pipe `<pipe>` output buffer size in bytes have
        used to duplicate this-process stdin/stdout/stderr as source.

      /tee-std[in|out|err]-to-client-pipe <pipe>
        Duplicate standard stream to a tee outbound client named pipe `<pipe>`
        to write to.

        Can not be used together with the
        `/tee-std[in|out|err]-to-server-pipe` option.

        Can not be used together with the same `/tee-std[in|out|err]-dup`
        option.

        Can be used together with `/tee-std[in|out|err]` option.

      /tee-std[in|out|err]-to-client-pipe-connect-timeout <timeout>
        Timeout in milliseconds to wait for an inbound server named pipe
        `<pipe>` connection from an outbound client named pipe attached to
        this-process stdin/stdout/stderr as source. By default 30 seconds
        timeout is used.

      /tee-std[in|out|err]-dup <fileno>
        Duplicate the tee respective handle from another one, where the
        `<fileno>` is the source handle index:
          0 = stdin, 1 = stdout, 2 = stderr.

        Must be used after a respective `/tee-std[in|out|err] <fileno>`
        option. Has the same behaviour as a sequence of respective
        `/tee-stdin`, `/tee-stdout` or `/tee-stderr` options with the same
        `<fileno>` and so can be used instead.

      /tee-conout-dup
        Duplicate the tee stdout and stderr handle from tee stdin.
        Has the same behaviour as a sequence of `/tee-stdout-dup 0` and
        `/tee-stderr-dup 0` options and so can be used instead.

      /tee-std[in|out|err]-file-truncate
        Truncate instead of append on a tee file `<file>` open.

      /tee-std[in|out|err]-file-flush
        Flush after each write into a tee file `<file>`.

      /tee-std[in|out|err]-pipe-flush
        Flush after each write into a tee named pipe `<pipe>`.

      /tee-std[in|out|err]-flush
        Flush after each write into a tee file `<file> or a tee named pipe
        `<pipe>` have used to split output from this-process
        stdin/stdout/stderr.

      /tee-output-flush
        Flush after each write into a tee file `<file> or a named pipe
        `<pipe>` have used to split output from this-process stdout and stderr.

      /tee-inout-flush
        Flush after each write into a tee file `<file> or a named pipe
        `<pipe>` have used to split output from this-process stdin and stdout
        and stderr.

      /tee-std[in|out|err]-pipe-buf-size <size>
        Anonymous pipe buffer size in bytes attached directly to the child
        process stdin/stdout/stderr.

        Has no effect if a respective named pipe is used.

      /tee-std[in|out|err]-read-buf-size <size>
        Buffer size in bytes to read from this-process stdin.
        Buffer size in bytes to read from a child process stdout/stderr.

      /mutex-std-writes
        In case of a write into reopened standard handle opened from a file
        does mutual excluded write into the same file from different
        processes.
        Each unique opened file entity associated with an unique mutex.
        The handle file pointer moves to the end each time after the mutex is
        locked to guarantee write into the file end between processes.

        Has no effect in case of a write into not reopened (inherited)
        standard handle. In this case synchronization depends on the Win32 API
        and basically happens when all writes does perform on the same handle
        (for example, when stderr has duplicated from stdout). If handles are
        different (each opened separately from the same file), then
        this-process tries to compare file entity identifiers and detect file
        handles equality (the same file opened from may be different file
        paths) to replace already opened second handle by a first file handle
        duplication.

      /mutex-tee-file-writes
        Does mutual excluded write into the same file from different
        processes.
        Each unique opened file entity associated with an unique mutex.
        The handle file pointer moves to the end each time after the mutex is
        locked to guarantee write into the file end between processes.
        Synchronization depends on the Win32 API and basically happens when
        all writes does perform on the same handle (for example, when stderr
        has duplicated from stdout). If handles are different (each opened
        separately from the same file), then this-process tries to compare
        file entity identifiers and detect file handles equality (the same
        file opened from may be different file paths) to replace already
        opened second handle by a first file handle duplication.

      /create-child-console
        Create new console for a child process, otherwise a child process
        inherits a parent process console if exists.

        CreateProcess
          Uses CREATE_NEW_CONSOLE flag.
        ShellExecute
          Removes usage of the SEE_MASK_NO_CONSOLE flag.

        Has priority over `/no-window-console` flag.
        Can not be used together with `/detach-child-console` flag.

      /detach-child-console
        Create child process with detached console.

        CreateProcess
          Uses DETACHED_PROCESS flag.
        ShellExecute
          Has no effect, just uses SEE_MASK_NO_CONSOLE flag.

        Can not be used together with `/create-child-console` and
        `/no-window-console` flags.

      /create-console
        Create this-process console if not exists. If this-process console
        exists, owned and not visible, then shows it.
        If this-process console exists and not owned (inherited), then
        creates new console.
        
        Can not be used together with `/detach-console` and
        `/detach-inherited-console-on-wait` flags.

        Has priority over `/attach-parent-console` flag.

        Has no effect if this-process console already exists, owned and
        visible.

      /detach-console
        Detach this-process console if exists.

        Can not be used together with `/create-console` and
        `/attach-parent-console` flags.

      /detach-inherited-console-on-wait
        Detach this-process inherited console on waiting child process exit
        and reattach after the exit.

        Can not be used together with `/create-console` and `no-wait` flags.

        Has no effect if console is already detached or owned.

        May has meaning in particular cases where attachment to the same
        console can alter execution in a child process.

      /attach-parent-console
        Attach console from a parent process or it's ancestors. If
        this-process console is owned, then detaches it at first.

        Can not be used together with `/detach-console` flag.

        Has no effect if this-process console exists but not owned
        (inherited).

        Has no effect if `/create-console` is used.

      /create-console-title <title>
        Change console window title on the this-process console creation or
        recreation.
        
        Can be used together with `/own-console-title` option.

        Overrides `/console-title` option.

        Has no effect if this-process console is not owned.

      /own-console-title <title>
        Change console window title if this-process console is owned.

        Can be used together with `/create-console-title` option.

        Overrides `/console-title` option.

        Has no effect on inherited console.

      /console-title <title>
        Change console window title. Applies only if non of
        `/create-console-title` and `/own-console-title` is applied.

      /stdin-echo
        Explicitly enable console input buffer echo before start of a child
        process.

        Can not be used together with `/no-stdin-echo` flag.

      /no-stdin-echo
        Explicitly disable console input buffer echo before start of a child
        process.

        Can not be used together with `/stdin-echo` flag.

      /replace-args-in-tail <from> <to>
      /ra <from> <to>
        Replace `<from>` string by `<to>` string in tail command line
        arguments (arguments arter the first one).

      /replace-args <from> <to>
      /replace-arg<N> <from> <to>
      /r <from> <to>
      /r<N> <from> <to>
        Replace `<from>` string by `<to>` string for either all command line
        arguments or `<N>` command line argument, where `<N>` >= 0.

      /eval-backslash-esc
      /eval-backslash-esc<N>
      /e
      /e<N>
        Evaluate escape characters for either all arguments or `<N>` command
        line argument, where `<N>` >= 0:
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

      /eval-dbl-backslash-esc
      /e\\
        Evaluate double backslash escape characters:
          \\ = backslash

      /set-env-var <name> <value>
      /v
        Set environment variable of name `<name>` to value `<value>`.
        If `<value>` is empty, the variable is deleted.

    Special flags:
      /disable-wow64-fs-redir
        Disables file system redirection for the WOW64 process.

      /disable-ctrl-signals
        Disable all control signals handling in this-process such as:
          CTRL_C_EVENT         = 0
          CTRL_BREAK_EVENT     = 1
          CTRL_CLOSE_EVENT     = 2
          CTRL_LOGOFF_EVENT    = 5
          CTRL_SHUTDOWN_EVENT  = 6

      /disable-ctrl-c-signal
        Disable only CTRL-C signal handling in this-process.
        All other control signals will be passed into child process.

      /allow-gui-autoattach-to-parent-console
        In case if this-process console is not attached, then this-process
        tries to attach to a parent process console. To allow that use this
        flag.

        Has meaning and implemented only for `callfg` executable.

      /disable-conout-reattach-to-visible-console
        In case if this-process console is not visible and a parent process
        console is visible, then before print any output the application tries
        to attach to a parent process console to enable the user to read
        futher output into console before a child process start. To disable
        that use this flag.

      /allow-conout-attach-to-invisible-parent-console
        In case of search a parent process tree for processes with attached
        console, the flag allows to attach to an invisible console.
        By default parent processes tree with invisible consoles has to be
        skipped while searching for a console to attach.

        Has no effect if `/attach-parent-console` is not used.

        Does not related to the
        `/disable-conout-reattach-to-visible-console` flag usage.

      /disable-conout-duplicate-to-parent-console-on-error
        In case if this-process has own the console window, then this-process
        tries to save all the output to the stdout/stderr to duplicate it
        later to a parent process console in case of application early exit
        just before a child process start. This happens because a leaf process
        owned console window does close upon this-process exit and the user
        won't see the stdout/stderr output. Saved content print on
        this-process exit just before a child process start and is not happen
        if an error is not happened before a child process start. To disable
        that use this flag.

      /write-console-stdin-back
        When both this-process and a child process stdin is a character device
        (console), then this-process may write console input back to pass the
        last read input to a child process. A child process must use the same
        console input buffer and ReadConsole function call in that case,
        otherwise there is a chance of fall into an infinite input loop in
        this-proces.

        Can not be used together with `/pipe-stdin-to-child-stdin`,
        `/pipe-inout-child`, `/pipe-stdin-to-stdout` flags.

        Has no effect when a child process stdin is piped from this-process
        stdin.

    <ApplicationNameFormatString>, <CommandLineFormatString>,
    <FilePathFormatString>, <ParametersFormatString>,
    <ArgN> placeholders:
      ${<VarName>} - <VarName> environment variable value.
      {0}    - first argument value.
      {N}    - N'th argument value.
      {@}    - tail arguments as raw string.
      {*}    - first and tail arguments as raw string.
      {0hs}  - first argument hexidecimal string (00-FF per character).
      {Nhs}  - N'th arguments hexidecimal string (00-FF per character).
      \{     - '{' character escape.

      The `{*}` and `{@}` variables always substitutes even if value is empty,
      except if `/no-subst-empty-tail-vars` flag is defined.

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
      This-process loops stdin into stdout until EOF or a pipe close.
      This-process does wait only if stdin is a file or a pipe, otherwise a
      call has no effect. Stderr does not used on idle execution and all
      operations over it has no effect.

    Elevation:
      If one of `/elevate*` or `/unelevate*` flags are used, then most of
      regular flags does pass into child process command line. To use a flag
      for the parent process or specifically for the elevation execution or
      irrelatively to the elevation execution you must use a nested version of
      regular flags and options inside these options:
        `/elevate{ ... }{ ... }`, `/promote{ ... }`, `/promote-parent{ ... }`,
        `/unelevate{ ... }{ ... }`, `/demote{ ... }`, `/demote-parent{ ... }`

    Pipe name placeholders:
      {pid}     - this-process identifier as decimal number
      {ppid}    - parent process identifier as decimal number

    In case of ShellExecute the <ParametersFormatString> must contain only a
    command line arguments, but not the path to the executable (or document)
    itself which is part of <CommandLineFormatString>!

    If <CurrentDirectory> is not defined, then the current working directory
    is used.

  Return codes if `/ret-*` option is not defined:
   -255 - unspecified error
   -254 - SEH exception
   -128 - help output
   -7   - named pipe connection timeout
   -6   - named pipe connection error
   -5   - input/output error
   -4   - Win32 or COM error
   -2   - invalid format
   -1   - both <ApplicationNameFormatString> and <CommandLineFormatString>
          are empty or <FilePathFormatString> is empty.
    0   - succeded

  Examples (CreateProcess, no recursion, `cmd.exe` different escaping rules):
    1. callf.exe "${WINDIR}\system32\cmd.exe" "{0} {1}" "/c" "echo.Hello World!"
    2. callf.exe "${COMSPEC}" "{0} {1}" "/c" "echo.Hello World!"
    3. callf.exe "{0}" "\"{1}\" {2}" "${COMSPEC}" "/c" "echo.Hello World!"
    4. callf.exe "" "\"{0}\" {1} {2}" "cmd.exe" "/c" "echo.Hello World!"
    5. callf.exe "" "\"{0}\" {1} {2}" "${WINDIR}\system32\cmd.exe" "/c" "echo.Hello World!"
    6. callf.exe "" "\"{0}\" {@}" "${WINDIR}\system32\cmd.exe" /c echo.Hello World!
    7. callf.exe "" "{*}" "${WINDIR}\system32\cmd.exe" /c echo.Hello World!

    6. callf.exe "${COMSPEC}" "/c echo.Special case characters: ^|^&""|& ^ |&""^|^& ^^ ^|^&""|& ^ |&""^|^&&pause"
    7. callf.exe "${COMSPEC}" "/c echo.Special case characters: ^|^&\"^|^& ^^ ^|^&\"^|^& ^^ ^|^&\"^|^& ^^ ^|^&\"^|^&&pause"
    8. callf.exe "${COMSPEC}" "/c \"echo.Special case characters: ^^^|^^^&\"|& ^ |&\"^^^|^^^& ^^^^ ^^^|^^^&\"|& ^ |&\"^^^|^^^&^&pause\""

    Examples #1-5 should print:
      Hello World!

    Examples #6-8 should print and pause after:
      Special case characters: |&"|& ^ |&"|& ^ |&"|& ^ |&"|&

  Examples (CreateProcess, with recursion):
    1. callf.exe "" "\"${COMSPEC}\" /c echo.{0}" "%%TIME%%"
    2. callf.exe "" "callf.exe \"\" \"\\\"$\{COMSPEC}\\\" /c echo.{0}\" \"%%TIME%%\""
    3. callf.exe "" "callf.exe \"\" \"callf.exe \\\"\\\" \\\"\\\\\\\"$\\{COMSPEC}\\\\\\\" /c echo.{0}\\\" \\\"%%TIME%%\\\"\""

    4. callf.exe "" "\"${COMSPEC}\" /c echo.{0}" "%TIME%"
    5. callf.exe "" "callf.exe \"\" \"\\\"$\{COMSPEC}\\\" /c echo.{0}\" \"%TIME%\""
    6. callf.exe "" "callf.exe \"\" \"callf.exe \\\"\\\" \\\"\\\\\\\"$\\{COMSPEC}\\\\\\\" /c echo.{0}\\\" \\\"%TIME%\\\"\""

    Examples #1-3 must be run from the cmd.exe batch file (.bat).

    Examples #4-6 must be typed in the cmd.exe console window.

  Examples (CreateProcess/ShellExecute):
     1. callf.exe /attach-parent-console "${COMSPEC}" "/k"
     2. callf.exe /shell-exec open /no-sys-dialog-ui "${COMSPEC}" "/k"
     3. callf.exe /shell-exec open /no-sys-dialog-ui /attach-parent-console "${COMSPEC}" "/k"
     
     4. callf.exe /create-child-console "${COMSPEC}" "/k"
     5. callf.exe "callf.exe" "/create-console \"\" \"\\\"${COMSPEC}\\\" /k"
     6. callf.exe /shell-exec open /no-sys-dialog-ui /create-child-console "${COMSPEC}" "/k"
     7. callf.exe /shell-exec open /no-sys-dialog-ui "callf.exe" "/create-console \"\" \"\\\"${COMSPEC}\\\" /k"
     
     8. callf.exe /shell-exec runas /no-sys-dialog-ui "${COMSPEC}" "/k"
     9. callf.exe /shell-exec runas /no-sys-dialog-ui /attach-parent-console "${COMSPEC}" "/k"
    10. callf.exe /shell-exec runas /no-sys-dialog-ui /no-window "callf.exe" "\"\" \"\\\"${COMSPEC}\\\" /k"
    11. callf.exe /shell-exec runas /no-sys-dialog-ui /no-window "callf.exe" "/attach-parent-console \"\" \"\\\"${COMSPEC}\\\" /k"

    Examples #1-3 must be run in the same console.

    Examples #4-7 must be run in the new (child) console.

    Examples #8-9 must request the Administrator permission to execute in the
    new (child) console.

    Examples #10-11 must request the Administrator permission to execute in
    the existing (parent) console.

  Examples (CreateProcess/ShellExecute, with named pipes and idle execution with stdin-to-stdout piping):
    1. callf.exe /reopen-stdin 0.in .
    2. callf.exe /reopen-stdin 0.in "" "cmd.exe /k"

    3. callf.exe /reopen-stdin 0.in /reopen-stdout-as-server-pipe test123_{pid} /pipe-stdin-to-stdout "" "callf.exe /reopen-stdin-as-client-pipe test123_{ppid} ."
    4. callf.exe /reopen-stdin 0.in /reopen-stdout-as-server-pipe test123_{pid} /pipe-stdin-to-stdout "" "callf.exe /reopen-stdin-as-client-pipe test123_{ppid} \"\" \"cmd.exe /k\""

    5. callf.exe /reopen-stdin 0.in /reopen-stdout-as-server-pipe test123_{pid} /pipe-stdin-to-stdout /shell-exec runas /no-sys-dialog-ui /no-window "callf.exe" "/attach-parent-console /reopen-stdin-as-client-pipe test123_{ppid} ."
    6. callf.exe /reopen-stdin 0.in /reopen-stdout-as-server-pipe test123_{pid} /pipe-stdin-to-stdout /shell-exec runas /no-sys-dialog-ui /no-window "callf.exe" "/attach-parent-console /reopen-stdin-as-client-pipe test123_{ppid} \"\" \"cmd.exe /k\""

    Example #1 prints content of `0.in` file to the console.
    Example #2 writes content of `0.in` file to `cmd.exe /k` process input.

    Example #3 writes content of `0.in` file into `test123` named pipe, where
    it being read and print into the console by the child process.

    Example #4 writes content of `0.in` file into `test123` named pipe, where
    it being read and write to `cmd.exe /k` process input.

    Example #5 writes the content of `0.in` file into `test123` named pipe
    through the Administrator privileges isolation, where it being read and
    print into the existing (parent) console by the child process `callf.exe`.

    Example #6 writes content of `0.in` file into `test123` named pipe
    through the Administrator privileges isolation, where it being read and
    write to `cmd.exe /k` process input with the output has connected back
    to the child process `callf.exe` which prints to the existing (parent)
    console.

  Examples (CreateProcess/ShellExecute, elevation with redirection from/to
            named pipes):
    1. callf.exe /promote-parent{ /reopen-stdin 0.in } /elevate{ /no-window /create-outbound-server-pipe-from-stdin test0_{pid} /create-inbound-server-pipe-to-stdout test1_{pid} }{ /attach-parent-console /reopen-stdin-as-client-pipe test0_{ppid} /reopen-stdout-as-client-pipe test1_{ppid} } .
    2. callf.exe /promote-parent{ /reopen-stdin 0.in } /elevate{ /no-window /create-outbound-server-pipe-from-stdin test0_{pid} /create-inbound-server-pipe-to-stdout test1_{pid} }{ /attach-parent-console /reopen-stdin-as-client-pipe test0_{ppid} /reopen-stdout-as-client-pipe test1_{ppid} } "" "cmd.exe /k"

    Example #1 in case of elevation execution does write the content of the
    `0.in` file into `test0_{pid}` named pipe through the Administrator
    privileges isolation, where it being read and write back into the
    `test1_{pid}` named pipe to print into the existing (parent) console by
    the parent process `callf.exe`. If process has been already elevated, then
    just prints content of `0.in` file to the console.

    Example #2 in case of elevation execution does write the content of the
    `0.in` file into `test0_{pid}` named pipe through the Administrator
    privileges isolation, where it being read, processed by `cmd.exe` and
    write the output back into `test1_{pid}` named pipe to print to the
    existing (parent) console by the parent process `callf.exe`. If process has
    been already elevated, then just writes content of `0.in` file to the
    `cmd.exe /k` process input.

  Examples (CreateProcessWithToken/ShellExecute, unelevation by search an
            original user account process token):
    1. callf.exe /elevate "" "callf.exe /unelevate \"\" \"cmd.exe /k\""
    2. callf.exe /unelevate "" "callf.exe /elevate \"\" \"cmd.exe /k\""

    3. callf.exe /shell-exec runas "callf.exe" "/shell-exec-unelevate-from-explorer \"${COMSPEC}\" \"/k\""
    4. callf.exe /shell-exec-unelevate-from-explorer /D . "callf.exe" "/shell-exec runas \"${COMSPEC}\" \"/k\""

    Example #1 tries to create an elevated child this-process if this-process
    is not elevated, otherwise just executes the command line. The command
    line does create a not elevated child this-process and then creates the
    `cmd.exe /k` process.

    Example #2 tries to create a not elevated child this-process if
    this-process is elevated, otherwise just executes the command line. The
    command line does create an elevated child this-process and then creates
    the `cmd.exe /k` process.

    Example #3 tries to create an elevated child process if this-process is
    not elevated, otherwise just executes the command line. The command line
    does create a not elevated child `cmd.exe /k` process.

    Example #4 tries to create a not elevated child process if this-process is
    elevated, otherwise just executes the command line. The command line does
    create an elevated child `cmd.exe /k` process.

  Examples (CreateProcess, stdin+stdout+stderr redirection into single file
            within interactive input to console):
    1. callf.exe /tee-stdin inout.log /pipe-stdin-to-child-stdin /tee-conout-dup "${COMSPEC}" "/k"
    2. callf.exe /tee-stdin inout.log /write-console-stdin-back /tee-conout-dup "${COMSPEC}" "/k"

    Example #1 creates stdin/stdout/stderr anonymous pipes into/from the child
    `cmd.exe`process and writes them into the log file.

    Example #2 creates only stdout and stderr anonymous pipes from child
    process and writes them into the log file. The stdin gets read through the
    ReadConsole function, writes into the log file and writes back into stdin,
    where it being read again by ReadConsole from the child `cmd.exe` process.
    This one works only when only 2 processes in inheritance chain is attached
    to the same console and both does call to the ReadConsole.
