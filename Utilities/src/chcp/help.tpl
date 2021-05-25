[+ AutoGen5 template txt=%s.txt +]
chcp.exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Changes or prints current console output code page.

Usage: chcp.exe [/?] [<CodePage>]
  Description:
    Flags:
      /?:
        This help.

  Return codes:
   -255 - unspecified error
   -128 - help output
   -127 - conversion error
    0   - succeded
