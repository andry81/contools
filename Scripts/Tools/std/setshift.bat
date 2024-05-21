@echo off

rem USAGE:
rem   setshift.bat [-exe] [-no_trim] [-skip <skip-num>] <shift> <var> [<cmdline>...]

rem Description:
rem   Script sets variable from second argument to a command line formed from
rem   arguments beginning from %3 plus index from %1.
rem   Script can skip first N arguments after %2 before shift the rest.

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

rem <var>:
rem   Variable to set with skipped and shifted arguments from <cmdline>.

rem Examples:
rem   1. >setshift.bat 0 x "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      >set x
rem      x="1 2" ! ? * & | "=" 3
rem   2. >setshift.bat -exe 0 x "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      >set x
rem      x="1 2" ! ? * & | , ; = = "=" 3
rem   3. >setshift.bat 2 x "1 2" 3 4 5
rem      >set x
rem      x=4 5
rem   4. >errlvl.bat 123
rem      >setshift.bat
rem      >setshift.bat 0 x
rem      >setshift.bat 0 x 1 2 3
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=123
rem      >set x
rem      x=1 2 3
rem   5. >setshift.bat -3 x 1 2 3 4 5 6 7
rem      >set x
rem      x=1 2 3 7
rem      rem in a script
rem      >call setshift.bat -3 x %%3 %%2 %%1 %%*
rem   6. >setshift.bat -skip 2 -3 x a b 1 2 3 4 5 6 7
rem      >set x
rem      x=a b 1 2 3 7
rem      rem in a script
rem      >call setshift.bat -skip 2 -3 x param0 param1 %%3 %%2 %%1 %%*
rem   7. >setshift.bat -no_trim 1 x  a  b  c  d
rem      >set x
rem      x= b  c  d
rem   8. >set "$5E$3E=^>"
rem      >setshift.bat 0 x %$5E$3E%cmd param0 param1
rem      >set x
rem      x=>cmd param0 param1

rem Pros:
rem
rem   * Can handle almost all control characters.
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
  set "CMDLINE_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\setshift.%RANDOM%-%RANDOM%.txt"
) else set "CMDLINE_TEMP_FILE=%TEMP%\setshift.%RANDOM%-%RANDOM%.txt"

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
set "VAR="
set "CMDLINE="

rem cast to integer
set /A FLAG_SKIP+=0
set /A SHIFT+=0

set /A VAR_INDEX=FLAG_SHIFT+1
set /A ARG0_INDEX=FLAG_SHIFT+2

set /A SKIP=FLAG_SHIFT+2+FLAG_SKIP

if %SHIFT% GEQ 0 (
  set /A SHIFT+=SKIP
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
  ) else if !INDEX! EQU !VAR_INDEX! (
    endlocal & set "VAR=%%j"
  ) else endlocal
  set /A INDEX+=1
)

if not defined VAR endlocal & exit /b %LAST_ERROR%
setlocal ENABLEDELAYEDEXPANSION & set "__STRING__=!CMDLINE!" & if %FLAG_NO_TRIM% NEQ 0 set "__STRING__=!__STRING__:$20= !"
if not defined __STRING__ for /F "eol= tokens=* delims=" %%i in ("!VAR!") do endlocal & endlocal & set "%%i=" & exit /b %LAST_ERROR%

for /F "eol= tokens=* delims=" %%i in ("!VAR!") do (
  setlocal DISABLEDELAYEDEXPANSION & if %FLAG_EXE% EQU 0 (
    call "%%?~dp0%%encode\decode_sys_chars_bat_cmdline.bat"
  ) else call "%%?~dp0%%encode\decode_sys_chars_exe_cmdline.bat"
  setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!__STRING__!") do endlocal & endlocal & endlocal & endlocal & set "%%i=%%v" & exit /b %LAST_ERROR%
)
