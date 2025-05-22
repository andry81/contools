@echo off & goto DOC_END

rem USAGE:
rem   load_cmdline.bat <outvar> <cmdline-file>

rem Description:
rem   Script to load a command line file, where an argument is a text line.
rem   The `#` as the line first character is a line comment starter.
rem   To insert `#` as the line first raw character use the space character.

rem <outvar>
rem   Output variable name.

rem <cmdline-file>:
rem   Command line file path.
:DOC_END

rem reset output variable
if not "%~1" == "" if defined %~1 set "%~1="

setlocal DISABLEDELAYEDEXPANSION

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "OUT_VAR=%~1"
set "CMDLINE_FILE=%~2"

if not defined OUT_VAR (
  echo;%?~%: error: output variable name is not defined.
  exit /b 1
) >&2

if not defined CMDLINE_FILE (
  echo;%?~%: error: command line file is not defined.
  exit /b 2
) >&2

for /F "tokens=* delims="eol^= %%i in ("%CMDLINE_FILE%\.") do set "CMDLINE_FILE=%%~fi"

if not exist "%CMDLINE_FILE%" (
  echo;%?~%: error: command line file does not exist: "%CMDLINE_FILE%".
  exit /b 10
) >&2

set "CMDLINE="

for /F "usebackq eol=# tokens=* delims=" %%i in ("%CMDLINE_FILE%") do (
  if defined CMDLINE (
    setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!CMDLINE!") do endlocal & set "CMDLINE=%%j %%i"
  ) else set "CMDLINE=%%i"
)

rem return variable with leading white spaces trim
if defined CMDLINE (
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims=	 "eol^= %%i in ("!CMDLINE!") do endlocal & endlocal & set "%OUT_VAR%=%%i"
) else endlocal & set "%OUT_VAR%="

exit /b 0
