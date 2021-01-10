@echo off

rem drop last error level
type nul>nul

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

if not defined CURRENT_CP (
  echo.%~nx0: error: CURRENT_CP is not defined.
  exit /b -255
) >&2

set "LAST_CP=%CURRENT_CP%"

set "CURRENT_CP="
for /F "eol= tokens=1,* delims=|" %%i in ("%CP_HISTORY_LIST%") do (
  set "CURRENT_CP=%%i"
  set "CP_HISTORY_LIST=%%j"
)

if not defined CURRENT_CP exit /b 0
if "%CURRENT_CP%" == "%LAST_CP%" exit /b 0

rem echo.chcp restore "%LAST_CP%" ^<- "%CURRENT_CP%" >&2
if %FLAG_PRINT% NEQ 0 (
  chcp.com %CURRENT_CP%
) else chcp.com %CURRENT_CP% >nul
