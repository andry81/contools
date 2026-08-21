@echo off & setlocal DISABLEDELAYEDEXPANSION & set "NUM=%~1" & ( if not defined NUM exit /b 255 ) & ^
set /A "L=NUM" & setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!L!"') do for /F "usebackq tokens=* delims="eol^= %%j in ('"!NUM!"') do endlocal & ^
if %%~i NEQ %%~j exit /b 1
exit /b 0

rem USAGE:
rem   is_int.bat <number>

rem Description:
rem   Tests <value> on integral not expression type.
rem   Can test numbers bigger than 32-bit signed value.

rem <value>:
rem   String value.

rem Examples:
rem   1. >call is_int.bat ""
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=255
rem   2. >call is_int.bat 0 && echo OK
rem      OK
rem   3. >call is_int.bat +0 && echo OK
rem      OK
rem   4. >call is_int.bat ++0
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=1
rem   5. >call is_int.bat 1+1
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=1
