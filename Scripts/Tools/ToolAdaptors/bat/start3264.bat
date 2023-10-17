@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script tryes to start a command line under x32 cmd interpreter otherwise
rem   it calls a cmd interpreter for x64 process mode

rem   If current process mode is not the x32 process mode, then the cmd.exe
rem   calls with the /C flag.

rem   Waits started process.

if "%~1" == "" exit /b -1

if "%PROCESSOR_ARCHITECTURE%" == "x86" goto X86

if exist "%SystemRoot%\Syswow64\*" (
  "%SystemRoot%\Syswow64\cmd.exe" /C %*
  exit /b
)

:X86
start "" /B /WAIT %*
