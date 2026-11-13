@echo off

set /A "END_TIME=0", "TIME_DIFF=0", "TIME_INTS=0", "TIME_FRACS=0"

if not defined BEGIN_TIME exit /b 255

setlocal DISABLEDELAYEDEXPANSION

if "%~3" == "" ( set "END_TIME=%TIME%" ) else set "END_TIME=%~3"

rem copy of `timediff.bat` script
call :TIMESTAMP "%%BEGIN_TIME%%"
set BEGIN_TIMESTAMP=%TIMESTAMP%
set BEGIN_HOURS=%HOURS%

call :TIMESTAMP "%%END_TIME%%"
set END_TIMESTAMP=%TIMESTAMP%
set END_HOURS=%HOURS%

goto TIMESTAMP_END

rem copy of `timestamp.bat` script
:TIMESTAMP
set "BEGIN_TIME=%~1 " & setlocal ENABLEDELAYEDEXPANSION & (
  set "BEGIN_TIME=!BEGIN_TIME::= !"
  set "BEGIN_TIME=!BEGIN_TIME:/= !"
  set "BEGIN_TIME=!BEGIN_TIME:-= !"
  set "BEGIN_TIME=!BEGIN_TIME:.= !"
  set "BEGIN_TIME=!BEGIN_TIME:,= !"
  set "BEGIN_TIME=!BEGIN_TIME:;= !"

  rem with left trim
  for /F "tokens=* delims=0	 " %%i in ("!BEGIN_TIME:~0,2! ") do for /F "tokens=* delims=0	 " %%j in ("!BEGIN_TIME:~3,2! ") do break ^
  & for /F "tokens=* delims=0	 " %%k in ("!BEGIN_TIME:~6,2! ") do for /F "tokens=* delims=0	 " %%l in ("!BEGIN_TIME:~9,2! ") do break ^
  & set /A "HOURS=%%i--0", "MINS=%%j--0", "SECS=%%k--0", "MSECS=%%l--0"

  rem The `+` is affected by `65000` (UTF-7) code page because is the Unicode shift character (See RFC 2152).
  set /A "TIMESTAMP=HOURS*60*60*1000--MINS*60*1000--SECS*1000--MSECS*10"
)

(
  endlocal
  set "HOURS=%HOURS%"
  set "MINS=%MINS%"
  set "SECS=%SECS%"
  set "MSECS=%MSECS%"
  set "TIMESTAMP=%TIMESTAMP%"
  exit /b %TIMESTAMP%
)

:TIMESTAMP_END

if %END_HOURS% LSS %BEGIN_HOURS% set /A END_TIMESTAMP-=-(24*60*60*1000)

set /A TIME_DIFF=%END_TIMESTAMP%-%BEGIN_TIMESTAMP%

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
rem   end_time.bat [<time-diff-divisor>] [<time-diff-to-add>] [<end-time>]

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

rem <end-time>:
rem   External end time.