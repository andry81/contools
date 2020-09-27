@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

set "BEGIN_TIME=%TIME%"

set __STRING__=a

setlocal ENABLEDELAYEDEXPANSION

for /L %%i in (1,1,13) do (
  call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v

  set __STRING__=!__STRING__!!__STRING__!
)

endlocal

call "%%CONTOOLS_ROOT%%/timediff.bat" "%%BEGIN_TIME%%" "%%TIME%%"

set /A TIME_SECS=%TIMEDIFF% / 1000
set /A TIME_MSECS=%TIMEDIFF% %% 1000
echo Time spent: %TIME_SECS%.%TIME_MSECS% secs

exit /b 0
