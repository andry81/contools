@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script tryes to call x32 cmd interpreter under any process mode otherwise
rem   it calls a cmd interpreter under current process mode
rem   (x32 under x32 or x64 under x64).

rem   If current process mode is not the x32 process mode, then the cmd.exe
rem   calls with the /K flag.

if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto X64
rem in case of wrong PROCESSOR_ARCHITECTURE value
if "%PROCESSOR_ARCHITEW6432%" == "" goto X64

if "%~1" == "" exit /b -1

call %%*
rem Exit with current error level.
goto :EOF

:X64
if exist "%SystemRoot%\Syswow64\" (
  "%SystemRoot%\Syswow64\cmd.exe" /K %*
) else (
  "%SystemRoot%\System32\cmd.exe" /K %*
)
