@echo off

set END_TIME=0
set TIME_DIFF=0
set TIME_INTS=0
set TIME_FRACS=0

if not defined BEGIN_TIME exit /b 255

setlocal DISABLEDELAYEDEXPANSION

set "END_TIME=%TIME%"

call "%%~dp0timediff.bat" "%%BEGIN_TIME%%" "%%END_TIME%%"

set /A "TIME_DENOMINATOR=%~1 + 0"
set /A "TIME_DIFF_TO_ADD=%~2 + 0"

if %TIME_DENOMINATOR% EQU 0 set TIME_DENOMINATOR=1

set /A "TIME_DIFF=TIME_DIFF / TIME_DENOMINATOR + TIME_DIFF_TO_ADD"

set /A TIME_INTS=TIME_DIFF / 1000
set /A TIME_FRACS=TIME_DIFF %% 1000

if "%TIME_FRACS:~2,1%" == "" set "TIME_FRACS=0%TIME_FRACS%"
if "%TIME_FRACS:~2,1%" == "" set "TIME_FRACS=0%TIME_FRACS%"

(
  endlocal
  set "END_TIME=%END_TIME%"
  set "TIME_DIFF=%TIME_DIFF%"
  set "TIME_INTS=%TIME_INTS%"
  set "TIME_FRACS=%TIME_FRACS%"
  exit /b 0
)

rem USAGE:
rem   end_time.bat [<time-diff-divisor>] [<time-diff-to-add>]

rem Description:
rem   Script calculates time between this script call and the last call to
rem   `begin_time.bat` script in format:
rem
rem     TIME_INTS.TIME_FRACS
rem
rem  , where TIME_FRACS=NNN - fractions with zero padding.

rem <time-diff-divisor>:
rem   Time difference divisor to divide the result before return.
rem   1 is not defined.

rem <time-diff-to-add>:
rem   Time difference to add (after division of the current different).
rem   0 if not defined.