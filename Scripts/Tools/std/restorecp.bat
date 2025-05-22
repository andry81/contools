@echo off

setlocal

rem drop last error level
call;

set "?~dp0=%~dp0"
set "?~n0=%~n0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

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
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

if not defined CP_HISTORY_LIST (
  echo;%?~%: error: CP_HISTORY_LIST is not defined.
  exit /b 255
) >&2

set "__?CHCP_FILE="
if exist "%SystemRoot%\System32\chcp.com" set "__?CHCP_FILE=%SystemRoot%\System32\chcp.com"
if not defined __?CHCP_FILE if exist "%SystemRoot%\System64\chcp.com" set "__?CHCP_FILE=%SystemRoot%\System64\chcp.com"

if not defined __?CHCP_FILE (
  echo;%?~%: error: `chcp.com` is not found.
  exit /b 255
) >&2

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "__?CHCP_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\%?~n0%.%RANDOM%-%RANDOM%.txt"
) else set "__?CHCP_TEMP_FILE=%TEMP%\%?~n0%.%RANDOM%-%RANDOM%.txt"

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
  for /F "usebackq tokens=1,* delims=:"eol^= %%i in ("%__?CHCP_TEMP_FILE%") do set "LAST_CP=%%j"
  del /F /Q /A:-D "%__?CHCP_TEMP_FILE%" >nul 2>nul
) <nul

if defined LAST_CP set "LAST_CP=%LAST_CP: =%"

set "CURRENT_CP="
for /F "tokens=1,* delims=|"eol^= %%i in ("%CP_HISTORY_LIST%") do set "CURRENT_CP=%%i" & set "CP_HISTORY_LIST=%%j"

rem echo;chcp restore "%LAST_CP%" ^<- "%CURRENT_CP%" >&2

if not "%CURRENT_CP%" == "%LAST_CP%" (
  if %FLAG_PRINT% NEQ 0 (
    "%__?CHCP_FILE%" %CURRENT_CP%
  ) else "%__?CHCP_FILE%" %CURRENT_CP% >nul
) <nul

(
  endlocal
  set "LAST_CP=%LAST_CP%"
  set "CURRENT_CP=%CURRENT_CP%"
  set "CP_HISTORY_LIST=%CP_HISTORY_LIST%"
  exit /b 0
)
