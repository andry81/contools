@echo off & goto DOC_END

rem USAGE:
rem   load_cmdline.bat [-+] [<Flags>] [--] <outvar> <cmdline-file>

rem Description:
rem   Script to load a command line from a text file into a variable.
rem   The `#` as the line first character is a line comment starter.
rem   To insert `#` as the line first raw character use the space character.
rem   All spaces in each line in a text file by default does trim from the
rem   left.

rem <Flags>:
rem   -notrim
rem     Disables command line arguments trim.

rem -+:
rem   Separator to begin flags scope to parse.
rem --:
rem   Separator to end flags scope to parse.
rem   Required if `-+` is used.
rem   If `-+` is used, then must be used the same quantity of times.

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

rem script flags
set FLAG_FLAGS_SCOPE=0
set FLAG_NOTRIM=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG if "%FLAG%" == "-+" set /A FLAG_FLAGS_SCOPE+=1
if defined FLAG if "%FLAG%" == "--" set /A FLAG_FLAGS_SCOPE-=1

if defined FLAG (
  if "%FLAG%" == "-notrim" (
    set FLAG_NOTRIM=1
  ) else if not "%FLAG%" == "-+" if not "%FLAG%" == "--" (
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP

  if %FLAG_FLAGS_SCOPE% GTR 0 goto FLAGS_LOOP
)

if %FLAG_FLAGS_SCOPE% GTR 0 (
  echo;%?~%: error: not ended flags scope: %FLAG_FLAGS_SCOPE%
  exit /b -255
) >&2

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

if %FLAG_NOTRIM% EQU 0 (
  for /F "usebackq eol=# tokens=* delims=" %%i in ("%CMDLINE_FILE%") do for /F "tokens=* delims=	 " %%j in ("%%i") do (
    if defined CMDLINE (
      setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%k in ("!CMDLINE!") do endlocal & set "CMDLINE=%%k %%j"
    ) else set "CMDLINE=%%j"
  )
) else for /F "usebackq eol=# tokens=* delims=" %%i in ("%CMDLINE_FILE%") do (
  if defined CMDLINE (
    setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!CMDLINE!") do endlocal & set "CMDLINE=%%j %%i"
  ) else set "CMDLINE=%%i"
)

rem return variable with leading white spaces trim
if defined CMDLINE (
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims=	 "eol^= %%i in ("!CMDLINE!") do endlocal & endlocal & set "%OUT_VAR%=%%i"
) else endlocal & set "%OUT_VAR%="

exit /b 0
