[+ AutoGen5 template txt=%s.txt +]
Thrust library auto configuration utility, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Console utility for auto generate files from configuration/text files.

Usage: [+ AppName +].exe [/?] <Mode> [<Flags>] <ConfigFile> <OutputFile>
  Description:
    /?:
      This help.

    <Mode>: -<cfg2c | txt2c>
      cfg2c - Generate header file from configuration file to c/c++
              translation unit.
      txt2c - Generate text file to quoted and commented c-file.

    -<Flags>: -<p | a | u>:
      Uses ONLY in "txt2c" mode.
      p - (Default) Comment only '"' and '\' characters.
      a - As previous, but additionally comments '%' by '%'
          (for use in printf-like function).
      u - adds 'L' prefix into each text line.

    <ConfigFile>:
      Path to the configuration file, which would reads.

    <OutputFile>:
      Path to the output file, which would be processed from the <ConfigFile>.

  Return codes:
   -255 - unspecified error
   -128 - help output
   -3   - invalid parameters
    0   - succeded
    1   - <ConfigFile> or <OutputFile> is empty
    2   - can't open config file
    3   - can't open output file

  Examples:
    1. thlibautocfg.exe -cfg2c MyProject.cfg MyProject.hpp
    2. thlibautocfg.exe -txt2c -a -u MyText.txt MyText.hpp
