@echo off & goto DOC_END

rem USAGE:
rem   setshift.bat [-exe] [-notrim] [-skip <skip-num>] <shift> <var> [<cmdline>...]

rem Description:
rem   Script sets `<var>` variable to skipped and shifted `<cmdline>`.

rem -exe
rem   Use exe command line encoder instead of the batch as by default.
rem   An executable command line does not use `,;=` characters as command line
rem   arguments separator.

rem -notrim
rem   Avoids spaces trim in the shifted command line.

rem -skip <skip-num>
rem   Number of `<cmdline>` arguments to skip before shift.
rem   If not defined, then 0.

rem <shift>:
rem   Number of `<cmdline>` arguments to skip and shift.
rem   If >=0, then shifts by `<shift>` beginning from `<skip-num>` argument.
rem   If < 0, then shifts by `|<shift>|` beginning from `<skip-num>+|<shift>|`
rem   argument.

rem <var>:
rem   Variable to set.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.
rem

rem Examples (in console):
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
rem   7. >setshift.bat -notrim 1 x  a  b  c  d
rem      >set x
rem      x= b  c  d
rem   8. >setshift.bat 0 x ^>cmd param0 param1
rem      >set x
rem      x=>cmd param0 param1

rem Examples (in script):
rem   1. set "$5E$3E=^>"
rem      call setshift.bat 0 x %%$5E$3E%%cmd param0 param1
rem      set x
rem   2. set "TAB=	"
rem      call setshift.bat -notrim 0 x cmd %%TAB%% %%TAB%% param0  %%TAB%%%%TAB%%  %%TAB%%%%TAB%%  param1 %%TAB%% %%TAB%%param2 %%TAB%%param3
rem      set x

