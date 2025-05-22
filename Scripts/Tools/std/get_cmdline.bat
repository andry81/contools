@echo off & goto DOC_END

rem USAGE:
rem   get_cmdline.bat <cmdline>...

rem Description:
rem   Script sets RETURN_VALUE variable to a command line without skip or shift
rem   the arguments.
rem   Does not change the error level.

rem <cmdline>:
rem   Command line to get.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.
rem

rem NOTE:
rem   To skip or shift the arguments do use the `setshift.bat` script instead.
rem   To call a command with skipped or shifted arguments do use
rem   `callshift.bat` script.

rem Examples:
rem   1. >get_cmdline.bat "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      >set RETURN_VALUE
rem      RETURN_VALUE="1 2" ! ? * & | , ; = = "=" 3
rem   2. >errlvl.bat 123
rem      >get_cmdline.bat
rem      >get_cmdline.bat 1
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=123
:DOC_END

rem with save of previous error level
setlocal & set LAST_ERROR=%ERRORLEVEL%

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
if not defined __STRING__ endlocal & set "RETURN_VALUE=" & exit /b %LAST_ERROR%

setlocal ENABLEDELAYEDEXPANSION & if not "!__STRING__:~6!" == "# " (
  for /F "tokens=* delims="eol^= %%i in ("!__STRING__:~6,-2!") do endlocal & set "__STRING__=%%i"
) else endlocal & set "__STRING__="

if not defined __STRING__ endlocal & set "RETURN_VALUE=" & exit /b %LAST_ERROR%

(
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & endlocal & set "RETURN_VALUE=%%i"
  exit /b %LAST_ERROR%
)
