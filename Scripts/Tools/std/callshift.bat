@echo off

rem USAGE:
rem   callshift.bat [-exe] [-no_trim] [-skip <skip-num>] <shift> <command> [<cmdline>...]

rem Description:
rem   Script calls second argument and passes to it all arguments beginning
rem   from %3 plus index from %1. Script can skip first N arguments after %2
rem   before shift the rest.

rem -exe
rem   Use exe command line encoder instead of the batch as by default.
rem   An executable command line does not use `,;=` characters as command line
rem   arguments separator.

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
rem   1. >callshift.bat 0 echo "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      "1 2" ! ? * & | "=" 3
rem   2. >callshift.bat -exe 0 echo "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      "1 2" ! ? * & | , ; = = "=" 3
rem   3. >callshift.bat 2 echo."1 2" 3 4 5
rem      "1 2" 5
rem   4. >callshift.bat . set | sort
rem   5. >errlvl.bat 123
rem      >callshift.bat
rem      >callshift.bat 0 echo.
rem      >callshift.bat 0 echo 1 2 3
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=123
rem   6. >callshift.bat -3 echo 1 2 3 4 5 6 7
rem      1 2 3 7
rem      rem in a script
rem      >call callshift.bat -3 command %%3 %%2 %%1 %%*
rem   7. >callshift.bat -skip 2 -3 echo a b 1 2 3 4 5 6 7
rem      a b 1 2 3 7
rem      rem in a script
rem      >call callshift.bat -skip 2 -3 command param0 param1 %%3 %%2 %%1 %%*
rem   8. >callshift.bat 0 exit /b 123
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=123
rem   9. >errlvl.bat 123
rem      >callshift.bat 0 call errlvl.bat 321
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=321
rem  10. >callshift.bat -no_trim 1 echo  a  b  c  d
rem       b  c  d

rem Pros:
rem
rem   * Can handle almost all control characters.
rem   * Can call builtin commands.
rem   * Does restore previous ERRORLEVEL variable before call a command.
rem   * Can skip first N used arguments from the `%*` variable including
rem     additional command line arguments.
rem   * Can avoid spaces trim in the shifted command line.
rem
rem Cons:
rem
rem   * The control characters like `&` and `|` still must be escaped before
rem     call in a user script (side issue).
rem   * Does write to a temporary file to save the command line as is.
rem   * The delayed expansion feature must be disabled before this script call:
rem     `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem     expanded.
rem   * A batch script command line and an executable command line has
rem     different encoders.

rem with save of previous error level
setlocal DISABLEDELAYEDEXPANSION & set LAST_ERROR=%ERRORLEVEL%

rem drop last error level
call;

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "CMDLINE_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\callshift.%RANDOM%-%RANDOM%.txt"
) else set "CMDLINE_TEMP_FILE=%TEMP%\callshift.%RANDOM%-%RANDOM%.txt"

rem redirect command line into temporary file to print it correcly
for %%i in (1) do (
  set "PROMPT=$_"
  echo on
  for %%b in (1) do rem %*
  @echo off
) > "%CMDLINE_TEMP_FILE%"

for /F "usebackq eol= tokens=* delims=" %%i in ("%CMDLINE_TEMP_FILE%") do set "__STRING__=%%i"

del /F /Q /A:-D "%CMDLINE_TEMP_FILE%" >nul 2>nul

setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__STRING__:~0,-1!") do endlocal & set "__STRING__=%%i"

set "?~dp0=%~dp0"

rem script flags
set FLAG_SHIFT=0
set FLAG_EXE=0
set FLAG_NO_TRIM=0
set FLAG_SKIP=0

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-exe" (
    set FLAG_EXE=1
    shift
    set /A FLAG_SHIFT+=1
  )
)

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

rem encode specific command line characters
if %FLAG_EXE% EQU 0 (
  call "%%?~dp0%%encode\encode_sys_chars_bat_cmdline.bat"
) else call "%%?~dp0%%encode\encode_sys_chars_exe_cmdline.bat"

if %FLAG_NO_TRIM% NEQ 0 setlocal ENABLEDELAYEDEXPANSION & ^
set "__STRING__=!__STRING__:  = $20!" & for /F "eol= tokens=* delims=" %%i in ("!__STRING__:$20 =$20$20!") do endlocal & set "__STRING__=%%i"

set INDEX=-1

setlocal ENABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("!__STRING__!") do endlocal & for %%j in (%%i) do (
  setlocal ENABLEDELAYEDEXPANSION & if !INDEX! GEQ !ARG0_INDEX! (
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

if not defined COMMAND endlocal & exit /b %LAST_ERROR%
setlocal ENABLEDELAYEDEXPANSION & if defined CMDLINE (
  set "__STRING__=!COMMAND! !CMDLINE!"
) else set "__STRING__=!COMMAND!"
if %FLAG_NO_TRIM% NEQ 0 set "__STRING__=!__STRING__:$20= !"

for /F "eol= tokens=* delims=" %%i in ("!__STRING__!") do (
  setlocal DISABLEDELAYEDEXPANSION & if %FLAG_EXE% EQU 0 (
    call "%%?~dp0%%encode\decode_sys_chars_bat_cmdline.bat"
  ) else call "%%?~dp0%%encode\decode_sys_chars_exe_cmdline.bat"
  setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!__STRING__!") do endlocal & endlocal & endlocal & endlocal & call :SETERRORLEVEL %LAST_ERROR% & (
    %%v
  ) & exit /b
)

:SETERRORLEVEL
exit /b %*
