@echo off

if not defined LAST_CP exit /b 0
if "%CURRENT_CP%" == "%LAST_CP%" exit /b 0

rem echo.chcp restore "%LAST_CP%" ^<- "%CURRENT_CP%" >&2
chcp.com %LAST_CP% >nul
set "CURRENT_CP=%LAST_CP%"

set "LAST_CP="
for /F "eol=	 tokens=1,* delims=|" %%i in ("%CP_LIST%") do (
  set "LAST_CP=%%i"
  set "CP_LIST=%%j"
)
