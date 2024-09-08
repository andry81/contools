@echo off

setlocal

set "TIME_SLEEP_MSEC=%~1"

if not defined TIME_SLEEP_MSEC exit /b -1

rem use pingpath to wait longer than 500 msec
if %TIME_SLEEP_MSEC% GEQ 500 (
  "%SystemRoot%\System32\pathping.exe" 127.0.0.1 -n -q 1 -p %TIME_SLEEP_MSEC% >nul 2>nul
  exit /b 0
) else if %TIME_SLEEP_MSEC% LEQ 0 exit /b 0

call :SET_TIMESTAMP
set BEGIN_TIMESTAMP=%TIMESTAMP%
set BEGIN_HOURS=%HOURS%

rem echo.---

:WAIT_LOOP
call :BUSY_WAIT

call :SET_TIMESTAMP
set END_TIMESTAMP=%TIMESTAMP%
set END_HOURS=%HOURS%

if %END_HOURS% LSS %BEGIN_HOURS% set /A END_TIMESTAMP+=(24*60*60*1000)

set /A TIME_DIFF_MSEC=%END_TIMESTAMP%-%BEGIN_TIMESTAMP%

rem echo %BEGIN_TIMESTAMP% %END_TIMESTAMP% %TIME_DIFF_MSEC%
if %TIME_DIFF_MSEC% LSS %TIME_SLEEP_MSEC% goto WAIT_LOOP

exit /b 0

:BUSY_WAIT
rem call an external small executable to trigger OS scheduler and reduce a processor time consumption
"%SystemRoot%\System32\more.com" nul >nul 2>nul
exit /b 0

:SET_TIMESTAMP
set "BEGIN_TIME=%TIME%"
set "BEGIN_TIME=%BEGIN_TIME::=_%"
set "BEGIN_TIME=%BEGIN_TIME:/=_%"
set "BEGIN_TIME=%BEGIN_TIME:-=_%"
set "BEGIN_TIME=%BEGIN_TIME:.=_%"
set "BEGIN_TIME=%BEGIN_TIME:,=_%"
set "BEGIN_TIME=%BEGIN_TIME: =0%"

set HOURS=%BEGIN_TIME:~0,2%
set MINS=%BEGIN_TIME:~3,2%
set SECS=%BEGIN_TIME:~6,2%
set MSECS_10=%BEGIN_TIME:~9,2%

if %HOURS:~0,1% EQU 0 set HOURS=%HOURS:~1,1%
if %MINS:~0,1% EQU 0 set MINS=%MINS:~1,1%
if %SECS:~0,1% EQU 0 set SECS=%SECS:~1,1%
if %MSECS_10:~0,1% EQU 0 set MSECS_10=%MSECS_10:~1,1%

set /A TIMESTAMP=(%HOURS%*60*60*1000)+(%MINS%*60*1000)+(%SECS%*1000)+%MSECS_10%*10
