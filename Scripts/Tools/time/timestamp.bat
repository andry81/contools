@echo off

setlocal

set BEGIN_TIME=%~1
set HOURS=%BEGIN_TIME:~0,2%
set MINS=%BEGIN_TIME:~3,2%
set SECS=%BEGIN_TIME:~6,2%
set MSECS=%BEGIN_TIME:~9,2%

if defined HOURS ( if 0 EQU %HOURS:~0,1%0 set "HOURS=%HOURS:~1,1%" ) else set HOURS=0
if defined MINS ( if 0 EQU %MINS:~0,1%0 set "MINS=%MINS:~1,1%" ) else set MINS=0
if defined SECS ( if 0 EQU %SECS:~0,1%0 set "SECS=%SECS:~1,1%" ) else set SECS=0
if defined MSECS ( if 0 EQU %MSECS:~0,1%0 set "MSECS=%MSECS:~1%" ) else set MSECS=0
if defined MSECS ( if not "%MSECS%" == "0" if 0 EQU %MSECS:~0,1%0 set "MSECS=%MSECS:~1%" ) else set MSECS=0
if not defined MSECS set MSECS=0

set /A TIMESTAMP=(%HOURS%*60*60*1000)+(%MINS%*60*1000)+(%SECS%*1000)+%MSECS%*10

(
  endlocal
  set "HOURS=%HOURS%"
  set "MINS=%MINS%"
  set "SECS=%SECS%"
  set "MSECS=%MSECS%"
  set "TIMESTAMP=%TIMESTAMP%"
  exit /b %TIMESTAMP%
)
