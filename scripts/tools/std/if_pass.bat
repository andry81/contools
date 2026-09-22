@echo off & setlocal & set "LAST_ERROR=%ERRORLEVEL%" & (call) & rem echo;%*
if %* <nul ( exit /b 0 )
if %LAST_ERROR% NEQ 0 exit /b %LAST_ERROR%
exit /b 255

rem USAGE:
rem   if_pass.bat <if-expr>...

rem Description:
rem   The `if` script with multiple expressions in the command line.
rem   The script can be chained by the `&&` and `||` operators.
rem
rem   Script does not change the exit code if the previous exist code is not 0,
rem   otherwise returns 255.

rem <if-expr>:
rem   The `if` expression, see `if /?` for details.

rem Examples:
rem   1. rem Numbers comparison
rem      >call if_pass.bat 10 GTR 9
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0
rem
rem   2. rem Strings comparison
rem      >call if_pass.bat "10" LSS "9"
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0

rem Examples:
rem   Pass the previous exit code to further processing in the call chain:
rem
rem   1. >call errlvl.bat 123 || call if_pass.bat ^%ERRORLEVEL^% NEQ 123 && echo YES || echo NO
rem      NO
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=123
rem
rem   2. >call errlvl.bat 124 || call if_pass.bat ^%ERRORLEVEL^% NEQ 123 && echo YES || echo NO
rem      YES
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0
