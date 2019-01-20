* README_EN.txt
* 2019.01.20
* ConsoleTools

CAUTION:
  THIS README IS OBSOLETE AND LEFT FOR THE HISTORY.

  RELEASE MODEL HAS BEEN CHANGED AND NO LONGER EXIST, THERE IS NO RELEASE
  VERSION ANYMORE AND ARCHIVE FILES FOR THE DOWNLOAD. INSTEAD USE SVN MENU TO
  DOWNLOAD LATEST SOURCES/EXECUTABLES AND SEARCH FOR THE changelog.txt FILE
  FROM THE ROOT FOR A CHANGELOG PER DIRECTORY CONTEXT.

  A new version of console utilities is always UNDER DEVELOPMENT,
  see the DESCRIPTION section.

1. DESCRIPTION
2. LICENSE
3. REPOSITORIES
4. INSTALLATION
5. FILES
5.1. Backend registration scripts
5.2. Windows Batch scripts
5.3. Windows Scripting Host scripts
5.4. Perl scripts
5.5. Bash shell scripts
5.6. Windows executable utilities
6. KNOWN ISSUES
6.1. Error message `reg_cygwin.bat: error: (1) Failed to run cygcheck utility to detect cygwin dll version.'
7. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Scripts for WindowsNT interpreter cmd.exe and other interpreters to support
various operations and procedures with environment variables, text files and
piping.

The latest version is here: https://sf.net/p/contools

WARNING:
  Use the SVN access to find out new functionality and bug fixes.
  See the REPOSITORIES section.

-------------------------------------------------------------------------------
2. LICENSE
-------------------------------------------------------------------------------
The MIT license (see included text file "license.txt" or
https://en.wikipedia.org/wiki/MIT_License)

-------------------------------------------------------------------------------
3. REPOSITORIES
-------------------------------------------------------------------------------
Primary:
  * https://svn.code.sf.net/p/contools/contools/trunk
First mirror:
  * https://github.com/andry81/contools.git
Second mirror:
  * https://bitbucket.org/andry81/contools.git

-------------------------------------------------------------------------------
4. INSTALLATION
-------------------------------------------------------------------------------
run configure.bat

Windows executable utilities can be built if necessary under Microsoft Visual
Studio C++ 2015 Community Edition. The utilities does not require an installed
Microsoft Visual C++ 2015 Redistributables at runtime.

To build GUI utilities is required the wxWidgets library at least of version
3.1.x.

You have to download and copy the library sources manually into the
`/_3dparty/gui/wxWidgets` subdirectory.

-------------------------------------------------------------------------------
5. FILES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
5.1. Backend registration scripts
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
     reg_cygwin.bat
-------------------------------------------------------------------------------
Script checks and prepare Cygwin environment to run cmd interpreter in it.
Cygwin parameters reads from "cygwin.vars".

-------------------------------------------------------------------------------
     reg_msys.bat
-------------------------------------------------------------------------------
Script checks and prepare Msys environment to run cmd interpreter in it.
Msys parameters reads from "msys.vars".

-------------------------------------------------------------------------------
     reg_msysdvlpr.bat
-------------------------------------------------------------------------------
Script checks and prepare Msys environment to run cmd interpreter in it.
Msys parameters reads from "msysdvlpr.vars".

-------------------------------------------------------------------------------
     remount_cygwin_reg.bat
-------------------------------------------------------------------------------
Script remounts Cygwin paths in the registry by path read from "cygwin.vars".
To remount Cygwin by this script you should properly set variables
"CYGWIN_PATH" and "CYGWIN_REGKEY_PATH" before.

-------------------------------------------------------------------------------
     run_cygwin.bat
-------------------------------------------------------------------------------
Script checks and prepare Cygwin environment to run Cygwin login in it.
Cygwin parameters reads from "cygwin.vars".

-------------------------------------------------------------------------------
     run_cygwin_uac.bat
-------------------------------------------------------------------------------
Script runs run_cygwin.bat under UAC promotion.

-------------------------------------------------------------------------------
     run_msys.bat
-------------------------------------------------------------------------------
Script checks and prepare Msys environment to run Msys login in it.
Msys parameters reads from "msys.vars".

-------------------------------------------------------------------------------
     run_msys_uac.bat
-------------------------------------------------------------------------------
Script runs run_msys.bat under UAC promotion.

-------------------------------------------------------------------------------
     run_msysdvlpr.bat
-------------------------------------------------------------------------------
Script checks and prepare Msys environment to run Msys login in it.
Msys parameters reads from "msysdvlpr.vars".

-------------------------------------------------------------------------------
     run_msysdvlpr_uac.bat
-------------------------------------------------------------------------------
Script runs run_msysdvlpr.bat under UAC promotion.

-------------------------------------------------------------------------------
5.2. Windows Batch scripts
-------------------------------------------------------------------------------

!!!

BEWARE OF DIFFERENCES WHEN TYPE A BATCH FILE CODE IN A CONSOLE WINDOW AND
RUN AS AN ACTUAL BATCH FILE. THERE IS DIFFERENT VARIABLE EXPANSION PASS STAGES!

!!!

Example for the actual batch file example.bat:
1. @echo off
   set "AAA=C:\111\%%BBB%%"
   set "BBB=222\333"
   call set "DDD=%AAA%"
   echo "DDD=%DDD%"
   rem output is: "DDD=C:\111\222\333"

Example for direct input into a console window:
1. set "AAA=C:\111\%BBB%"
   set "BBB=222\333"
   call set "DDD=%AAA%"
   echo "DDD=%DDD%"
   rem output is: "DDD=C:\111\"

Differences between these 2 examples are in how the `set "AAA=C:\111\%BBB%'
would be expanded.

