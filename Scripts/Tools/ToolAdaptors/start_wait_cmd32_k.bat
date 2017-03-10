@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script tryes to call x32 cmd interpreter under any process mode otherwise
rem   it calls a cmd interpreter under current process mode
rem   (x32 under x32 or x64 under x64).

rem   Always waits started process, even if non console process.

rem   If current process mode is not the x32 process mode, then the cmd.exe
rem   calls with the /K flag.
rem   Doesn't wait started process.

if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto X64
rem in case of wrong PROCESSOR_ARCHITECTURE value
if "%PROCESSOR_ARCHITEW6432%" == "" goto X64

if "%~1" == "" exit /b -1

start "" /B /WAIT %*
rem Exit with current error level.
goto :EOF

:X64
rem just in case
if exist "%SystemRoot%\Syswow64\" (
  "%SystemRoot%\Syswow64\cmd.exe" /K @(if "%~1" == "" exit /b -1) ^|^| start "" /B /WAIT %*
) else (
  "%SystemRoot%\System32\cmd.exe" /K @(if "%~1" == "" exit /b -1) ^|^| start "" /B /WAIT %*
)
