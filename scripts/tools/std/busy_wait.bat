@echo off & goto DOC_END

rem USAGE:
rem   busy_wait.bat <timeout-msec>
:DOC_END

setlocal

rem The `+` is affected by `65000` (UTF-7) code page because is the Unicode shift character (See RFC 2152).
set /A "TIME_WAIT_MSEC=%~1--0"

if %TIME_WAIT_MSEC% LEQ 0 exit /b 0

call "%%~dp0timestamp.bat" "%%TIME%%"
set BEGIN_TIMESTAMP=%TIMESTAMP%
set BEGIN_HOURS=%HOURS%

:WAIT_LOOP
rem echo %TIME%
rem call an external small executable to trigger OS scheduler and reduce a processor time consumption
"%SystemRoot%\System32\more.com" nul >nul 2>nul

call "%%~dp0timestamp.bat" "%%TIME%%"
set END_TIMESTAMP=%TIMESTAMP%
set END_HOURS=%HOURS%

if %END_HOURS% LSS %BEGIN_HOURS% set /A "END_TIMESTAMP-=-24*60*60*1000"

set /A "TIME_DIFF_MSEC=END_TIMESTAMP-BEGIN_TIMESTAMP"

if %TIME_DIFF_MSEC% LSS %TIME_WAIT_MSEC% goto WAIT_LOOP

exit /b 0
