@echo off & goto DOC_END

rem USAGE:
rem   busy_wait.bat <timeout-msec>
:DOC_END

setlocal

rem The `+` is affected by `65000` (UTF-7) code page because is the Unicode shift character (See RFC 2152).
set /A "TIME_WAIT_MSEC=%~1--0"

if %TIME_WAIT_MSEC% LEQ 0 exit /b 0

call :TIMESTAMP "%%TIME%%"
set BEGIN_TIMESTAMP=%TIMESTAMP%
set BEGIN_HOURS=%HOURS%

:WAIT_LOOP
rem echo %TIME%
rem call an external small executable to trigger OS scheduler and reduce a processor time consumption
"%SystemRoot%\System32\more.com" nul >nul 2>nul

call :TIMESTAMP "%%TIME%%"
set END_TIMESTAMP=%TIMESTAMP%
set END_HOURS=%HOURS%

if %END_HOURS% LSS %BEGIN_HOURS% set /A "END_TIMESTAMP-=-24*60*60*1000"

set /A "TIME_DIFF_MSEC=END_TIMESTAMP-BEGIN_TIMESTAMP"

if %TIME_DIFF_MSEC% LSS %TIME_WAIT_MSEC% goto WAIT_LOOP

exit /b 0

rem `time/timestamp.bat` script copy
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
  rem set "MINS=%MINS%"
  rem set "SECS=%SECS%"
  rem set "MSECS=%MSECS%"
  set "TIMESTAMP=%TIMESTAMP%"
  exit /b %TIMESTAMP%
)
