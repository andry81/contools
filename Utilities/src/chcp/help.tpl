[+ AutoGen5 template txt=%s.txt +]
chcp.exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Changes or prints current console output code page.

Usage: chcp.exe [/?] [<Flags>] [//] [<InputOutputCodePage>]
  Description:
    /?:
    This help.

    //:
    Character sequence to stop parse <Flags> command line parameters.

    Flags:
      /in <InputCodePage>
        Sets input code page.

      /out <OutputCodePage>
        Sets output code page.

    <InputOutputCodePage>
      Sets both input and output code pages.

    If `/in` or `/out` flags and <InputOutputCodePage> are not defined, then
    prints both the Output and Input code pages:
      <OutputCodePage>:<InputCodePage>

  Return codes:
   -255 - unspecified error
   -128 - help output
   -127 - conversion error
   -3   - invalid params
    0   - succeded
