[+ AutoGen5 template txt=%s.txt +]
retakeowner.exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Retakes ownership on a file or not recursively on a directory.

Usage: retakeowner.exe [/?] <File>|<Directory> <User>|<Group>
  Description:
    - /?:
      This help.

    <File>|<Directory> - Path to existing file or directory.
    <User>|<Group>     - Existing User or Group to take ownership.

  Return codes (Positive values - errors, negative - warnings):
   -3   - invalid parameters
   -2   - help output
   -1   - unspecified error
    0   - succeded
    >0  - Win32 errors

  Examples:
    retakeowner.exe "c:\myfile.exe" User
