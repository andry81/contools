@echo off

setlocal DISABLEDELAYEDEXPANSION

call :TIMESTAMP "%%~1"
set BEGIN_TIMESTAMP=%TIMESTAMP%
set BEGIN_HOURS=%HOURS%

call :TIMESTAMP "%%~2"
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

(
  endlocal
  set "TIME_DIFF=%TIME_DIFF%"
  exit /b %TIME_DIFF%
)
