[+ AutoGen5 template txt=%s.txt +]
printf.exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Print in style of c-function printf, replacing specific backslashed
  character pairs in string arguments with characters.

Usage: printf.exe [/?] [<Flags>] <FormatString> [<Arg1> [<Arg2> ... [<ArgN>]]]
  Description:
    /?:
      This help.

    Flags:
      /chcp <codepage>
        Console output code page.

      /no-print-gen-error-string
        Don't print generic error string.

      /no-expand-env
        Don't expand `${...}` environment variables.

      /no-subst-vars
        Don't substitute `{...}` variables.

    <FormatString> placeholders:
      ${<VarName>} - <VarName> environment variable value.
      {0}    - first argument value.
      {N}    - N'th argument value.
      {0hs}  - first arguments hexidecimal string (00-FF per character).
      {Nhs}  - N'th arguments hexidecimal string (00-FF per character).
      \{     - '{' character escape

    Arguments placeholders:
      ${<VarName>} - <VarName> environment variable value.
      \{    - '{' character escape

  Return codes:
   -255 - unspecified error
   -128 - help output
   -2   - invalid format
   -1   - <FormatString> is empty.
    0   - succeded

  Examples:
    1. printf.exe "{0}={1}" "My profit" "10%"
