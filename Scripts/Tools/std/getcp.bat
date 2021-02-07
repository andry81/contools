@echo off

setlocal

rem drop last error level
type nul >nul

set "__?VAR_NAME=%~1"

if not defined __?VAR_NAME set "__?VAR_NAME=CURRENT_CP"

set "__?CHCP_FILE="
if exist "%SystemRoot%\System32\chcp.com" set "__?CHCP_FILE=%SystemRoot%\System32\chcp.com"
if not defined __?CHCP_FILE if exist "%SystemRoot%\System64\chcp.com" set "__?CHCP_FILE=%SystemRoot%\System64\chcp.com"

for /F "usebackq eol= tokens=1,* delims=:" %%i in (`@"%%__?CHCP_FILE%%" ^<nul 2^>nul`) do set "__?CURRENT_CP=%%j"
if defined __?CURRENT_CP set "__?CURRENT_CP=%__?CURRENT_CP: =%"

(
  endlocal
  set "%__?VAR_NAME%=%__?CURRENT_CP%"
)

exit /b 0
