[+ AutoGen5 template txt=%s.txt +]
Standard input indexing utility, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Console utility to index standard input stream by line print time,
  offset from begin of stream and size of line.

Usage: pipetimes.exe [/? | [-a] <IndexFile>] [<PipeFile>]
  Description:
    /?:
      This help.
    -a:
      Append instead of rewriting.
    <IndexFile>:
      Path to file which would store piping times and offsets.
    <PipeFile>
      Path to file which write time will be used to write into IndexFile
      for each read out from standard input.

    Utility reads standard input line by line and writes it without changes to
    the standard output. Each input line time, length and offset from begin of
    the standard input writes in to <FilePath> in the format:
        "<BeginLineTime> <EndLineTime> <LineOffset> <LineLength>
        [<PipeWriteTime>]\n".
    Each value writes in hexadecimal integral form and <*LineTime> can be
    greater than 32-bits value. The "*LineTime" resolution is 1ms, basically
    this is enough for piping, because delays between line output in scripts and
    console utilities is greater than 1ms.
    The PipeWriteTime is optional and available if PipeFile is defined and if
    defined has 64-bit value.

    This script useful when you reads both standard input and standard error
    pipes and wants later to merge them both into one stream, for example, of
    HTML form.

  Return codes:
   -255 - unspecified error
   -128 - help output
   -2   - invalid format
    0   - succeded
   >0   - errors
