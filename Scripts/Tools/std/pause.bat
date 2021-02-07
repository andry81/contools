@echo off

rem DESCRIPTION:
rem   Sets the code page to the last known (`%LAST_CP%`) after a code page restore routine (basically after a call to the
rem   `restorecp.bat` script). That is required in cases where the code page before a call to the `chcp.bat` was different
rem   when the after and so the `pause` command does print unreadable text in the log.
rem   This is it, all output into a log file must be made under the same code page!
rem
rem NOTE:
rem   Script does not change the error level because restores it internally
rem

setlocal & set "LASTERROR=%ERRORLEVEL%"

set "CHCP_FILE="
if exist "%SystemRoot%\System32\chcp.com" set "CHCP_FILE=%SystemRoot%\System32\chcp.com"
if not defined CHCP_FILE if exist "%SystemRoot%\System64\chcp.com" set "CHCP_FILE=%SystemRoot%\System64\chcp.com"

if not defined CHCP_FILE (
  if exist "%SystemRoot%\System32\timeout.exe" ( "%SystemRoot%\System32\timeout.exe" /T -1 ) else pause
  exit /b %LASTERROR%
)

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

rem script flags
set "FLAG_CHCP="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

if defined FLAG_CHCP (
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%FLAG_CHCP%%
  if exist "%SystemRoot%\System32\timeout.exe" ( "%SystemRoot%\System32\timeout.exe" /T -1 ) else pause
  call "%%CONTOOLS_ROOT%%/std/restorecp.bat"
  exit /b %LASTERROR%
)

for /F "usebackq eol= tokens=1,* delims=:" %%i in (`@"%%CHCP_FILE%%" ^<nul 2^>nul`) do set "CURRENT_CP=%%j"
if defined CURRENT_CP set "CURRENT_CP=%CURRENT_CP: =%"

if exist "%SystemRoot%\System32\timeout.exe" (
  if defined LAST_CP if not "%CURRENT_CP%" == "%LAST_CP%" ( "%CHCP_FILE%" %LAST_CP% <nul >nul & "%SystemRoot%\System32\timeout.exe" /T -1 & "%CHCP_FILE%" %CURRENT_CP% <nul >nul & exit /b %LASTERROR% )
  "%SystemRoot%\System32\timeout.exe" /T -1
) else (
  if defined LAST_CP if not "%CURRENT_CP%" == "%LAST_CP%" ( "%CHCP_FILE%" %LAST_CP% <nul >nul & pause & "%CHCP_FILE%" %CURRENT_CP% <nul >nul & exit /b %LASTERROR% )
  pause
)

exit /b %LASTERROR%
