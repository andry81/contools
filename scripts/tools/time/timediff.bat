@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0timestamp.bat" "%%~1"
set BEGIN_TIMESTAMP=%TIMESTAMP%
set BEGIN_HOURS=%HOURS%
call "%%~dp0timestamp.bat" "%%~2"
set END_TIMESTAMP=%TIMESTAMP%
set END_HOURS=%HOURS%

if %END_HOURS% LSS %BEGIN_HOURS% set /A END_TIMESTAMP-=-(24*60*60*1000)

set /A TIME_DIFF=%END_TIMESTAMP%-%BEGIN_TIMESTAMP%

(
  endlocal
  set "TIME_DIFF=%TIME_DIFF%"
  exit /b %TIME_DIFF%
)
