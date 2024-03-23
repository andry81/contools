@echo off

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL
net session >nul 2>nul && goto IMPL

:ELEVATE
set IMPL=1
rem CAUTION: ShellExecute does not wait a child process close!
start /B /WAIT "" "%SystemRoot%\System32\mshta.exe" vbscript:Close^(CreateObject^("Shell.Application").ShellExecute^("%COMSPEC%"^,"/c @call ""%~f0"" %* & pause"^,""^,"runas"^,True))
exit /b

:IMPL
net session >nul 2>nul || (
  echo.%~nx0: error: process must be elevated before continue.
  exit /b 255
) >&2

rem Photoshop x86
sc stop "FLEXnet Licensing Service"
sc config "FLEXnet Licensing Service" start= disabled

rem Photoshop x64
sc stop "FLEXnet Licensing Service 64"
sc config "FLEXnet Licensing Service 64" start= disabled
