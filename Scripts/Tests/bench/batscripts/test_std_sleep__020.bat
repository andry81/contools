@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo.^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

set "BEGIN_TIME=%TIME%"

for /L %%i in (1,1,5) do (
  call "%%CONTOOLS_ROOT%%/std/sleep.bat" 20
)

call "%%CONTOOLS_ROOT%%/timediff.bat" "%%BEGIN_TIME%%" "%%TIME%%"

(
  endlocal
  set "TIMEDIFF=%TIMEDIFF%"
)

set /A TIMEDIFF/=5

set /A TIME_SECS=%TIMEDIFF% / 1000
set /A TIME_MSECS=%TIMEDIFF% %% 1000

if "%TIME_MSECS:~2,1%" == "" set "TIME_MSECS=0%TIME_MSECS%"
if "%TIME_MSECS:~1,1%" == "" set "TIME_MSECS=0%TIME_MSECS%"

echo Time spent: %TIME_SECS%.%TIME_MSECS% secs
echo.

exit /b 0
