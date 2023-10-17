@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script tryes to call x32 cmd interpreter under any process mode otherwise
rem   it calls a cmd interpreter under current process mode
rem   (x32 under x32 or x64 under x64).

rem   If current process mode is not the x32 process mode, then the cmd.exe
rem   calls with the /K flag.

rem   Waits started process.

if "%PROCESSOR_ARCHITECTURE%" == "x86" goto X86

if exist "%SystemRoot%\Syswow64\*" (
  "%SystemRoot%\Syswow64\cmd.exe" /K %*
  exit /b
)

:X86
if "%~1" == "" exit /b -1

rem Workaround:
rem   The "start" calls cmd.exe with /K parameter, but /K must be used only in different process mode, so call cmd.exe explicitly with /C paramater.
start "" /B /WAIT "%SystemRoot%\System32\cmd.exe" /C %*
