@echo off

set END_TIME=0
set TIMEDIFF=0
set TIME_INTS=0
set TIME_FRACS=0

if not defined BEGIN_TIME exit /b 255

setlocal

set "END_TIME=%TIME%"

call "%%~dp0timediff.bat" "%%BEGIN_TIME%%" "%%END_TIME%%"

set /A "TIME_DENOMINATOR=%~1"

if %TIME_DENOMINATOR% EQU 0 set TIME_DENOMINATOR=1

set /A TIMEDIFF/=TIME_DENOMINATOR

set /A TIME_INTS=%TIMEDIFF% / 1000
set /A TIME_FRACS=%TIMEDIFF% %% 1000

if "%TIME_FRACS:~2,1%" == "" set "TIME_FRACS=0%TIME_FRACS%"
if "%TIME_FRACS:~2,1%" == "" set "TIME_FRACS=0%TIME_FRACS%"

(
  endlocal
  set "END_TIME=%END_TIME%"
  set "TIMEDIFF=%TIMEDIFF%"
  set "TIME_INTS=%TIME_INTS%"
  set "TIME_FRACS=%TIME_FRACS%"
  exit /b 0
)

rem USAGE:
rem   end_time.bat <time-diff-divisor>

rem Description:
rem   Script calculates time between this script call and the last call to
rem   `begin_time.bat` script in format:
rem
rem     TIME_INTS.TIME_FRACS
rem
rem  , where TIME_FRACS=NNN - milliseconds with zero padding.

rem <time-diff-divisor>:
rem   Time difference divisor to divide the result before return.