@echo off & goto DOC_END

rem USAGE:
rem   get_cmdline_len.bat [<flags>] [--] <cmdline>...

rem Description:
rem   Script counts the number of a command line arguments based on flags and
rem   returns the count.
rem
rem   NOTE:
rem     All the rest description is in the `callshift.bat` script.

rem <flags>:
rem   -exe
rem     Use exe command line encoder instead of the batch as by default.
rem     An executable command line does not use `,;=` characters as command
rem     line arguments separator.
rem
rem   -skip <skip-num>
rem     Number of `<cmdline>` arguments to skip before shift.
rem     If not defined, then 0.
rem
rem   -shift <shift>:
rem     Number of `<cmdline>` arguments to skip and shift.
rem     If >=0, then shifts by `<shift>` beginning from `<skip-num>` argument.
rem     If < 0, then shifts by `|<shift>|` beginning from
rem     `<skip-num>+|<shift>|` argument.

rem --:
rem   Separator to stop parse flags.

rem <cmdline>:
rem   Command line to count.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.
rem

rem Examples:
rem   1. >callshift.bat 0 echo "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      "1 2" ! ? * & | "=" 3
rem      >get_cmdline_len.bat -- "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=8
rem   2. >callshift.bat -exe 0 echo "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      "1 2" ! ? * & | , ; = = "=" 3
rem      >get_cmdline_len.bat -exe -- "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=12
rem   3. >callshift.bat -skip 2 -3 echo a b 1 2 3 4 5 6 7
rem      a b 1 2 3 7
rem      >get_cmdline_len.bat -skip 3 -shift -3 -- echo a b 1 2 3 4 5 6 7
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=7
:DOC_END

setlocal DISABLEDELAYEDEXPANSION

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
if not defined __STRING__ exit /b 0

setlocal ENABLEDELAYEDEXPANSION & if not "!__STRING__:~6!" == "# " (
  for /F "tokens=* delims="eol^= %%i in ("!__STRING__:~6,-2!") do endlocal & set "__STRING__=%%i"
) else endlocal & set "__STRING__="

if not defined __STRING__ exit /b 0

set "?~dp0=%~dp0"

rem script flags
set FLAG_SHIFT=0
set FLAG_EXE=0
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

if defined FLAG if "%FLAG%" == "-skip" (
  set "FLAG_SKIP=%~2"
  shift
  shift
  call set "FLAG=%%~1"
  set /A FLAG_SHIFT+=2
)

set SHIFT=0

if defined FLAG if "%FLAG%" == "-shift" (
  set "SHIFT=%~2"
  shift
  shift
  call set "FLAG=%%~1"
  set /A FLAG_SHIFT+=2
)

if defined FLAG if "%FLAG%" == "--" (
  shift
  call set "FLAG=%%~1"
  set /A FLAG_SHIFT+=1
)

rem cast to integer
set /A SHIFT+=0
set /A FLAG_SKIP+=0

if %SHIFT% GEQ 0 (
  set /A FLAG_SHIFT+=SHIFT
) else (
  set /A FLAG_SHIFT+=-SHIFT*2
)

rem encode specific command line characters
if %FLAG_EXE% EQU 0 (
  call "%%?~dp0%%encode\encode_sys_chars_bat_cmdline.bat"
) else call "%%?~dp0%%encode\encode_sys_chars_exe_cmdline.bat"

set COUNT=0

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & for %%j in (%%i) do set /A COUNT+=1

set /A COUNT-=FLAG_SHIFT+FLAG_SKIP

if %COUNT% LSS 0 set COUNT=0

endlocal & exit /b %COUNT%
