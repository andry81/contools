@echo off

setlocal

call "%%~dp0timestamp.bat" "%%~1"
set BEGIN_TIMESTAMP=%TIMESTAMP%
set BEGIN_HOURS=%HOURS%
call "%%~dp0timestamp.bat" "%%~2"
set END_TIMESTAMP=%TIMESTAMP%
set END_HOURS=%HOURS%

if %END_HOURS% LSS %BEGIN_HOURS% set /A END_TIMESTAMP+=(24*60*60*1000)

set /A TIMEDIFF=%END_TIMESTAMP%-%BEGIN_TIMESTAMP%

(
  endlocal
  set "TIMEDIFF=%TIMEDIFF%"
  exit /b %TIMEDIFF%
)
