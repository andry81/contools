@echo off

rem USAGE:
rem   get_cmdline.bat <cmdline>...

rem Description:
rem   Script sets RETURN_VALUE variable to a command line without skip or shift
rem   the arguments and returns a previous error code.

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

rem with save of previous error level
setlocal & set LAST_ERROR=%ERRORLEVEL%

rem drop last error level
call;

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "CMDLINE_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\get_cmdline.%RANDOM%-%RANDOM%.txt"
) else set "CMDLINE_TEMP_FILE=%TEMP%\get_cmdline.%RANDOM%-%RANDOM%.txt"

rem redirect command line into temporary file to print it correcly
for %%i in (1) do (
  set "PROMPT=$_"
  echo on
  for %%b in (1) do rem %*
  @echo off
) > "%CMDLINE_TEMP_FILE%"

for /F "usebackq eol= tokens=* delims=" %%i in ("%CMDLINE_TEMP_FILE%") do set "RETURN_VALUE=%%i"

del /F /Q /A:-D "%CMDLINE_TEMP_FILE%" >nul 2>nul

(
  setlocal ENABLEDELAYEDEXPANSION
  if not "!RETURN_VALUE:~4,-1!" == "" (
    for /F "eol= tokens=* delims=" %%i in ("!RETURN_VALUE:~4,-1!") do endlocal & endlocal & set "RETURN_VALUE=%%i"
  ) else endlocal & endlocal & set "RETURN_VALUE="
  exit /b %LAST_ERROR%
)