In actual batch script it will always be expanded. In a windows console it would
only be expanded IF THE `BBB' VARIABLE HAS BEEN SET BEFORE (NOT EMPTY),
OTHERWISE IT WILL BE LEFT AS IS.

SO YOU HAVE TO INPUT `set "BBB="` IN SECOND EXAMPLE FOR A CONSOLE WINDOW TO
AVOID EARLY EXPANSION OF THE `set "AAA=C:\111\%BBB%"':

1. set "BBB="
   set "AAA=C:\111\%BBB%"

!!!

BEWARE OF VARIABLES EXISTED BEFORE YOU INVOKE BATCH INSTRUCTIONS, OTHERWISE THE
RESULT WOULD BE DIFFERENT THAN YOU THINK OF.

!!!

To automatically drop created variables from the BATCH SCRIPT FILE you can use
these instructions:

setlocal
endlocal

!!!

BEWARE OF THE ENDLOCAL INSTRUCTION WHICH CALLS AUTOMATICALLY WHEN A SCRIPT
EXITS OR HAS CALLED SUBROUTINE ENDS.

BEWARE OF THE `SETLOCAL` INSTRUCTION WHICH WORKS ONLY IN A SCRIPT.

!!!

-------------------------------------------------------------------------------
     abspath.bat
-------------------------------------------------------------------------------
Script converts relative path to absolute canonical path.

Examples:
1. call abspath.bat "../Test"
   echo PATH_VALUE=%PATH_VALUE%

-------------------------------------------------------------------------------
     appendvar.bat
-------------------------------------------------------------------------------
Script appends value to variable values splitted by separator.

Examples:
1. call appendvar.bat PATH "C:\blabla\blabla" ";"
2. set "AAA=C:\blabla\blabla\"
   call appendvar.bat AAA "blabla\blabla" \

-------------------------------------------------------------------------------
     assert_msvc.bat
-------------------------------------------------------------------------------
Script checks if it is running under Visual Studio environment.

-------------------------------------------------------------------------------
     callargs.bat
-------------------------------------------------------------------------------
Script calls %* variable with restore error level which was just before a call.

Examples:
1. rem Below routine should be inside a script!
   call errlvl.bat 10
   set "AAA=BBB"
   set "BBB=C:\blabla\blabla"
   rem If we remove "callargs.bat" from below line, error level would be
   rem dropped in to 0 after command, because of "call" prefix before "set"
   rem command. So "callargs.bat" executes with call "prefix" before "set"
   rem command, but internally restores previous error level to avoid bad
   rem behaviour with "call" prefix before "set" command.
   rem This is valid ONLY inside a script, not manually entered in a console
   rem window!
   call callargs.bat set "CCC=%%%AAA%%%"
   echo "ERRORLEVEL=%ERRORLEVEL%"

-------------------------------------------------------------------------------
     countlines.bat
-------------------------------------------------------------------------------
Script reads standard output from command passed into arguments and counts not
empty lines into variable STDOUT_LINES.

Examples:
1. call countlines.bat dir c:\
   echo STDOUT_LINES=%STDOUT_LINES%

-------------------------------------------------------------------------------
     cstresc.bat
-------------------------------------------------------------------------------
Script reads and escapes string to a variable.
Script additionally reads length of escaping string and returns it.
Script replaces characters found in string with escape sequence -
"\<Char>". So, if you want to pass characters which should be
escaped and you want to escape character "\" itself, then you should pass
it with others too, otherwise it wouldn't be escaped.

Examples:
1. rem would be evaluated as: a="a\\b\\\.c"
   cstresc.bat "a\b\.c" a "\."
2. rem would be evaluated as: a="a\b\\.c"
   cstresc.bat "a\b\.c" a "."
3. rem would be evaluated as: a="a\\b\\.c"
   cstresc.bat "a\b\.c" a

-------------------------------------------------------------------------------
     cygver.bat
-------------------------------------------------------------------------------
Script reads version of cygwin package and sets variable CYGWIN_VER_STR to read
  value.
Parse version number in to 4 or 5 numbers:
  <MajorVersion>.<MinorVersion>.<PatchNumber>.<Revision1>[.<Revision2>]
