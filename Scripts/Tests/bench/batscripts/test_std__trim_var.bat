@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

set myvar1=              1 ! 2 ^| 3 ^& 4 ^^ 5 = 6 , 7 ; 8 * 9 # 0 %% 1 / 2 \ 3 ? 4 ^> 5 ^< 6 " 7             

set "BEGIN_TIME=%TIME%"

setlocal ENABLEDELAYEDEXPANSION

for /L %%i in (1,1,10) do call "%%CONTOOLS_ROOT%%/std/trim_var.bat" myvar1 myvar2

endlocal

call "%%CONTOOLS_ROOT%%/timediff.bat" "%%BEGIN_TIME%%" "%%TIME%%"

set /A TIME_SECS=%TIMEDIFF% / 1000
set /A TIME_MSECS=%TIMEDIFF% %% 1000
echo Time spent: %TIME_SECS%.%TIME_MSECS% secs

exit /b 0
