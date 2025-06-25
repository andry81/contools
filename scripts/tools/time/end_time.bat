@echo off

set TIMEDIFF=0
set TIME_INTS=0
set TIME_FRACS=0

if not defined BEGIN_TIME exit /b 255

setlocal

call "%%~dp0timediff.bat" "%%BEGIN_TIME%%" "%%TIME%%"

set /A "TIME_DENOMINATOR=%~1"

if %TIME_DENOMINATOR% EQU 0 set TIME_DENOMINATOR=1

set /A TIMEDIFF/=TIME_DENOMINATOR

set /A TIME_INTS=%TIMEDIFF% / 1000
set /A TIME_FRACS=%TIMEDIFF% %% 1000

if "%TIME_FRACS:~2,1%" == "" set "TIME_FRACS=0%TIME_FRACS%"
if "%TIME_FRACS:~2,1%" == "" set "TIME_FRACS=0%TIME_FRACS%"

(
  endlocal
  set "TIMEDIFF=%TIMEDIFF%"
  set "TIME_INTS=%TIME_INTS%"
  set "TIME_FRACS=%TIME_FRACS%"
  exit /b 0
)
