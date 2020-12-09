@echo off

rem DESCRIPTION:
rem   Sets the code page to the last known (`%LAST_CP%`) after a code page restore routine (basically after a call to the
rem   `restorecp.bat` script). That is required in cases where the code page before a call to the `chcp.bat` was different
rem   when the after and so the `pause` command does print unreadable text in the log. This is it, all output into a log
rem   file must be made under the same code page!
rem
rem NOTE:
rem   Script does not change the error level because restores it internally
rem

setlocal & set "LASTERROR=%ERRORLEVEL%"

set "CURRENT_CP="
for /F "usebackq eol= tokens=1,* delims=:" %%i in (`chcp.com 2^>nul`) do set "CURRENT_CP=%%j"

if defined CURRENT_CP set "CURRENT_CP=%CURRENT_CP: =%"

if defined LAST_CP if not "%CURRENT_CP%" == "%LAST_CP%" ( chcp.com %LAST_CP% >nul & "%WINDIR%\System32\timeout.exe" /T -1 & chcp.com %CURRENT_CP% >nul & exit /b %LASTERROR% )

pause

exit /b %LASTERROR%
