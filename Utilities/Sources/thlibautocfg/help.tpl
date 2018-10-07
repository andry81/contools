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

  Return codes (Basically positive values - errors, negative - warnings):
    0   - succeded
    1   - invalid format
    2   - help output
    3   - parameters doesn't defined or incorrect
    4   - can't open input file
    5   - can't open output file
    255 - unspecified error

  Examples:
    thlibautocfg.exe -cfg2c MyProject.cfg MyProject.hpp
    thlibautocfg.exe -txt2c -a -u MyText.txt MyText.hpp
