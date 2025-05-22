@echo off & goto DOC_END

rem USAGE:
rem   get_cmdline_var_len.bat [<flags>] [--] <var>

rem Description:
rem   Script counts the number of a command line arguments from a variable
rem   value based on flags and returns the count.
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

rem <var>:
rem   Variable with command line to count.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.
rem

rem Examples:
rem   1. >setshift.bat 0 x "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      >set x
rem      x="1 2" ! ? * & | "=" 3
rem      >get_cmdline_var_len.bat -- x
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=8
rem   2. >setshift.bat -exe 0 x "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      >set x
rem      x="1 2" ! ? * & | , ; = = "=" 3
rem      >get_cmdline_var_len.bat -exe -- x
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=12
rem   3. >setshift.bat -skip 2 -3 x a b 1 2 3 4 5 6 7
rem      >set x
rem      x=a b 1 2 3 7
rem      >get_cmdline_var_len.bat -skip 2 -shift 3 -- x
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=1
:DOC_END

setlocal DISABLEDELAYEDEXPANSION

rem drop last error level
call;

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
)

if defined FLAG if "%FLAG%" == "-skip" (
  set "FLAG_SKIP=%~2"
  shift
  shift
  call set "FLAG=%%~1"
)

if defined FLAG if "%FLAG%" == "-shift" (
  set "FLAG_SHIFT=%~2"
  shift
  shift
  call set "FLAG=%%~1"
)

if defined FLAG if "%FLAG%" == "--" (
  shift
  call set "FLAG=%%~1"
)

if "%~1" == "" exit /b 0

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in (""!%~1!"") do endlocal & set "__STRING__=%%~i"

if not defined __STRING__ exit /b 0

rem cast to integer
set /A FLAG_SKIP+=0
set /A FLAG_SHIFT+=0

if %FLAG_SHIFT% LSS 0 set /A FLAG_SHIFT*=-2

rem encode specific command line characters
if %FLAG_EXE% EQU 0 (
  call "%%?~dp0%%encode\encode_sys_chars_bat_cmdline.bat"
) else call "%%?~dp0%%encode\encode_sys_chars_exe_cmdline.bat"

set COUNT=0

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & for %%j in (%%i) do set /A COUNT+=1

set /A COUNT-=FLAG_SHIFT+FLAG_SKIP

if %COUNT% LSS 0 set COUNT=0

endlocal & exit /b %COUNT%
