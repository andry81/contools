[+ AutoGen5 template txt=%s.txt +]
Environment variables compare utility, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Console utility to compare environment variable values.
  The utility is useful when you want to compare environment variable values
  created by the cmd.exe batch script in that batch script, because the
  batch interpreter has string comparison issues and can not compare
  environment strings fully correct.

Usage: envvarcmp.exe [/? | <VarName1> <VarName2> [<PrintPrefix> [<EqualString> [<NotEqualString> [<LessString> [<GreaterOrEqualString>]]]]]]
  Description:
    /?:
      This help.

    <VarName1>:
      First environment variable name.

    <VarName2>:
      Second environment variable name.

    <PrintPrefix>:
      Always prints after compare if not empty.
      Can has common placeholders plus these:
      {EQL} - put <EqualString> when first variable is equal to second.
      {NEQ} - put <NotEqualString> when first variable is not equal to second.
      {LSS} - put <LessString> when first variable is less than second.
      {GEQ} - put <GreaterOrEqualString> when first variable is greater or
              equal than second.

    If <PrintPrefix> is empty, then below string prints instead of
    <PrintPrefix>:

    <EqualString>
      String associated with "equal" result. Can has common placeholders.

    <NotEqualString>
      String associated with "not equal" result. Can has common placeholders.

    <LessString>
      String associated with "less" result. Can has common placeholders.

    <GreaterOrEqualString>
      String associated with "greater or equal" result. Can has common
      placeholders.

    Common placeholders:
      ${<VarName>} - <VarName> environment variable value.
      {0}    - first environment variable's value.
      {1}    - second environment variable's value.
      {0hs}  - first environment variable's hexidecimal string
               (00-FF per character).
      {1hs}  - second environment variable's hexidecimal string
               (00-FF per character).
      \{     - '{' character escape

    Utility compares environment variable values and prints a string into
    output.
    If the <EqualString> is not empty and the <NotEqualString> is not empty,
    then the <LessString> and <GreaterOrEqualString> does not used.
    If the <EqualString> is not empty and the <NotEqualString> is empty, then
    the <GreaterOrEqualString> is used as "GreaterString".
    If the <EqualString> is empty and the <NotEqualString> is not empty, then
    the <GreaterOrEqualString> is used as "EqualString".
    If the <EqualString> is empty and the <NotEqualString> is empty, then
    the <LessString> and the <GreaterOrEqualString> is used instead.

  Return codes:
   -255   - unspecified error
   -128   - help output
   -2     - invalid format.
   -1     - not equal, first variable is less than second.
    0     - equal.
    1     - not equal, first variable is greater or equal than second.
    2     - <VarName1> string is not defined or it's value having too big size
            (>= 32767).
    3     - <VarName2> string is not defined or it's value having too big size
            (>= 32767).
   >3     - other errors
