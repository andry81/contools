@echo off & (call) & rem echo;%*
goto IF%~1 || exit /b -1
:IF1
if %~2 <nul ( exit /b 0 ) else shift & shift 
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF3
if %2 %~3 %4 <nul ( exit /b 0 ) else shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF4
if %~2 %3 %~4 %5 <nul ( exit /b 0 ) else shift & shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF5
if %~2 %~3 %4 %~5 %6 <nul ( exit /b 0 ) else shift & shift & shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF1
if %~2 <nul ( exit /b 0 ) else shift & shift 
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF3
if %2 %~3 %4 <nul ( exit /b 0 ) else shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF4
if %~2 %3 %~4 %5 <nul ( exit /b 0 ) else shift & shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF5
if %~2 %~3 %4 %~5 %6 <nul ( exit /b 0 ) else shift & shift & shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF1
if %~2 <nul ( exit /b 0 ) else shift & shift 
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF3
if %2 %~3 %4 <nul ( exit /b 0 ) else shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF4
if %~2 %3 %~4 %5 <nul ( exit /b 0 ) else shift & shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF5
if %~2 %~3 %4 %~5 %6 <nul ( exit /b 0 ) else shift & shift & shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF1
if %~2 <nul ( exit /b 0 ) else shift & shift 
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF3
if %2 %~3 %4 <nul ( exit /b 0 ) else shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF4
if %~2 %3 %~4 %5 <nul ( exit /b 0 ) else shift & shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF5
if %~2 %~3 %4 %~5 %6 <nul ( exit /b 0 ) else shift & shift & shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF1
if %~2 <nul ( exit /b 0 ) else shift & shift 
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF3
if %2 %~3 %4 <nul ( exit /b 0 ) else shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF4
if %~2 %3 %~4 %5 <nul ( exit /b 0 ) else shift & shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1
:IF5
if %~2 %~3 %4 %~5 %6 <nul ( exit /b 0 ) else shift & shift & shift & shift & shift & shift
( if "%~1" == "" exit /b 255 ) & goto IF%~1 || exit /b -1

rem USAGE: ifn_or.bat <if-expt0-len> <if-expr0> [...<if-exptN-len> <if-exprN>]

rem Description:
rem   The `if` script with multiple variable length expressions in a command
rem   line using an expression per multiple arguments chained by the `OR`
rem   operator.
rem   The script can be chained by the `&&` and `||` operators.

rem <if-expt-len>:
rem   Length of the following expression as number of a command line arguments.
rem
rem <if-expr>:
rem   The `if` expression, see `if /?` for details.

rem Examples:
rem   1. rem Numbers comparison
rem      >call ifn_or.bat 3 1 NEQ 1 3 10 GTR 9
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0
rem
rem   2. rem Strings comparison
rem      >call ifn_or.bat 3 1 NEQ 1 3 "10" LSS "9"
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0
