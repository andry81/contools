@echo off & (call) & rem echo;%*
if %* <nul ( exit /b 0 )
exit /b 255

rem USAGE: if_.bat <if-expr>...

rem Description:
rem   The `if` script with a single expression in a command line.
rem   The script can be chained by the `&&` and `||` operators.

rem <if-expr>:
rem   The `if` expression, see `if /?` for details.

rem Examples:
rem   1. rem Numbers comparison
rem      >call if_.bat 10 GTR 9
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0
rem
rem   2. rem Strings comparison
rem      >call if_.bat "10" LSS "9"
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0
