@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Hashdeep wrapper script.

rem Drop last error level
type nul>nul

setlocal

call "%%~dp0__init__.bat" || exit /b

rem use 64-bit application in 64-bit OS
if not "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto NOTX64
rem To avoid potential recursion in case of wrong PROCESSOR_ARCHITECTURE value
if defined PROCESSOR_ARCHITEW6432 goto NOTX64
goto X64

:NOTX64
rem WORKAROUND: The last slash must backward otherwise "Unknown algorithm" error will be thrown.
"%CONTOOLS_HASHDEEP_ROOT%\hashdeep.exe" %*

:X64
rem WORKAROUND: The last slash must backward otherwise "Unknown algorithm" error will be thrown.
"%CONTOOLS_HASHDEEP_ROOT%\hashdeep64.exe" %*

exit /b
