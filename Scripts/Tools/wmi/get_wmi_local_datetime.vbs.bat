@echo off

rem drop return value
set "RETURN_VALUE="

rem Drop last error level
call;

rem CAUTION:
rem   `for /F` does not return a command error code
for /F "usebackq tokens=* delims="eol^= %%i in (`@"%%SystemRoot%%\System32\cscript.exe" //nologo "%~dp0print_wmi_local_datetime.vbs" 2^>nul`) do set "RETURN_VALUE=%%i"

if defined RETURN_VALUE endlocal & set "RETURN_VALUE=%RETURN_VALUE:~0,18%" & exit /b 0

exit /b 1

rem Description:
rem   Independent to Windows locale date/time request.
