@echo off

setlocal DISABLEDELAYEDEXPANSION

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
  set "TIME_DIFF=%TIME_DIFF%"
  set "TIME_INTS=%TIME_INTS%"
  set "TIME_FRACS=%TIME_FRACS%"
  exit /b 0
)

rem USAGE:
rem   recalc_time.bat [<time-diff-divisor>] [<time-diff-to-add>]

rem Description:
rem   Script recalculates time in the `TIME_DIFF`, `TIME_INTS`, `TIME_FRACS`
rem   variables in format:
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