@echo off

rem Description:
rem   Script calls second argument and passes to it all arguments beginning
rem   from %3 plus index from %1. Script can skip first N arguments after %2
rem   before shift the rest.

rem USAGE:
rem   callshift.bat <shift> <command> [<cmdline>]

rem   <shift>
rem     Number of arguments in <cmdline> to skip and shift.
rem     If >=0, then only shifts <cmdline> after %2 argument.
rem     If < 0, then skips first <shift> arguments after %2 argument and
rem     shifts the rest <cmdline>.
rem
rem   <command>
rem     Command to call with skipped and shifted arguments from <cmdline>.

rem Examples:
rem   1. >callshift.bat 0 echo "1 2" ! ^^? ^^* ^& ^| , ; = 3
rem      "1 2" ! ? * & | , ; 3
rem   2. >callshift.bat 2 echo."1 2" 3 4 5
rem      "1 2" 5
rem   3. >callshift.bat . set | sort
rem   4. >errlvl.bat 123
rem      >callshift.bat
rem      >callshift.bat 0 echo.
rem      >callshift.bat 0 echo 1 2 3
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=123
rem   5. >call callshift.bat -3 echo 1 2 3 4 5 6 7
rem      1 2 3 7
rem      >call callshift.bat -3 command %%3 %%2 %%1 %%*

rem Pros:
rem
rem   * Can handle `!`, `?`, `*`, `&`, `|`, `,`, `;` characters.
rem   * Can call builtin commands.
rem   * Does restore previous ERRORLEVEL variable before call a command.
rem   * Does not leak variables outside.
rem   * Can skip first N used arguments from the `%*` variable.
rem
rem Cons:
rem
rem   * The control characters like `&` and `|` still must be escaped.
rem   * To handle `?` and `*` characters you must prefix them additionally to the escape: `^?`, `^*`.
rem   * Can not handle `=` character.
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

set "SHIFT=%~1"
set "COMMAND="
set "CMDLINE="

rem cast to integer
set /A SHIFT+=0

set SKIP=2

if %SHIFT% GEQ 0 (
  set /A SHIFT+=2
) else (
  set /A SKIP+=-SHIFT
  set /A SHIFT=-SHIFT*2+2
)

rem Escape specific separator characters by sequence of `$NN` characters:
rem  1. `?` and `*` - globbing characters in the `for %%i in (...)` expression
rem  2. `,`, `;`    - separator characters in the `for %%i in (...)` expression
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!LINE:$=$00!") do endlocal & set "LINE=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!LINE:^*=$01!") do endlocal & set "LINE=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!LINE:^?=$02!") do endlocal & set "LINE=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!LINE:,=$03!") do endlocal & set "LINE=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!LINE:;=$04!") do endlocal & set "LINE=%%i"

set INDEX=-1

for /F "eol= tokens=* delims=" %%i in ("%LINE%") do for %%j in (%%i) do (
  setlocal ENABLEDELAYEDEXPANSION
  if !INDEX! GEQ 2 (
    if !INDEX! LSS !SKIP! (
      if defined CMDLINE (
        for /F "eol= tokens=* delims=" %%v in ("!CMDLINE!") do endlocal & set "CMDLINE=%%v %%j"
      ) else endlocal & set "CMDLINE=%%j"
    ) else if !INDEX! GEQ !SHIFT! (
      if defined CMDLINE (
        for /F "eol= tokens=* delims=" %%v in ("!CMDLINE!") do endlocal & set "CMDLINE=%%v %%j"
      ) else endlocal & set "CMDLINE=%%j"
    )
  ) else if !INDEX! EQU 1 (
    endlocal & set "COMMAND=%%j"
  ) else endlocal
  set /A INDEX+=1
)

rem restore error level
call :SETERRORLEVEL %LAST_ERROR%
goto CALL

:SETERRORLEVEL
exit /b %*

:CALL
(
  setlocal ENABLEDELAYEDEXPANSION
  for /F "eol= tokens=* delims=" %%i in ("!COMMAND!") do (
    if defined CMDLINE (
      for /F "eol= tokens=* delims=" %%v in ("!CMDLINE:$04=;!") do endlocal & set "CMDLINE=%%v"
      setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!CMDLINE:$03=,!") do endlocal & set "CMDLINE=%%v"
      setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!CMDLINE:$02=?!") do endlocal & set "CMDLINE=%%v"
      setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!CMDLINE:$01=*!") do endlocal & set "CMDLINE=%%v"
      setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!CMDLINE:$00=$!") do endlocal & set "CMDLINE=%%v"
      setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!CMDLINE!") do endlocal & endlocal & call :SETERRORLEVEL %LAST_ERROR% & %%i %%v
    ) else endlocal & endlocal & call :SETERRORLEVEL %LAST_ERROR% & %%i
  )
  exit /b %LAST_ERROR%
)

:SETERRORLEVEL
exit /b %*
