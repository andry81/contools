@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo.^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

set "BEGIN_TIME=%TIME%"

for /L %%i in (1,1,3) do (
  "%SystemRoot%\System32\cscript.exe" //nologo "%CONTOOLS_ROOT%/std/sleep.vbs" 50
)

call "%%CONTOOLS_ROOT%%/timediff.bat" "%%BEGIN_TIME%%" "%%TIME%%"

(
  endlocal
  set "TIMEDIFF=%TIMEDIFF%"
)

set /A TIMEDIFF/=3

set /A TIME_SECS=%TIMEDIFF% / 1000
set /A TIME_MSECS=%TIMEDIFF% %% 1000

if "%TIME_MSECS:~2,1%" == "" set "TIME_MSECS=0%TIME_MSECS%"
if "%TIME_MSECS:~2,1%" == "" set "TIME_MSECS=0%TIME_MSECS%"

echo Time spent: %TIME_SECS%.%TIME_MSECS% secs
echo.

exit /b 0