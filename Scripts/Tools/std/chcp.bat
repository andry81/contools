@echo off

rem CAUTION:
rem   When the 65000 codepage is used then some of characters DOES BECOME
rem   CONTROL CHARACTERS!
rem   For example, the plus character (`+`) becomes the unicode codepoint
rem   prefix character and expressions which contain this character like
rem   `set BLABLA=1+1` WILL FAIL!

setlocal

rem drop last error level
call;

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

set "CODE_PAGE=%~1"

if not defined CODE_PAGE (
  echo.%?~nx0%: error: CODE_PAGE is not defined.
  exit /b 255
) >&2

set "__?CHCP_FILE="
if exist "%SystemRoot%\System32\chcp.com" set "__?CHCP_FILE=%SystemRoot%\System32\chcp.com"
if not defined __?CHCP_FILE if exist "%SystemRoot%\System64\chcp.com" set "__?CHCP_FILE=%SystemRoot%\System64\chcp.com"

if not defined __?CHCP_FILE (
  echo.%?~nx0%: error: `chcp.com` is not found.
  exit /b 255
) >&2

set "__?CHCP_TEMP_FILE=%TEMP%\%~n0.%RANDOM%-%RANDOM%.txt"

if not defined CP_HISTORY_LIST goto INIT

rem CAUTION:
rem   Windows XP/7 implementation has an issue with stdin+stdout/stderr double redirection:
rem     `call <nul >nul & call <nul >nul` or `call <nul 2>nul & call <nul 2>nul`
rem     which breaks standard input handle.
rem   To workaround that we need to separate stdin redirection from stdout/stderr redirections:
rem     `(... >nul 2>nul) <nul`
rem

set "LAST_CP=%CURRENT_CP%"
if not defined LAST_CP (
  "%__?CHCP_FILE%" 2>nul > "%__?CHCP_TEMP_FILE%"
  for /F "usebackq eol= tokens=1,* delims=:" %%i in ("%__?CHCP_TEMP_FILE%") do set "LAST_CP=%%j"
  del /F /Q /A:-D "%__?CHCP_TEMP_FILE%" >nul 2>&1
) <nul
set "CP_HISTORY_LIST=%LAST_CP%|%CP_HISTORY_LIST%"
set "CURRENT_CP=%CODE_PAGE%"

goto UPDATECP

:INIT
set "LAST_CP="
(
  "%__?CHCP_FILE%" 2>nul > "%__?CHCP_TEMP_FILE%"
  for /F "usebackq eol= tokens=1,* delims=:" %%i in ("%__?CHCP_TEMP_FILE%") do set "LAST_CP=%%j"
  del /F /Q /A:-D "%__?CHCP_TEMP_FILE%" >nul 2>&1
) <nul
if defined LAST_CP set "LAST_CP=%LAST_CP: =%"

set "CURRENT_CP=%CODE_PAGE%"
set "CP_HISTORY_LIST=%LAST_CP%|"

:UPDATECP
set "__?CHCP_TEMP_FILE="

if "%CURRENT_CP%" == "%LAST_CP%" goto EXIT

(
  if %FLAG_PRINT% NEQ 0 (
    "%__?CHCP_FILE%" %CURRENT_CP% || set "CURRENT_CP=%LAST_CP%"
  ) else "%__?CHCP_FILE%" %CURRENT_CP% >nul || set "CURRENT_CP=%LAST_CP%"
) <nul

:EXIT
(
  endlocal
  set "LAST_CP=%LAST_CP%"
  set "CURRENT_CP=%CURRENT_CP%"
  set "CP_HISTORY_LIST=%CP_HISTORY_LIST%"
  set "__?CHCP_FILE="
)

exit /b 0
