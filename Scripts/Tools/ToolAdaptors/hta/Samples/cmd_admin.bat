@echo off

rem Description:
rem  Example of a batch script to use `mshta` to self execute a batch script in elevated environment if started in not elevated environment.

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL
net session >nul 2>&1 && goto IMPL

:ELEVATE
set IMPL=1
rem CAUTION: ShellExecute does not wait a child process close!
start /B /WAIT "" mshta vbscript:Close(CreateObject("Shell.Application").ShellExecute("%COMSPEC%","/c @call ""%~f0""","","runas",True))
pause
exit /b

:IMPL
net session >nul 2>&1 || (
  echo.%~nx0: error: process must be elevated before continue.
  exit /b 255
) >&2

pause
