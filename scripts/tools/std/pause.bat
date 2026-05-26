@echo off & goto DOC_END

rem USAGE:
rem   pause.bat [-chcp <code-page>]

rem Description:
rem   Sets the code page to the last known (`%LAST_CP%`) after a code page
rem   restore routine (basically after a call to the `restorecp.bat` script).
rem   That is required in cases where the code page before a call to the
rem   `chcp.bat` was different when the after and so the `pause` command does
rem   print unreadable text in the log. This is it, all output into a log file
rem   must be made under the same code page!
rem
rem NOTE:
rem   Script does not change the error level because restores it internally
rem
rem CAUTION:
rem   The `chcp.com` does reset the standard input.
rem   See for the details:
rem     "`chcp.com` and `fc.exe` does reset the standard input" :
rem     https://github.com/andry81/contools/discussions/35

rem CAUTION:
rem   The double redirection has an issue versus `callf` utility.
rem   See for details:
rem     "`set /p` skips the input after `callf` call with the elevation" :
rem     https://github.com/andry81/contools/discussions/37
:DOC_END

setlocal & set "LAST_ERROR=%ERRORLEVEL%"

set "?~dp0=%~dp0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem script flags
set "FLAG_CHCP="

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG if "%FLAG%" == "-chcp" set "FLAG_CHCP=%~2" & shift & shift & call set "FLAG=%%~1"

if defined FLAG (
  echo;%?~%: error: invalid flag: %FLAG%
) >&2

if defined FLAG_CHCP (
  call "%%?~dp0%%chcp.bat" %%FLAG_CHCP%%
  if exist "%SystemRoot%\System32\timeout.exe" ( "%SystemRoot%\System32\timeout.exe" /T -1 ) else pause
  call "%%?~dp0%%restorecp.bat"
  exit /b %LAST_ERROR%
)

for /F "usebackq tokens=1,* delims=:"eol^= %%i in (`@"%%CHCP_FILE%%" ^<nul 2^>nul`) do set "CURRENT_CP=%%j"
if defined CURRENT_CP set "CURRENT_CP=%CURRENT_CP: =%"

if exist "%SystemRoot%\System32\timeout.exe" (
  if defined LAST_CP if not "%CURRENT_CP%" == "%LAST_CP%" "%CHCP_FILE%" %LAST_CP% <nul >nul & "%SystemRoot%\System32\timeout.exe" /T -1 & "%CHCP_FILE%" %CURRENT_CP% <nul >nul & exit /b %LAST_ERROR%
  "%SystemRoot%\System32\timeout.exe" /T -1
) else (
  if defined LAST_CP if not "%CURRENT_CP%" == "%LAST_CP%" "%CHCP_FILE%" %LAST_CP% <nul >nul & pause & "%CHCP_FILE%" %CURRENT_CP% <nul >nul & exit /b %LAST_ERROR%
  pause
)

exit /b %LAST_ERROR%
