@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

set __STRING__=a

setlocal DISABLEDELAYEDEXPANSION

set "BEGIN_TIME=%TIME%"

for /L %%i in (1,1,13) do (
  call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v

  set __STRING__=!__STRING__!!__STRING__!
)

call "%%CONTOOLS_ROOT%%/timediff.bat" "%%BEGIN_TIME%%" "%%TIME%%"

(
  endlocal
  set "TIMEDIFF=%TIMEDIFF%"
)

set /A TIMEDIFF/=13

set /A TIME_SECS=%TIMEDIFF% / 1000
set /A TIME_MSECS=%TIMEDIFF% %% 1000

if "%TIME_MSECS:~2,1%" == "" set "TIME_MSECS=0%TIME_MSECS%"
if "%TIME_MSECS:~2,1%" == "" set "TIME_MSECS=0%TIME_MSECS%"

echo Time spent: %TIME_SECS%.%TIME_MSECS% secs
echo;

exit /b 0