Version conversion examples:
  - 1.7.5-1         ->  1.7.5.1
  - 2.1-1           ->  2.1.0.1
  - 1.4p6-10        ->  1.4.6.10
  - 00885-1         ->  885.0.0.1
  - 1.3.30c-10      ->  1.3.30c.10
  - 20050522-1      ->  20050522.0.0.1
  - 5.7_20091114-14 ->  5.7.20091114.14
  - 4.5.20.2-2      ->  4.5.20.2.2
  - 2009k-1         ->  2009k.0.0.1

Examples:
1. call cygver.bat cygwin "c:\cygwin"
   echo CYGWIN_VER_STR=%CYGWIN_VER_STR%
2. call cygver.bat cygwin-doc "c:\cygwin"
   echo CYGWIN_VER_STR=%CYGWIN_VER_STR%

-------------------------------------------------------------------------------
     dirpath.bat
-------------------------------------------------------------------------------
Script gets directory path from full path.
If success script setups variable FOUND_PATH and returns 0.
Otherwise returns non zero error level.

Examples:
1. call dirpath.bat C:\blabla\blabla -i
   echo FOUND_PATH=%FOUND_PATH%

-------------------------------------------------------------------------------
     dos2unix.bat
-------------------------------------------------------------------------------
Script converts all files in directory with script by wildcards
"*.*sh.;configure.*.;makefile.*." from the Dos text format to the Unix
text format using the dos2unix utility.

-------------------------------------------------------------------------------
     dospath.bat
-------------------------------------------------------------------------------
Script converts relative path to the DOS canonical path.

Examples:
1. call dospath.bat "../Test"
   echo PATH_VALUE=%PATH_VALUE%

-------------------------------------------------------------------------------
     errlvl.bat
-------------------------------------------------------------------------------
Script returns error level passed as first argument. If first argument is
empty, then returns previous error level.

Examples:
1. call errlvl.bat 10
   echo ERRORLEVEL=%ERRORLEVEL%

-------------------------------------------------------------------------------
     execwsh.bat
-------------------------------------------------------------------------------
Script calls to Windows Scripting Host (WSH) script.
Variable "__ARGS__" uses to pass arguments to the WSH interpreter.

Examples:
1. set __ARGS__="arg1" "arg2"
   call execwsh.bat myscript.js

-------------------------------------------------------------------------------
     expandvar.bat
-------------------------------------------------------------------------------
Script expands variable %2, store result in variable %1 and returns with
previous error level.

Examples:
1. call errlvl.bat 10
   set "AAA=BBB"
   set "BBB=C:\blabla\%%CCC%%"
   set "CCC=blabla\blabla"
   call expandvar.bat DDD "%%%AAA%%%"
   echo "DDD=%DDD%"

-------------------------------------------------------------------------------
     expandvarn.bat
-------------------------------------------------------------------------------
Script expands variable %2 with numeric expression, store result in
variable %1 and returns with previous error level.

-------------------------------------------------------------------------------
     expandvarx.bat
-------------------------------------------------------------------------------
Script expands variable %*, store result in variable EXPANDED_VALUE and
returns with previous error level.

-------------------------------------------------------------------------------
     expandvarxn.bat
-------------------------------------------------------------------------------
Script expands string %* with numeric expression, store result in
variable EXPANDED_VALUE and returns with previous error level.

-------------------------------------------------------------------------------
     fileattr.bat
-------------------------------------------------------------------------------
Script gets file attributes from relative or absolute path.
If success script sets variable FILE_ATTR and returns 0.
Otherwise returns non zero error level.

Examples:
1. call fileattr.bat "%WINDIR%\system32\cmd.exe"
   echo FILE_ATTR=%FILE_ATTR%

-------------------------------------------------------------------------------
     filenameext.bat
-------------------------------------------------------------------------------
Script gets file name and extension from full path.
If success script sets variable FOUND_PATH and returns 0.
Otherwise returns non zero error level.

Examples:
1. call filenameext.bat "C:\blabla\blabla.ext" -i
   echo FOUND_PATH=%FOUND_PATH%

-------------------------------------------------------------------------------
     filesize.bat
-------------------------------------------------------------------------------
Script reads file size by file path. If success script returns file size,
otherwise -1.

Examples:
1. call filesize.bat "C:\blabla\blabla.ext"

-------------------------------------------------------------------------------
     gccmrt.bat
-------------------------------------------------------------------------------
Scripts renames runtime library "libmsvcrt*.lib" files in the POSIX /lib
directory to the variant w/o suffix to make them default for the GCC compiler
linker.

-------------------------------------------------------------------------------
     iffexist.bat
-------------------------------------------------------------------------------
Script checks file existence in directory list.
If success script sets variable FOUND_PATH and returns 0.
Otherwise returns non zero error level.

Examples:
1. call iffexist.bat cmd.exe PATH -a
   echo FOUND_PATH=%FOUND_PATH%

-------------------------------------------------------------------------------
     isnativecmd.bat
-------------------------------------------------------------------------------
Script detects native Windows cmd.exe. Returns 0 if it is, and 1 - if not.

-------------------------------------------------------------------------------
     joinvars.bat
