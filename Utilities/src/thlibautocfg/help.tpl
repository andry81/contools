[+ AutoGen5 template txt=%s.txt +]
Thrust library auto configuration utility, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Console utility for auto generate files from configuration/text files.

Usage: [+ AppName +].exe [/?] <Mode> [<Flags>] <InputFile> <OutputFile>
  Description:
    /?:
      This help.

    <Mode>: -<cfg2c | txt2c>
      cfg2c - Generate header file from configuration file to c/c++
              translation unit.
      txt2c - Generate text file to quoted and commented c-file.

    -<Flags>: -<p | a | u | h <file-path-template | m <output-file-line-template>>:
      Uses ONLY in "txt2c" mode.
      p - (Default) Comment only '"' and '\' characters.
      a - As previous, but additionally comments '%' by '%'
          (for use in printf-like function).
      u - adds 'L' prefix into each text line.
      h - split output into mutiple inclusion files.
          <file-path-template> - file path template to generate multiple
            inclusion files.
            Placeholders:
              `{N}` - counter beginning from 0.
            Example:
              `help/{N}.hpp`
          <OutputFile> - contains inclusion lines in format:
            `<output-file-line-template(N)>`
            , where by default it expands to:
              `#include "<file-path-template(N)>"`
            To override it you can use option `-m`.
      m - printf like format string to insert into each line of <OutputFile>
          per generated <file-path-template>.
          <output-file-line-template> - output file line template to insert
            lines.
            Placeholders:
              `{N}` - counter beginning from 0.
            Examples:
              `::puts(\n#include <help/{N}.hpp>\n);`
              `INCLUDE_HELP_INL_EPILOG({N})\n#include <help/{N}.hpp>\nINCLUDE_HELP_INL_PROLOG({N})`
          <OutputFile> - contains arbitrary lines in format:
            `<output-file-line-template(N)>`
              
    <InputFile>:
      Path to the input file to read.

    <OutputFile>:
      Path to the output file to write.

  Return codes:
    255 - unspecified error
    128 - help output
    16  - input/output error
    2   - invalid parameters
    1   - invalid format
    0   - succeded

  Examples:
    1. thlibautocfg.exe -cfg2c MyProject.cfg MyProject.hpp
    2. thlibautocfg.exe -txt2c -a -u MyText.txt MyText.hpp
    3. thlibautocfg.exe -txt2c -a -u -h help help.{N}.hpp help.tpl help_inl.hpp
