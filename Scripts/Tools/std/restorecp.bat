@echo off

rem drop last error level
type nul>nul

if not defined CURRENT_CP exit /b -255

set "LAST_CP=%CURRENT_CP%"

set "CURRENT_CP="
for /F "eol=	 tokens=1,* delims=|" %%i in ("%CP_HISTORY_LIST%") do (
  set "CURRENT_CP=%%i"
  set "CP_HISTORY_LIST=%%j"
)

if not defined CURRENT_CP exit /b 0
if "%CURRENT_CP%" == "%LAST_CP%" exit /b 0

rem echo.chcp restore "%LAST_CP%" ^<- "%CURRENT_CP%" >&2
chcp.com %CURRENT_CP% >nul