-------------------------------------------------------------------------------
Script creates or updates variable consisted from concatenated strings
splitted by ';' character. Strings are stored in file, which reads by
script.

Examples:
1. call joinvars.bat PATH "pathlist.txt"

-------------------------------------------------------------------------------
     msysver.bat
-------------------------------------------------------------------------------
Script reads version of msys dll and sets variable MSYS_VER_STR
  to read value.
Parse version number in to 4 or 5 numbers:
  <MajorVersion>.<MinorVersion>.<PatchNumber>.<Revision1>[.<Revision2>]
Version conversion examples:
  - 1.7.5-1         ->  1.7.5.1
  - 2.1-1           ->  2.1.0.1
  - 1.4p6-10        ->  1.4.6.10
  - 00885-1         ->  885.0.0.1
  - 1.3.30c-10      ->  1.3.30c.10
  - 20050522-1      ->  20050522.0.0.1
  - 5.7_20091114-14 ->  5.7.20091114.14
  - 4.5.20.2-2      ->  4.5.20.2.2
  - 2009k-1         ->  2009k.0.0.1

Examples:
1. call msysver.bat msys "c:\msys\1.0"
   echo MSYS_VER_STR=%MSYS_VER_STR%

-------------------------------------------------------------------------------
     printdospath.bat
-------------------------------------------------------------------------------
Script converts relative path to the DOS canonical path and prints it.

-------------------------------------------------------------------------------
     printfile.bat
-------------------------------------------------------------------------------
Script simply outputs text file line by line with expand option.

-------------------------------------------------------------------------------
     regenum.bat
-------------------------------------------------------------------------------
Script outputs subkeys of registry key by read and parse output of
reg.exe utility. Utility findstr.exe searches target string by regular
expression without case sensitivity. String partially escapes before been
passed to findstr.exe.
If key doesn't exist, then error level sets to 1, otherwise - 0.

Examples:
1. call regenum.bat "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft"
2. call regenum.bat "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\"

-------------------------------------------------------------------------------
     regquery.bat
-------------------------------------------------------------------------------
Script reads and parses standard output of "reg.exe query" to variable
REGQUERY_VALUE. Script setvarfromstd.bat ignores empty strings until not
empty string appear. Utility findstr.exe searches target string by
regular expression without case sensitivity.
If key not empty and doesn't exist, then error level sets to 1.
If value not empty and doesn't exist, then error level sets to 2.
If value empty, then script reads default value. If it is not defined,
then script returns 2, otherwise 0.
If key and value not empty and found, then error level sets to 0.

Examples:
1. call regquery.bat "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Command Processor" EnableExtensions
   echo REGQUERY_VALUE=%REGQUERY_VALUE%

-------------------------------------------------------------------------------
     resetenv.bat
-------------------------------------------------------------------------------
Script clears all environment variables which are not declared in a target
text file. Text file has a simple file format with a variable name on
each string line.

Examples:
1. call resetenv.bat "./env_vars.lst"

Example of variables text file:
  See the file "vars_winxp.lst" as an example of the default Window XP
  environment.

-------------------------------------------------------------------------------
     setvarfromstd.bat
-------------------------------------------------------------------------------
rem   Script reads standard output to variable STDOUT_VALUE.
rem   Command "for" ignores empty strings until not empty string appear.
rem   Additionally all spaces before non empty value does trim.
rem   If STDOUT_VALUE is empty, when error level sets to 1, otherwise - 0.
rem   If you try to call a script (*.bat), you can doesn't prefix name of
rem   script with "call" operator because script anyway runs under child
rem   cmd.exe process and it's return code ignores by "for" command.
rem
rem   Beware of triple expansion of all the script arguments -
rem   first expansion before any evaluation in batch scripts, second expansion
rem   because of "call" prefix to the script name and third expansion because
rem   of nature of command "for". So you should escape all potentially
rem   expandable characters BEFORE pass them into the script arguments!
rem   Exception is string quoting character - ", because of nature of the
rem   variable %* (it preserves % character as is).

rem Examples:
rem 1. call setvarfromstd.bat echo 10
rem    echo STDOUT_VALUE=%STDOUT_VALUE%

-------------------------------------------------------------------------------
     setvarsfromfile.bat
-------------------------------------------------------------------------------
Script reads text file with variables in format "VARIABLE=VALUE" and
applies it. You can use all expression types what uses by "set" command
in the command preprocessor cmd.exe (read help about command "set").

Example of variables text file:
  # Comment string
  _MYVALUE0=0
  _MYVALUE1=1
  "_MYVALUE2=1&2"
  /A _MYVALUE3=1+2
  /P _MYVALUE4=<"MyDirectory\Config&Init\MyVariableValue.var"
  _MYVALUE10=%_MYVALUE1%0
  _MYVALUE0=
  _MYVALUE12=1%?0%2
  "_MYVALUE13=1^2"
To avoid problems with special characters you should use quotes around
VARIABLE=VALUE expression. In any other case use %?*% placement variables.

Examples:
1. call setvarsfromfile.bat blabla.vars

-------------------------------------------------------------------------------
     splitvars.bat
