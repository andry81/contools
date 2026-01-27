@echo off & (call) & rem echo;%*
:LOOP
if %~1 <nul ( shift ) else exit /b 255
if "%~1" == "" exit /b 0
if %~1 <nul ( shift ) else exit /b 255
if "%~1" == "" exit /b 0
if %~1 <nul ( shift ) else exit /b 255
if "%~1" == "" exit /b 0
if %~1 <nul ( shift ) else exit /b 255
if "%~1" == "" exit /b 0
if %~1 <nul ( shift ) else exit /b 255
if "%~1" == "" exit /b 0
goto LOOP

rem USAGE:
rem   if_and.bat <if-expr>...

rem Description:
rem   The `if` script with multiple fixed length expressions in the command
rem   line using an expression per argument chained by the `AND` operator.
rem   The script can be chained by the `&&` and `||` operators.

rem <if-expr>:
rem   The `if` expression, see `if /?` for details.

rem Examples:
rem   1. rem Numbers comparison
rem      >call if_and.bat "10 GTR 9" "100 GTR 99"
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0
rem
rem   NOTE:
rem     Strings comparison is not supported, use `ifn_*.bat` scripts instead.
