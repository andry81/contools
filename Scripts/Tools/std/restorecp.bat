@echo off

setlocal

rem drop last error level
type nul >nul

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

rem script flags
set FLAG_PRINT=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-p" (
    set FLAG_PRINT=1
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

if not defined CP_HISTORY_LIST (
  echo.%?~nx0%: error: CP_HISTORY_LIST is not defined.
  exit /b 255
) >&2

set "CHCP_FILE="
if exist "%SystemRoot%\System32\chcp.com" set "CHCP_FILE=%SystemRoot%\System32\chcp.com"
if not defined CHCP_FILE if exist "%SystemRoot%\System64\chcp.com" set "CHCP_FILE=%SystemRoot%\System64\chcp.com"

if not defined CHCP_FILE (
  echo.%?~nx0%: error: `chcp.com` is not found.
  exit /b 255
) >&2

set "LAST_CP=%CURRENT_CP%"
if not defined LAST_CP for /F "usebackq eol= tokens=1,* delims=:" %%i in (`@"%%CHCP_FILE%%" 2^>nul`) do set "LAST_CP=%%j"

set "CURRENT_CP="
for /F "eol= tokens=1,* delims=|" %%i in ("%CP_HISTORY_LIST%") do ( set "CURRENT_CP=%%i" & set "CP_HISTORY_LIST=%%j" )

if not defined CURRENT_CP exit /b 0
if "%CURRENT_CP%" == "%LAST_CP%" exit /b 0

rem echo.chcp restore "%LAST_CP%" ^<- "%CURRENT_CP%" >&2
if %FLAG_PRINT% NEQ 0 (
  "%CHCP_FILE%" %CURRENT_CP%
) else "%CHCP_FILE%" %CURRENT_CP% >nul

(
  endlocal
  set "LAST_CP=%LAST_CP%"
  set "CURRENT_CP=%CURRENT_CP%"
  set "CP_HISTORY_LIST=%CP_HISTORY_LIST%"
)