-------------------------------------------------------------------------------
Script prints substrings concatenated together by split character.
String can exists as string literal or stores in file.
If stores in file, then additionally could be multilined.

Examples:
1. call splitvars.bat "%PATH%" ";" -s

-------------------------------------------------------------------------------
     start32.bat
-------------------------------------------------------------------------------
Script tryes to call x32 cmd interpreter under any process mode otherwise
it calls a cmd interpreter under the same process mode
(x32 under x32 or x64 under x64).

-------------------------------------------------------------------------------
     start64.bat
-------------------------------------------------------------------------------
Script tryes to call x64 cmd interpreter under x32 process mode if it is
in the Windows x64 environment otherwise it calls a cmd interpreter
under the same process mode (x32 under x32 or x64 under x64).

The "%SystemRoot%\Sysnative" directory doesn't exist on the Windows XP x64
and lower. It can be available only after Windows Vista x64,
Windows Server 2008 x64 or after Windows Server 2003 x64 with installed
"Microsoft hotfix 942589".

For those not server Windows systems or server Windows systems less than
Windows Server 2003 you have to install at least
"Windows Server 2003 Resource Kit Tools" to set the tool "linkd.exe"
available otherwise the script won't work properly.
In the depth the script tryes to map the "%SystemRoot%\Sysnative" path if
doesn't exist yet to the "%SystemRoot%\system32" directory and calls
cmd.exe through the mapped "%SystemRoot%\system32" directory, then that
involves call to the 64bit cmd.exe under the Windows x64 environment or
to the 32bit cmd.exe under the Windows x32 environment (for the datails
search for the article
"Jailed 32-Bit Processes on Windows x64" on the internet).

-------------------------------------------------------------------------------
     strchr.bat
-------------------------------------------------------------------------------
Script searches characters in string and returns offset of the first
found.
If the characters doesn't found in the string, then returns -1.
If string empty or doesn't exist, then returns -1.
If the characters argument is empty or doesn't exist, then returns
length of string only.

WARNING:
  Avoid usage of the "!" character if the delayed expansion is on,
  use then replacement for it (for example "?2" as described below) that
  initializes BEFORE the expansion is enabled!

OVERALL SCRIPT OPTIMIZATIONS:
1. Iteration over a for-loop is made by peaces to avoid the script slowdown,
   because the cmd interpreter runs a for-loop to the end even if a goto
   out of a for-loop scope is occured!
2. Double expansion is made over the delayed expansion, that is faster than
   over the "call" command prefix.

Examples:
1. call strchr.bat "" "Hello world!" W /i
   echo ERRORLEVEL=%ERRORLEVEL%

-------------------------------------------------------------------------------
     stresc.bat
-------------------------------------------------------------------------------
Script reads and escapes string to a variable.
Script additionally reads length of escaping string and returns it.
Script replaces characters found in string with escape sequence -
"^<Char>". Script searches and escapes all control characters including
the "^" character and the "%" character.

OVERALL SCRIPT OPTIMIZATIONS:
1. Iteration over a for-loop is made by peaces to avoid the script slowdown,
   because the cmd interpreter runs a for-loop to the end even if a goto
   out of a for-loop scope is occured!
2. Double expansion is made over the delayed expansion, that is faster than
   over the "call" command prefix.

Examples:
1. rem would be evaluated as: a="a^&^|\c"
   stresc.bat "" "a&|\c" a
2. rem would be evaluated as: a="a^^^^^>^>"
   stresc.bat "" a^^>>" a
3. rem would be evaluated as: a="%a%\!b!"
   stresc.bat "" "%a%\!b!" a

-------------------------------------------------------------------------------
     strlen.bat
-------------------------------------------------------------------------------
Script reads length of the first argument and returns it.
If argument is empty, then returns 0.

OVERALL SCRIPT OPTIMIZATIONS:
1. Iteration over a for-loop is made by peaces to avoid the script slowdown,
   because the cmd interpreter runs a for-loop to the end even if a goto
   out of a for-loop scope is occured!
2. Double expansion is made over the delayed expansion, that is faster than
   over the "call" command prefix.

Examples:
1. call strlen.bat "" "Hello world!"
   echo ERRORLEVEL=%ERRORLEVEL%

-------------------------------------------------------------------------------
     strrep.bat
-------------------------------------------------------------------------------
Script reads and replaces characters in the string to a variable.
Script additionally reads length of the string and returns it.
Script searches characters in the string defined by even offsets
in another string with characters for replacement and replaces
them by characters with odd offsets from the same string

Examples:
1. rem would be evaluated as: a="a\b\,c"
   strrep.bat "" "a/b/.c" "/\.," a
2. rem would be evaluated as: a="b\a\.c"
   strrep.bat "" "a\b\.c" "abba" a

-------------------------------------------------------------------------------
     strstr.bat
-------------------------------------------------------------------------------
Script searches substring in string and returns it's offset.
If substring didn't found in the string, then returns -1.
If string is empty or doesn't exist, then returns -1.
If substring argument is empty or doesn't exist, then returns -1.