rem Pros:
rem
rem   * Can handle almost all control characters.
rem   * Does restore previous ERRORLEVEL variable before call a command.
rem   * Can skip first N used arguments from the `%*` variable including
rem     additional command line arguments.
rem   * Can avoid spaces and tabulation characters trim in the shifted command
rem     line.
rem
rem Cons:
rem
rem   * The control characters like `&` and `|` still must be escaped before
rem     call in a user script (side issue).
rem   * Does write to a temporary file to save the command line as is and
rem     `cmd.exe /Q ...` can suppress `echo on` at all.
rem   * The delayed expansion feature must be disabled before this script call:
rem     `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem     expanded.
rem   * A batch script command line and an executable command line has
rem     different encoders.
rem   * In case of a tabulation character immediately after a command line
rem     argument, you must entail each argument at least with one space
rem     character, because all tabulation characters does encode which may end
rem     up with arguments concatenation and so wrong skip and/or shift.
:DOC_END

rem with save of previous error level
setlocal DISABLEDELAYEDEXPANSION & set LAST_ERROR=%ERRORLEVEL%

rem drop last error level
call;

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "CMDLINE_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\%~n0.%RANDOM%-%RANDOM%.txt"
) else set "CMDLINE_TEMP_FILE=%TEMP%\%~n0.%RANDOM%-%RANDOM%.txt"

rem redirect command line into temporary file to print it correctly
(
  setlocal DISABLEEXTENSIONS
  (set PROMPT=$_)
  echo on
  for %%z in (%%z) do rem * %*#
  @echo off
  endlocal
) > "%CMDLINE_TEMP_FILE%"

set "__STRING__=" & for /F "usebackq tokens=* delims="eol^= %%i in ("%CMDLINE_TEMP_FILE%") do set "__STRING__=%%i"

del /F /Q /A:-D "%CMDLINE_TEMP_FILE%" >nul 2>nul

rem WORKAROUND:
rem   In case if `echo` is turned off externally.
rem
if not defined __STRING__ exit /b %LAST_ERROR%

setlocal ENABLEDELAYEDEXPANSION & if not "!__STRING__:~6!" == "# " (
  for /F "tokens=* delims="eol^= %%i in ("!__STRING__:~6,-2!") do endlocal & set "__STRING__=%%i"
) else endlocal & set "__STRING__="

if not defined __STRING__ exit /b %LAST_ERROR%

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

if defined FLAG if "%FLAG%" == "-exe" (
  set FLAG_EXE=1
  shift
  call set "FLAG=%%~1"
  set /A FLAG_SHIFT+=1
)

if defined FLAG if "%FLAG%" == "-notrim" (
  set FLAG_NO_TRIM=1
  shift
  call set "FLAG=%%~1"
  set /A FLAG_SHIFT+=1
)

if defined FLAG if "%FLAG%" == "-skip" (
  set "FLAG_SKIP=%~2"
  shift
  shift
  call set "FLAG=%%~1"
  set /A FLAG_SHIFT+=2
)

set "SHIFT=%~1"
set "VAR="
set "CMDLINE="

rem test on invalid flag
if not defined SHIFT exit /b %LAST_ERROR%

set "SHIFT_=%SHIFT%"

rem cast to integer
set /A SHIFT+=0

if not "%SHIFT%" == "%SHIFT_%" exit /b %LAST_ERROR%

rem cast to integer
set /A FLAG_SKIP+=0

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

rem CAUTION:
rem   Encodes ALL tabulation characters.
rem
if %FLAG_NO_TRIM% NEQ 0 setlocal ENABLEDELAYEDEXPANSION & ^
set "__STRING__=!__STRING__:  = $20!" & set "__STRING__=!__STRING__:$20 =$20$20!" & ^
set "__STRING__=!__STRING__:		=	$09!" & set "__STRING__=!__STRING__:$09	=$09$09!" & ^
set "__STRING__=!__STRING__:	 =$09$20!" & set "__STRING__=!__STRING__:$09 =$09$20!" & ^
for /F "tokens=* delims="eol^= %%i in ("!__STRING__:	=$09!") do endlocal & set "__STRING__=%%i"

set INDEX=0

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & for %%j in (%%i) do (
  setlocal ENABLEDELAYEDEXPANSION & if !INDEX! GEQ !ARG0_INDEX! (
    if !INDEX! LSS !SKIP! (
      if defined CMDLINE (
        for /F "tokens=* delims="eol^= %%v in ("!CMDLINE!") do endlocal & set "CMDLINE=%%v %%j"
      ) else endlocal & set "CMDLINE=%%j"
    ) else if !INDEX! GEQ !SHIFT! (
      if defined CMDLINE (
        for /F "tokens=* delims="eol^= %%v in ("!CMDLINE!") do endlocal & set "CMDLINE=%%v %%j"
      ) else endlocal & set "CMDLINE=%%j"
    ) else endlocal
  ) else if !INDEX! EQU !VAR_INDEX! (
    endlocal & set "VAR=%%j"
  ) else endlocal
  set /A INDEX+=1
)

if not defined VAR endlocal & exit /b %LAST_ERROR%
setlocal ENABLEDELAYEDEXPANSION & set "__STRING__=!CMDLINE!" & if %FLAG_NO_TRIM% NEQ 0 set "__STRING__=!__STRING__:$20= !" & set "__STRING__=!__STRING__:$09=	!"
if not defined __STRING__ for /F "tokens=* delims="eol^= %%i in ("!VAR!") do endlocal & endlocal & set "%%i=" & exit /b %LAST_ERROR%

for /F "tokens=* delims="eol^= %%i in ("!VAR!") do (
  setlocal DISABLEDELAYEDEXPANSION & if %FLAG_EXE% EQU 0 (
    call "%%?~dp0%%encode\decode_sys_chars_bat_cmdline.bat"
  ) else call "%%?~dp0%%encode\decode_sys_chars_exe_cmdline.bat"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%v in ("!__STRING__!") do endlocal & endlocal & endlocal & endlocal & set "%%i=%%v" & exit /b %LAST_ERROR%
)
