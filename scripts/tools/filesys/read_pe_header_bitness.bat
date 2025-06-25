@echo off & goto DOC_END

rem Description:
rem   Script detects PE binary file bitness.
rem   OS: Windows XP+
:DOC_END

rem drop return value
set "RETURN_VALUE="

setlocal

call "%%~dp0__init__.bat" || exit /b

rem CAUTION:
rem   `for /F` does not return a command error code
for /F "usebackq tokens=* delims="eol^= %%i in (`@"%%SystemRoot%%\System32\cscript.exe" //nologo "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/vbs/read_pe_header_bitness.vbs" %*`) do set "RETURN_VALUE=%%i"

rem cast to integer
set /A RETURN_VALUE+=0

if %RETURN_VALUE% NEQ 0 endlocal & set "RETURN_VALUE=%RETURN_VALUE%" & exit /b 0

exit /b 1