Examples:
1. call strstr.bat "Hello world!" "World" /i
   echo ERRORLEVEL=%ERRORLEVEL%

-------------------------------------------------------------------------------
     unix2dos.bat
-------------------------------------------------------------------------------
Script converts all files in directory with script by wildcards
"*.*sh.;configure.*.;makefile.*." from the Unix text format to the Dos
text format using the unix2dos utility.

-------------------------------------------------------------------------------
     unset.bat
-------------------------------------------------------------------------------
Script safely drops variable value without change the error level.

-------------------------------------------------------------------------------
     wctoansi.bat
-------------------------------------------------------------------------------
Converts unicode 16-byte string written in hex form to ANSI string by
simply removing code page character and copies it to %1 variable.

Examples:
1. call wctoansi.bat TEST 3200330034003500
   echo TEST=%TEST%

-------------------------------------------------------------------------------
     which.bat
-------------------------------------------------------------------------------
Script finds a file in the PATH variable.

-------------------------------------------------------------------------------
     winver.bat
-------------------------------------------------------------------------------
Script sets WINVER_VALUE to string in format:
<Name>|<PlatformType>|<Version>
Examples:
  Windows 2000 32bit for x86            -> Windows2000|x86|5.00.2195
  Windows XP 32bit for x86              -> WindowsXP|x86|5.1.2600
  Windows XP 64bit for x86              -> WindowsXP|x64|5.2.3790
  Windows XP 64bit for Itanium          -> WindowsXP|i64|5.2.XXXX
  Windows Vista 32bit for x86           -> WindowsVista|x86|6.0.6001
  Windows Vista 64bit for x86           -> WindowsVista|x64|6.0.6001
  Windows 7 32bit for x86               -> Windows7|x86|6.1.7600
  Windows 7 64bit for x86               -> Windows7|x64|6.1.7600
  Windows 8 64bit for x86               -> Windows8|x64|6.2.9200
  Windows Server 2008 R2 64bit for x86  -> WindowsSrv2008R2|x64|6.1.7600

-------------------------------------------------------------------------------
     make_shortcut.bat
-------------------------------------------------------------------------------
Script to create the Windows shortcut file in the current directory for any
command line.

-------------------------------------------------------------------------------
     make_shortcut_cmd.bat
-------------------------------------------------------------------------------
Script to create the Windows shortcut file to the "COMSPEC /C <cmdline>"
in the current directory.

-------------------------------------------------------------------------------
     make_shortcut_cmd_xp.bat
-------------------------------------------------------------------------------
Script to create the Windows shortcut file to the "COMSPEC /C <cmdline>" in
the "%SYSTEMROOT%" directory (specific run under Windows XP only).
Creating a shortcut in the "%SYSTEMROOT%" directory under Windows XP avoids
parasite path prefixes in the output shortcut file.

-------------------------------------------------------------------------------
5.3. Windows Scripting Host scripts
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
     sarf.js
-------------------------------------------------------------------------------
SaRF => Search and Replace in Files.

Script searches in text file by regular expressions and replaces found signatures
by predefined text with regular expression variables (\1, \2, etc).
 Command arguments:
 [1] - Path to ANSI text file in which text would be searched and replaced.
 [2] - Path to ANSI text file, each line of which stores a regexp for string
       which would be searched and replaced in text file [1].
 [3] - Path to ANSI text file, each line of which stores strings for
       replacement in text file [1].

Examples:
1. sarf.js test.txt search.txt replace.txt

-------------------------------------------------------------------------------
     make_shortcut.vbs
-------------------------------------------------------------------------------
Creates the Windows shortcut file with assigned command line and working
directory.

-------------------------------------------------------------------------------
     update_shortcut.vbs
-------------------------------------------------------------------------------
Assign new command line to the existing Windows shortcut file.

-------------------------------------------------------------------------------
5.4. Perl scripts
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
     pipetimes.pl
-------------------------------------------------------------------------------
CAUTION:
  This implementation is obsolete, use pipetimes.exe instead as more
  precise.

Script indexes standard input stream by line print time, offset from begin
of stream and size of line.

Examples:
1. #!/bin/sh
   function foo()
   {
     echo 1
     sleep 1
     echo 12
     echo 12 >&2
     echo 123
     echo 123 >&2
     echo 1234
     echo 1234 >&2
     sleep 1
     echo 12345
     echo 123456
     echo 12345 >&2
     echo 123456 >&2
   }

   # 2-phase redirection
   {
   {
     foo
   } 2>&1 >&6 | perl ./pipetimes.pl -a "$ErrIndexFilePath" | tee -a "$ErrFilePath" >&2
   } 6>&1 | perl ./pipetimes.pl -a "$OutIndexFilePath" | tee -a "$OutFilePath"

   # 3-phase redirection
   {
   {
   {
     foo
   } 2>&1 >&6 | perl ./pipetimes.pl -a "$ErrIndexFilePath" | tee -a "$ErrFilePath" >&7 2>/dev/null
   } 6>&1 | perl ./pipetimes.pl -a "$OutIndexFilePath" | tee -a "$OutFilePath"
   } 7>&2

