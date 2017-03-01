[+ AutoGen5 template txt=%s.txt +]
clearcache.exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Clears a drive I/O cache.

Usage: clearcache.exe [/?] <DriveRoot1> [<DriveRoot2> ... [<DriveRootN>]]
  Description:
    - /?:
      This help.

    <DriveRoot> - the root of a drive:

  Return codes (Positive values - errors, negative - warnings):
   -2   - help output
   -1   - unspecified error
    0   - succeded
    >0  - drive operation Win32 error

  Examples:
    clearcache.exe C: D:\ E:
