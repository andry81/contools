@echo off

setlocal

set BEGIN_TIME=%~1
set HOURS=%BEGIN_TIME:~8,2%
set MINS=%BEGIN_TIME:~10,2%
set SECS=%BEGIN_TIME:~12,2%
set MSECS=%BEGIN_TIME:~15,3%
if %HOURS:~0,1% EQU 0 set HOURS=%HOURS:~1,1%
if %MINS:~0,1% EQU 0 set MINS=%MINS:~1,1%
if %SECS:~0,1% EQU 0 set SECS=%SECS:~1,1%
if %MSECS:~0,1% EQU 0 set MSECS=%MSECS:~1,2%
if %MSECS:~0,1% EQU 0 set MSECS=%MSECS:~1,1%

set /A TIMESTAMP=(%HOURS%*60*60*1000)+(%MINS%*60*1000)+(%SECS%*1000)+%MSECS%

(
  endlocal
  set "HOURS=%HOURS%"
  set "MINS=%MINS%"
  set "SECS=%SECS%"
  set "MSECS=%MSECS%"
  set "TIMESTAMP=%TIMESTAMP%"
  exit /b %TIMESTAMP%
)
