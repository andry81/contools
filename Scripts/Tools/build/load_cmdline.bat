@echo off

rem USAGE:
rem   load_cmdline.bat <OutVar> <CmdlineFile>

rem Description:
rem   Script to load a command line file, where an argument is treated per line.
rem   The `#` as the line first character is a line comment starter.
rem   To insert `#` as the line first raw character use the space character.

rem <OutVar>
rem   Output variable name.

rem <CmdlineFile>:
rem   Command line file path.

rem reset output variable
if not "%~1" == "" if defined %~1 set "%~1="

setlocal DISABLEDELAYEDEXPANSION

set "OUT_VAR=%~1"
set "CMDLINE_FILE=%~2"

if not defined OUT_VAR (
  echo.%~nx0: error: output variable name is not defined.
  exit /b 1
) >&2

if not defined CMDLINE_FILE (
  echo.%~nx0: error: command line file is not defined.
  exit /b 2
) >&2

for /F "tokens=* delims="eol^= %%i in ("%CMDLINE_FILE%\.") do set "CMDLINE_FILE=%%~fi"

if not exist "%CMDLINE_FILE%" (
  echo.%~nx0: error: command line file does not exist: "%CMDLINE_FILE%".
  exit /b 10
) >&2

set "CMDLINE="

for /F "usebackq eol=# tokens=* delims=" %%i in ("%CMDLINE_FILE%") do (
  if defined CMDLINE (
    setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!CMDLINE!") do endlocal & set "CMDLINE=%%j %%i"
  ) else set "CMDLINE=%%i"
)

rem return variable
if defined CMDLINE (
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!CMDLINE!") do endlocal & endlocal & set "%OUT_VAR%=%%i"
)

exit /b 0
