@echo off

rem USAGE:
rem   callshift.bat [-no_trim] [-skip <skip-num>] <shift> <command> [<cmdline>...]

rem Description:
rem   Script calls second argument and passes to it all arguments beginning
rem   from %3 plus index from %1. Script can skip first N arguments after %2
rem   before shift the rest.

rem -no_trim
rem   Avoids spaces trim in the shifted command line.

rem -skip <skip-num>
rem   Additional number of skip arguments after %2 argument.
rem   If not defined, then 0.

rem <shift>:
rem   Number of arguments in <cmdline> to skip and shift.
rem   If >=0, then only shifts <cmdline> after %2 argument plus <skip-num>.
rem   If < 0, then skips first <shift> arguments after %2 argument plus
rem   <skip-num> and shifts the rest <cmdline>.

rem <command>:
rem   Command to call with skipped and shifted arguments from <cmdline>.

rem Examples:
rem   1. >callshift.bat 0 echo "1 2" ! ^^? ^^* ^& ^| , ; = ^= "=" 3
rem      "1 2" ! ? * & | , ; "=" 3
rem   2. >callshift.bat 2 echo."1 2" 3 4 5
rem      "1 2" 5
rem   3. >callshift.bat . set | sort
rem   4. >errlvl.bat 123
rem      >callshift.bat
rem      >callshift.bat 0 echo.
rem      >callshift.bat 0 echo 1 2 3
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=123
rem   5. >callshift.bat -3 echo 1 2 3 4 5 6 7
rem      1 2 3 7
rem      rem in a script
rem      >call callshift.bat -3 command %%3 %%2 %%1 %%*
rem   6. >callshift.bat -skip 2 -3 echo a b 1 2 3 4 5 6 7
rem      a b 1 2 3 7
rem      rem in a script
rem      >call callshift.bat -skip 2 -3 command param0 param1 %%3 %%2 %%1 %%*
rem   7. >callshift.bat 0 exit /b 123
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=123
rem   8. >errlvl.bat 123
rem      >callshift.bat 0 call errlvl.bat 321
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=321
rem   9. >callshift.bat -no_trim 1 echo  a  b  c  d
rem       b  c  d

rem Pros:
rem
rem   * Can handle `!`, `?`, `*`, `&`, `|`, `,`, `;`, `=` characters.
rem   * Can call builtin commands.
rem   * Does restore previous ERRORLEVEL variable before call a command.
rem   * Does not leak variables outside.
rem   * Can skip first N used arguments from the `%*` variable including
rem     additional command line arguments.
rem   * Can avoid spaces trim in the shifted command line.
rem
rem Cons:
rem
rem   * The control characters like `&` and `|` still must be escaped.
rem   * To handle `?` and `*` characters you must prefix them additionally to escape: `^?`, `^*`.
rem   * Can not handle `=` character without quotes.
rem   * Does write to a temporary file to save the command line as is.

rem with save of previous error level
setlocal & set LAST_ERROR=%ERRORLEVEL%

rem drop last error level
call;

set "CMDLINE_TEMP_FILE=%TEMP%\callshift.%RANDOM%-%RANDOM%.txt"

rem redirect command line into temporary file to print it correcly
for %%i in (1) do (
  set "PROMPT=$_"
  echo on
  for %%b in (1) do rem %*
  @echo off
) > "%CMDLINE_TEMP_FILE%"

for /F "usebackq eol= tokens=* delims=" %%i in ("%CMDLINE_TEMP_FILE%") do set "LINE=%%i"

del /F /Q "%CMDLINE_TEMP_FILE%" >nul 2>nul

rem script flags
set FLAG_SHIFT=0
set FLAG_SKIP=0
set FLAG_NO_TRIM=0

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-no_trim" (
    set FLAG_NO_TRIM=1
    shift
    set /A FLAG_SHIFT+=1
  )
)

