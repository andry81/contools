@echo off

rem Description:
rem   Script calls second argument and passes to it all arguments beginning from %3 plus index from %1

rem Command arguments:
rem %1 - shift index
rem %2 - command
rem %3-... - command line arguments

rem Examples:
rem   1. callshift.bat 0 echo "1 2" ! ^^? ^^* ^& ^| , ; = 3
rem   2. callshift.bat 2 echo."1 2" 3 4 5
rem   3. callshift.bat . set | sort
rem   4. errlvl.bat 123
rem      callshift.bat
rem      callshift.bat 0 echo.
rem      callshift.bat 0 echo 1 2 3
rem      echo ERRORLEVEL=%ERRORLEVEL%

rem Pros:
rem
rem   * Can handle `!`, `?`, `*`, `&`, `|`, `,`, `;` characters.
rem   * Can call builtin commands.
rem   * Does restore previous ERRORLEVEL variable before call a command.
rem   * Does not leak variables outside.
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

set /A SHIFT+=2

if %SHIFT% LSS 2 set SHIFT=2

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
  if !INDEX! GEQ !SHIFT! (
    if defined CMDLINE (
      for /F "eol= tokens=* delims=" %%v in ("!CMDLINE!") do endlocal & set "CMDLINE=%%v %%j"
    ) else endlocal & set "CMDLINE=%%j"
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
