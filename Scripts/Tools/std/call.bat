@echo off

rem USAGE:
rem   call.bat [-exe] [--] <cmdline>...

rem Description:
rem   Script calls `<cmdline>` as is.
rem   The `call` prefix is not required to call batch scripts.

rem --:
rem   Separator to stop parse flags.

rem -exe
rem   Use exe command line encoder instead of the batch as by default.
rem   An executable command line does not use `,;=` characters as command line
rem   arguments separator.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.
rem

rem Examples (in console):
rem   1. >call.bat echo "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      "1 2" ! ? * & | "=" 3
rem   2. >call.bat -exe echo "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      "1 2" ! ? * & | , ; = = "=" 3
rem   3. >call.bat set | sort
rem   4. >errlvl.bat 123
rem      >call.bat
rem      >call.bat echo.
rem      >call.bat echo 1 2 3
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=123
rem   5. >call.bat exit /b 321
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=321
rem   6. >errlvl.bat 123
rem      >call.bat errlvl.bat 321
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=321
rem   7. >call.bat echo.^>cmd param0 param1
rem      >cmd param0 param1

rem Examples (in script):
rem   1. set "$5E$3E=^>"
rem      call call.bat echo.%%$5E$3E%%cmd param0 param1
rem   2. set "TAB=	"
rem      call call.bat echo.cmd %%TAB%% %%TAB%% param0  %%TAB%%%%TAB%%  %%TAB%%%%TAB%%  param1 %%TAB%% %%TAB%%param2 %%TAB%%param3
rem   3. call call.bat %%*

rem Pros:
rem
rem   * Can handle almost all control characters.
rem   * Can call builtin commands.
rem   * Does restore previous ERRORLEVEL variable before call a command.
rem   * Can avoid spaces and tabulation characters trim in the shifted command line.
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

if defined FLAG if "%FLAG%" == "--" (
  shift
  set /A FLAG_SHIFT+=1
)

set "CMDLINE="

rem encode specific command line characters
if %FLAG_EXE% EQU 0 (
  call "%%?~dp0%%encode\encode_sys_chars_bat_cmdline.bat"
) else call "%%?~dp0%%encode\encode_sys_chars_exe_cmdline.bat"

rem CAUTION:
rem   Encode ALL tabulation characters.
rem   To split arguments with tabulation characters mix you must to entail each argument with at least one SPACE character!
rem
setlocal ENABLEDELAYEDEXPANSION & ^
set "__STRING__=!__STRING__:  = $20!" & set "__STRING__=!__STRING__:$20 =$20$20!" & ^
set "__STRING__=!__STRING__:		=	$09!" & set "__STRING__=!__STRING__:$09	=$09$09!" & ^
set "__STRING__=!__STRING__:	 =$09$20!" & set "__STRING__=!__STRING__:$09 =$09$20!" & ^
for /F "eol= tokens=* delims=" %%i in ("!__STRING__:	=$09!") do endlocal & set "__STRING__=%%i"

set INDEX=-1

setlocal ENABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("!__STRING__!") do endlocal & for %%j in (%%i) do (
  setlocal ENABLEDELAYEDEXPANSION & if !INDEX! GEQ !FLAG_SHIFT! (
    if defined CMDLINE (
      for /F "eol= tokens=* delims=" %%v in ("!CMDLINE!") do endlocal & set "CMDLINE=%%v %%j"
    ) else endlocal & set "CMDLINE=%%j"
  ) else endlocal
  set /A INDEX+=1
)

if not defined CMDLINE endlocal & exit /b %LAST_ERROR%
setlocal ENABLEDELAYEDEXPANSION & set "__STRING__=!CMDLINE!" & ^
set "__STRING__=!__STRING__:$20= !" & set "__STRING__=!__STRING__:$09=	!"

setlocal DISABLEDELAYEDEXPANSION & if %FLAG_EXE% EQU 0 (
  call "%%?~dp0%%encode\decode_sys_chars_bat_cmdline.bat"
) else call "%%?~dp0%%encode\decode_sys_chars_exe_cmdline.bat"
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%v in ("!__STRING__!") do endlocal & endlocal & endlocal & endlocal & call :SETERRORLEVEL %LAST_ERROR% & (
  %%v
)
exit /b

:SETERRORLEVEL
exit /b %*
