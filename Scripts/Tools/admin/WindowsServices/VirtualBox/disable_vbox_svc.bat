@echo off

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL
net session >nul 2>&1 && goto IMPL

:ELEVATE
set IMPL=1
rem CAUTION: ShellExecute does not wait a child process close!
start /B /WAIT "" "%SystemRoot%\System32\mshta.exe" vbscript:Close^(CreateObject^("Shell.Application").ShellExecute^("%COMSPEC%"^,"/c @call ""%~f0"" %* & pause"^,""^,"runas"^,True))
exit /b

:IMPL
net session >nul 2>&1 || (
  echo.%~nx0: error: process must be elevated before continue.
  exit /b 255
) >&2

rem COM Server for VirtualBox API
sc stop VBoxSDS
sc config VBoxSDS start= disabled
