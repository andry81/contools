[+ AutoGen5 template txt=%s.txt +]
printf.exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Print in style of c-function printf, replacing specific backslashed
  character pairs in string arguments with characters.

Usage: printf.exe [/?] <FormatString> [<Arg1> [<Arg2> ... [<ArgN>]]]
  Description:
    - /?:
      This help.

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

  Return codes (Positive values - errors, negative - warnings):
   -1   - empty <FormatString>.
    0   - succeded
    1   - help output
    2   - invalid format.
    3   - <VarName*> string is not defined or it's value having too big size
          (>= 32767).
    255 - unspecified error

  Examples:
    printf.exe "{0}={1}" "My profit" "10%"
