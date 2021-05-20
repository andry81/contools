[+ AutoGen5 template txt=%s.txt +]
callf.exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Create process in style of c-function printf, replacing specific backslashed
  character pairs in string arguments with characters.

Usage: callf.exe [/?] [<Flags>] [//] <ApplicationNameFormatString> [<CommandLineFormatString> [<Arg1> [<Arg2> ... [<ArgN>]]]]
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
        Return CreateProcess return code.

      /ret-win-error
        Return Win32 error code.

      /win-error-langid <LANGID>
        Language ID to format Win32 error messages.

      /ret-child-exit
        Return child process exit code (if has no `/no-wait` flag).

      /print-win-error-string
        Print Win32 error string (even if `/ret-win-error` is not set).

      /no-print-gen-error-string
        Don't print generic error string.

      /no-wait
        Don't wait a child process exit.

      /no-window
        Don't show a child process console window.

      /no-expand-env
        Don't expand `${...}` environment variables.

      /no-subst-vars
        Don't substitute `{...}` variables (command line parameters).

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

      /create-child-console
        Create new console for child process.

      /detach-parent-console
        Detach console from parent process.

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

    <ApplicationNameFormatString>, <CommandLineFormatString>:
      Win32 `CreateProcess` function 2 first parameters (see related
      documentation).

    <ApplicationNameFormatString>, <CommandLineFormatString>,
    <ArgN> placeholders:
      ${<VarName>} - <VarName> environment variable value.
      {0}    - first argument value.
      {N}    - N'th argument value.
      {0hs}  - first arguments hexidecimal string (00-FF per character).
      {Nhs}  - N'th arguments hexidecimal string (00-FF per character).
      \{     - '{' character escape

    The <ApplicationNameFormatString> can be empty, then the
    <CommandLineFormatString> must have an application file path in the first
    argument. See detailed documentation in MSDN for the function
    "CreateProcess".

  Return codes if `/ret-*` option is not defined:
   -255 - unspecified error
   -128 - help output
   -4   - Win32 error
   -2   - invalid format
   -1   - both <ApplicationNameFormatString> and <CommandLineFormatString>
          are empty.
    0   - succeded

  Examples:
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
