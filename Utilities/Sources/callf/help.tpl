[+ AutoGen5 template txt=%s.txt +]
callf.exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Create process in style of c-function printf, replacing specific backslashed
  character pairs in string arguments with characters.

Usage: callf.exe [/?] <ApplicationNameFormatString> [<CommandLineFormatString> [<Arg1> [<Arg2> ... [<ArgN>]]]]
  Description:
    - /?:
      This help.

    <ApplicationNameFormatString>, <CommandLineFormatString> placeholders:
      ${<VarName>} - <VarName> environment variable value.
      {0}    - first argument value.
      {N}    - N'th argument value.
      {0hs}  - first arguments hexidecimal string (00-FF per character).
      {Nhs}  - N'th arguments hexidecimal string (00-FF per character).
      \{     - '{' character escape

    Arguments placeholders:
      ${<VarName>} - <VarName> environment variable value.
      \{    - '{' character escape

    The <ApplicationNameFormatString> can be empty, then the
    <CommandLineFormatString> must have an application file path in the first
    argument. See detailed documentation in MSDN for the function
    "CreateProcess".

  Return codes (Positive values - errors, negative - warnings):
   -1   - empty <FormatString>.
    0   - succeded
    1   - help output
    2   - invalid format.
    3   - <VarName*> string is not defined or it's value having too big size
          (>= 32767).
    255 - unspecified error

  Examples:
    1. callf.exe "${WINDIR}\system32\cmd.exe" "{0} {1}" "/c" "echo.Hello World!"
    2. callf.exe "${COMSPEC}" "{0} {1}" "/c" "echo.Hello World!"
    3. callf.exe "{0}" "{1} {2}" "${COMSPEC}" "/c" "echo.Hello World!"
    4. callf.exe "" "{0} {1} {2}" "\"cmd.exe\"" "/c" "echo.Hello World!"
    5. callf.exe "" "{0} {1} {2}" "\"${WINDIR}\system32\cmd.exe\"" "/c" "echo.Hello World!"

    6. callf.exe "${COMSPEC}" "/c (echo.Special case characters: ^|^&""|& ^ |&""^|^& ^^ ^|^&""|& ^ |&""^|^&)&pause"
    7. callf.exe "${COMSPEC}" "/c (echo.Special case characters: ^|^&\"^|^& ^^ ^|^&\"^|^& ^^ ^|^&\"^|^& ^^ ^|^&\"^|^&)&pause"

    First 5 examples should print:
            Hello Wold!

    Last 2 examples should print and pause after:
            Special case characters: |&"|& ^ |&"|& ^ |&"|& ^ |&"|&
