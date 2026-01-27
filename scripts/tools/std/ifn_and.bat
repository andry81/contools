@echo off & (call) & rem echo;%*
goto IF%~1 || exit /b -1
:IF1
if %~2 <nul ( shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF3
if %2 %~3 %4 <nul ( shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF4
if %~2 %3 %~4 %5 <nul ( shift & shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF5
if %~2 %~3 %4 %~5 %6 <nul ( shift & shift & shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF1
if %~2 <nul ( shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF3
if %2 %~3 %4 <nul ( shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF4
if %~2 %3 %~4 %5 <nul ( shift & shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF5
if %~2 %~3 %4 %~5 %6 <nul ( shift & shift & shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF1
if %~2 <nul ( shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF3
if %2 %~3 %4 <nul ( shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF4
if %~2 %3 %~4 %5 <nul ( shift & shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF5
if %~2 %~3 %4 %~5 %6 <nul ( shift & shift & shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF1
if %~2 <nul ( shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF3
if %2 %~3 %4 <nul ( shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF4
if %~2 %3 %~4 %5 <nul ( shift & shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF5
if %~2 %~3 %4 %~5 %6 <nul ( shift & shift & shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF1
if %~2 <nul ( shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF3
if %2 %~3 %4 <nul ( shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF4
if %~2 %3 %~4 %5 <nul ( shift & shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1
:IF5
if %~2 %~3 %4 %~5 %6 <nul ( shift & shift & shift & shift & shift & shift ) else exit /b 255
( if "%~1" == "" exit /b 0 ) & goto IF%~1 || exit /b -1

rem USAGE:
rem   ifn_and.bat <if-expr0-len> <if-expr0>... [<if-exprN-len> <if-exprN>...]...

rem Description:
rem   The `if` script with multiple variable length expressions in the command
rem   line using an expression per multiple arguments chained by the `AND`
rem   operator.
rem   The script can be chained by the `&&` and `||` operators.

rem <if-expr-len>:
rem   Length of the following expression as number of a command line arguments.
rem
rem <if-expr>:
rem   The `if` expression, see `if /?` for details.

rem Examples:
rem   1. rem Numbers comparison
rem      >call ifn_and.bat 3 10 GTR 9 3 100 GTR 99
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0
rem
rem   2. rem Strings comparison
rem      >call ifn_and.bat 3 "10" LSS "9" 3 "100" LSS "99"
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0