-------------------------------------------------------------------------------
     sar.pl
-------------------------------------------------------------------------------
SaR => Search and Replace.

Perl version required: 5.6.0 or higher (for "@-"/"@+" regexp variables).

Format: sar.pl [<Options>] <SearchPattern> [<ReplacePattern>] [<Flags>]
        [<RoutineProlog>] [<RoutineEpilog>]
Script searches in standard input text signatures, matches/replaces them by
predefined text with regexp variables (\0, \1, ..., \254, \255) and prints
result dependent on options.

-------------------------------------------------------------------------------
5.5. Bash shell scripts
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
     bash_entry
-------------------------------------------------------------------------------
Script to find bash shell version and call bash shell interpreter from the
"/usr/local/bin" directory if has any, otherwise call from the "/bin"
directory bypassing any user mount point redirection that may exist on the
way.

-------------------------------------------------------------------------------
     baselib.sh
-------------------------------------------------------------------------------
Script library to support basic shell operations. 

-------------------------------------------------------------------------------
     cygsetupdiff.sh
-------------------------------------------------------------------------------
Script reads the first cygwin setup.ini file and extracts all requested
packages including it's dependencies. Then reads the second cygwin setup.ini
file and findout which found depencies is not found in that file. Then after
that it prints all packages not found in the second file but found in the
first.

-------------------------------------------------------------------------------
cygsetuplib.sh
-------------------------------------------------------------------------------
Script library to support operations with the cygwin setup.ini file.

-------------------------------------------------------------------------------
cygsetupprint.sh
-------------------------------------------------------------------------------
Script prints fields of found packages.

-------------------------------------------------------------------------------
     cygver.sh
-------------------------------------------------------------------------------
Bash script which reads version of cygwin package and prints it.
Parse version number in to 4 or 5 numbers:
  <MajorVersion>.<MinorVersion>.<PatchNumber>.<Revision1>[.<Revision2>]
Version conversion examples:
  - 1.7.5-1         ->  1.7.5.1
  - 2.1-1           ->  2.1.0.1
  - 1.4p6-10        ->  1.4.6.10
  - 00885-1         ->  885.0.0.1
  - 1.3.30c-10      ->  1.3.30c.10
  - 20050522-1      ->  20050522.0.0.1
  - 5.7_20091114-14 ->  5.7.20091114.14
  - 4.5.20.2-2      ->  4.5.20.2.2
  - 2009k-1         ->  2009k.0.0.1

Examples:
1. cygver.sh cygwin
2. source "cygver.sh"
   CygwinVer cygwin 

-------------------------------------------------------------------------------
     execbat.sh
-------------------------------------------------------------------------------
Bash script for invoking Windows batch scripts. Cygwin/Mingw/Msys system
required.

Examples:
1. execbat.sh "echo 10"
2. source "execbat.sh"
   ExecWindowsBatch "echo 10"

-------------------------------------------------------------------------------
     execfunc.sh
-------------------------------------------------------------------------------
Bash script which executes function by name of bash script and name of
function in that script. Cygwin/Mingw/Msys system required.

Examples:
1. execfunc.sh "$CONTOOLS_ROOT/execbat.sh" "ExecWindowsBatch" "echo 10"
2. source "$CONTOOLS_ROOT/execfunc.sh"
   ExecBashFunction "$CONTOOLS_ROOT/execbat.sh" "ExecWindowsBatch" "echo 10"

-------------------------------------------------------------------------------
     filelib.sh
-------------------------------------------------------------------------------
Bash file library, supports common file functions.

-------------------------------------------------------------------------------
     funclib.sh
-------------------------------------------------------------------------------
Script library to support function object.

-------------------------------------------------------------------------------
     gccmrt.sh
-------------------------------------------------------------------------------
Bash script which copies in Cygwin/Mingw/Msys system "libmsvcr??[d].a" files
to "libmsvcr[d].a" files which uses as runtime libraries by default by GCC
linker. Cygwin/Mingw/Msys system required.

-------------------------------------------------------------------------------
     hashlib.sh
-------------------------------------------------------------------------------
Script library of hash functions.

-------------------------------------------------------------------------------
     mountdir.sh
-------------------------------------------------------------------------------
Bash script which mounts directory in the Cygwin/Msys system.
Cygwin/Msys system required.

Examples:
1. mountdir.sh 'C:\Mingw' /mingw
2. source "mountdir.sh"
   MountDir 'C:\Mingw' /mingw

-------------------------------------------------------------------------------
     patchlib.sh
-------------------------------------------------------------------------------
Patch library, implements main functions to automate source patching.

-------------------------------------------------------------------------------
     perllib.sh
-------------------------------------------------------------------------------
Set of bash functions to work with perl. Cygwin/Msys/Mingw system required.

-------------------------------------------------------------------------------
     print_merged_logs.sh
-------------------------------------------------------------------------------
Bash script to prints merged logs generated by pipetimes.exe utility.

