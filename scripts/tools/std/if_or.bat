@echo off & (call) & rem echo;%*
:LOOP
if %~1 <nul ( exit /b 0 ) else shift
if "%~1" == "" exit /b 255
if %~1 <nul ( exit /b 0 ) else shift
if "%~1" == "" exit /b 255
if %~1 <nul ( exit /b 0 ) else shift
if "%~1" == "" exit /b 255
if %~1 <nul ( exit /b 0 ) else shift
if "%~1" == "" exit /b 255
if %~1 <nul ( exit /b 0 ) else shift
if "%~1" == "" exit /b 255
goto LOOP

rem USAGE: if_or.bat <if-expr0> [...<if-exprN>]

rem Description:
rem   The `if` script with multiple fixed length expressions in a command line
rem   using an expression per argument chained by the `OR` operator.
rem   The script can be chained by the `&&` and `||` operators.

rem <if-expr>:
rem   The `if` expression, see `if /?` for details.

rem Examples:
rem   1. rem Numbers comparison
rem      >call if_or.bat "10 GTR 9"
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0
rem
rem   NOTE:
rem     Strings comparison is not supported, use `ifn_*.bat` scripts instead.
