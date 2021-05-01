[+ AutoGen5 template txt=%s.txt +]
clearcache.exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Clears a drive I/O cache.

Usage: clearcache.exe [/?] <DriveRoot1> [<DriveRoot2> ... [<DriveRootN>]]
  Description:
    /?:
      This help.

    <DriveRoot> - the root of a drive.

  Return codes:
   -255 - unspecified error
   -128 - help output
   -2   - invalid format.
    0   - succeded
   >0   - Win32 errors

  Examples:
    clearcache.exe C: D:\ E:
