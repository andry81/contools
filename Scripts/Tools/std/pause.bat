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

if not exist "%SystemRoot%\System32\chcp.com" goto PAUSE

set "CURRENT_CP="
for /F "usebackq eol= tokens=1,* delims=:" %%i in (`chcp.com 2^>nul`) do set "CURRENT_CP=%%j"

if defined CURRENT_CP set "CURRENT_CP=%CURRENT_CP: =%"

if exist "%SystemRoot%\System32\timeout.exe" (
  if defined LAST_CP if not "%CURRENT_CP%" == "%LAST_CP%" ( "%SystemRoot%\System32\chcp.com" %LAST_CP% >nul & "%SystemRoot%\System32\timeout.exe" /T -1 & "%SystemRoot%\System32\chcp.com" %CURRENT_CP% >nul & exit /b %LASTERROR% )
) else if defined LAST_CP if not "%CURRENT_CP%" == "%LAST_CP%" ( "%SystemRoot%\System32\chcp.com" %LAST_CP% >nul & pause & "%SystemRoot%\System32\chcp.com" %CURRENT_CP% >nul & exit /b %LASTERROR% )

:PAUSE
pause

exit /b %LASTERROR%