Usage:
  "print_merged_logs.sh <stdout.log> <stderr.log> <stdout_index.log>
         <stderr_index.log>", where:
  <stdout.log> and <stderr.log> - standard output/error log files.
  <stdout_index.log> and <stderr_index.log> - standard output/error log
    files indexes.

-------------------------------------------------------------------------------
     stringlib.sh
-------------------------------------------------------------------------------
Bash string library, supports common string functions.

-------------------------------------------------------------------------------
     synclib.sh
-------------------------------------------------------------------------------
Script library to support synchronization operations.

-------------------------------------------------------------------------------
     tee2.sh
-------------------------------------------------------------------------------
Bash script for redirecting stdin to both stdout and stderr or one of
the auxiliary streams (if first parameter has been set) at a time.
Cygwin/Mingw/Msys system required.

Examples:
1. echo 10 | tee2.sh
2. echo 10 | tee2.sh -6 6>&2
3. source "tee2.sh"
   echo 10 | SplitPipeToStream
   echo 20 | SplitPipeToStream -6 6>&2
   echo 30 | SplitPipeToStream -6 s 6>&2

-------------------------------------------------------------------------------
     testlib.sh
-------------------------------------------------------------------------------
Script library to support testing

-------------------------------------------------------------------------------
     traplib.sh
-------------------------------------------------------------------------------
Script library to support trap shell operations.

-------------------------------------------------------------------------------
     unmountdir.sh
-------------------------------------------------------------------------------
Bash script which unmounts directory in the Cygwin/Msys system.
Cygwin/Msys system required.

Examples:
1. unmountdir.sh /mingw
2. source "unmountdir.sh"
   UnmountDir /mingw

-------------------------------------------------------------------------------
5.6. Windows executable utilities
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
     cecho.exe, cecho_x64.exe
-------------------------------------------------------------------------------
3d party utility to colorize output in the *.bat scripts. See the
"http://www.codeproject.com/Articles/17033/Add-Colors-to-Batch-Files" for the
details.

-------------------------------------------------------------------------------
     thlibautocfg.exe
-------------------------------------------------------------------------------
Thrust library auto configuration utility. Reads input file and output
processed input file (see ThlibAutoCfg_help.txt inside source directory for
detailes).

-------------------------------------------------------------------------------
     pipetimes.exe
-------------------------------------------------------------------------------
CAUTION:
  This implementation still can not be precise for several reasons.
  For example, this has 2-phase redirection:
  1. {
     {
       foo
     } 2>&1 >&6 | pipetimes.exe -a "$ErrIndexFilePath" | tee -a "$ErrFilePath" >&2
     } 6>&1 | pipetimes.exe -a "$OutIndexFilePath" | tee -a "$OutFilePath"
  To handle different phases of redirection corretly:
  1. The utility must get all the streams at the same time which not gonna
     happen because of lags inside the shell output.
  2. Two processes of pipetimes.exe must process both streams together w/o
     schedule lags which not gonna happen too, because of not real time OS.
  As a result the $ErrIndexFilePath and $OutIndexFilePath will contain the
  time lag values.

Standard input intermediate indexing utility. Indexes standard input stream by
steam input time, offset from begin of input stream and size of input stream
portion. Have the same sematic as pipetimes.pl script, but more precisable (see
pipetimes_help.txt inside source directory for detailes).

Examples:
1. #!/bin/sh
   function foo()
   {
     echo 1
     sleep 1
     echo 12
     echo 12 >&2
     echo 123
     echo 123 >&2
     echo 1234
     echo 1234 >&2
     sleep 1
     echo 12345
     echo 123456
     echo 12345 >&2
     echo 123456 >&2
   }

   # 2-phase redirection
   {
   {
     foo
   } 2>&1 >&6 | pipetimes.exe -a "$ErrIndexFilePath" | tee -a "$ErrFilePath" >&2
   } 6>&1 | pipetimes.exe -a "$OutIndexFilePath" | tee -a "$OutFilePath"

   # 3-phase redirection
   {
   {
   {
     foo
   } 2>&1 >&6 | pipetimes.exe -a "$ErrIndexFilePath" | tee -a "$ErrFilePath" >&7 2>/dev/null
   } 6>&1 | pipetimes.exe -a "$OutIndexFilePath" | tee -a "$OutFilePath"
   } 7>&2

-------------------------------------------------------------------------------
6. KNOWN ISSUES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
6.1. Error message `reg_cygwin.bat: error: (1) Failed to run cygcheck utility to detect cygwin dll version.'
-------------------------------------------------------------------------------
Solution:
 1. Reintall cygwin referenced by the path from CYGWIN_PATH variable in the
    Scripts/Config/cygwin.vars configuration file or
 2. Fix path to the cygwin installation directory in the registry:
    (x64) HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Cygnus Solutions\Cygwin\mounts v2\/
    (x86) HKEY_LOCAL_MACHINE\SOFTWARE\Cygnus Solutions\Cygwin\mounts v2\/

-------------------------------------------------------------------------------
7. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
