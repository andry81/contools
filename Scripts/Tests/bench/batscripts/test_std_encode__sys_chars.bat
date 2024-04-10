@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

set __STRING__=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=

set "BEGIN_TIME=%TIME%"

setlocal DISABLEDELAYEDEXPANSION

for /L %%i in (1,1,10) do (
  call "%%CONTOOLS_ROOT%%/std/encode/encode_sys_chars.bat"
  call "%%CONTOOLS_ROOT%%/std/encode/decode_sys_chars.bat"
)

endlocal

call "%%CONTOOLS_ROOT%%/timediff.bat" "%%BEGIN_TIME%%" "%%TIME%%"

set /A TIMEDIFF/=10

set /A TIME_SECS=%TIMEDIFF% / 1000
set /A TIME_MSECS=%TIMEDIFF% %% 1000

if "%TIME_MSECS:~2,1%" == "" set "TIME_MSECS=0%TIME_MSECS%"
if "%TIME_MSECS:~1,1%" == "" set "TIME_MSECS=0%TIME_MSECS%"

echo Time spent: %TIME_SECS%.%TIME_MSECS% secs

exit /b 0
