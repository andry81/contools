@echo off & setlocal & set "BEGIN_TIME=%~1 " & setlocal ENABLEDELAYEDEXPANSION & (
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
  endlocal
  set "HOURS=%HOURS%"
  set "MINS=%MINS%"
  set "SECS=%SECS%"
  set "MSECS=%MSECS%"
  set "TIMESTAMP=%TIMESTAMP%"
  exit /b %TIMESTAMP%
)

rem USAGE:
rem   timestamp.bat <time-string>

rem Description:
rem   Evaluate <time-string> into set of variables.

rem <time-string>:
rem   Time string in format: `HH:MM:SS.NN`
rem   , where a separator character can be one of: `:/-.,;`