if defined FLAG (
  if "%FLAG%" == "-skip" (
    set "FLAG_SKIP=%~2"
    shift
    shift
    set /A FLAG_SHIFT+=2
  )
)

set "SHIFT=%~1"
set "COMMAND="
set "CMDLINE="

rem cast to integer
set /A FLAG_SKIP+=0
set /A SHIFT+=0

set /A COMMAND_INDEX=FLAG_SHIFT+1
set /A ARG0_INDEX=FLAG_SHIFT+2

set /A SKIP=FLAG_SHIFT+2+FLAG_SKIP

if %SHIFT% GEQ 0 (
  set /A SHIFT+=FLAG_SHIFT+2+FLAG_SKIP
) else (
  set /A SKIP+=-SHIFT
  set /A SHIFT=FLAG_SHIFT+2+FLAG_SKIP-SHIFT*2
)

rem Escape specific separator characters by sequence of `$NN` characters:
rem  1. `?` and `*` - globbing characters in the `for %%i in (...)` expression
rem  2. `,`, `;`, <space> - separator characters in the `for %%i in (...)` expression
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!LINE:$=$00!") do endlocal & set "LINE=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!LINE:^*=$01!") do endlocal & set "LINE=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!LINE:^?=$02!") do endlocal & set "LINE=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!LINE:,=$03!") do endlocal & set "LINE=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!LINE:;=$04!") do endlocal & set "LINE=%%i"
if %FLAG_NO_TRIM% NEQ 0 (
  setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!LINE:  = $05!") do endlocal & set "LINE=%%i"
  setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!LINE:$05 =$05$05!") do endlocal & set "LINE=%%i"
)

set INDEX=-1

setlocal ENABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("!LINE!") do endlocal & for %%j in (%%i) do (
  setlocal ENABLEDELAYEDEXPANSION
  if !INDEX! GEQ !ARG0_INDEX! (
    if !INDEX! LSS !SKIP! (
      if defined CMDLINE (
        for /F "eol= tokens=* delims=" %%v in ("!CMDLINE!") do endlocal & set "CMDLINE=%%v %%j"
      ) else endlocal & set "CMDLINE=%%j"
    ) else if !INDEX! GEQ !SHIFT! (
      if defined CMDLINE (
        for /F "eol= tokens=* delims=" %%v in ("!CMDLINE!") do endlocal & set "CMDLINE=%%v %%j"
      ) else endlocal & set "CMDLINE=%%j"
    ) else endlocal
  ) else if !INDEX! EQU !COMMAND_INDEX! (
    endlocal & set "COMMAND=%%j"
  ) else endlocal
  set /A INDEX+=1
)

if defined COMMAND (
  setlocal ENABLEDELAYEDEXPANSION
  for /F "eol= tokens=* delims=" %%i in ("!COMMAND!") do (
    if defined CMDLINE (
      for /F "eol= tokens=* delims=" %%v in ("!CMDLINE:$04=;!") do endlocal & set "CMDLINE=%%v"
      if %FLAG_NO_TRIM% NEQ 0 setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!CMDLINE:$05= !") do endlocal & set "CMDLINE=%%v"
      setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!CMDLINE:$03=,!") do endlocal & set "CMDLINE=%%v"
      setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!CMDLINE:$02=?!") do endlocal & set "CMDLINE=%%v"
      setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!CMDLINE:$01=*!") do endlocal & set "CMDLINE=%%v"
      setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!CMDLINE:$00=$!") do endlocal & set "CMDLINE=%%v"
      setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!CMDLINE!") do endlocal & endlocal & call :SETERRORLEVEL %LAST_ERROR% & %%i %%v
    ) else endlocal & endlocal & call :SETERRORLEVEL %LAST_ERROR% & %%i
    exit /b
  )
  exit /b %LAST_ERROR%
)

(
  endlocal
  exit /b %LAST_ERROR%
)

:SETERRORLEVEL
exit /b %*
