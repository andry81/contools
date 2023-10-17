@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script tryes to call x32 cmd interpreter under any process mode otherwise
rem   it exits with -256 error level.

rem   If current process mode is not the x32 process mode and x32 cmd.exe can
rem   be called, then the cmd.exe calls with the /C flag.

rem   Waits started process.

if "%~1" == "" exit /b -1

if "%PROCESSOR_ARCHITECTURE%" == "x86" goto X86

if not exist "%SystemRoot%\Syswow64\*" exit /b -256

"%SystemRoot%\Syswow64\cmd.exe" /C %*
exit /b

:X86
rem Workaround:
rem   The "start" calls cmd.exe with /K parameter, so call cmd.exe explicitly with /C paramater.
start "" /B /WAIT "%SystemRoot%\System32\cmd.exe" /C %*
