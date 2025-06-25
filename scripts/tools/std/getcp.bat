@echo off & goto DOC_END

rem USAGE:
rem   getcp.bat [<code-page-var>]
:DOC_END

setlocal

rem drop last error level
call;

set "__?VAR_NAME=%~1"

if not defined __?VAR_NAME set "__?VAR_NAME=CURRENT_CP"

set "__?CHCP_FILE="
if exist "%SystemRoot%\System32\chcp.com" set "__?CHCP_FILE=%SystemRoot%\System32\chcp.com"
if not defined __?CHCP_FILE if exist "%SystemRoot%\System64\chcp.com" set "__?CHCP_FILE=%SystemRoot%\System64\chcp.com"

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "__?CHCP_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\%~n0.%RANDOM%-%RANDOM%.txt"
) else set "__?CHCP_TEMP_FILE=%TEMP%\%~n0.%RANDOM%-%RANDOM%.txt"

(
  "%__?CHCP_FILE%" 2>nul > "%__?CHCP_TEMP_FILE%"
  for /F "usebackq tokens=1,* delims=:"eol^= %%i in ("%__?CHCP_TEMP_FILE%") do set "__?CURRENT_CP=%%j"
  del /F /Q /A:-D "%__?CHCP_TEMP_FILE%" >nul 2>nul
) <nul

if defined __?CURRENT_CP set "__?CURRENT_CP=%__?CURRENT_CP: =%"

endlocal & set "%__?VAR_NAME%=%__?CURRENT_CP%"

exit /b 0
