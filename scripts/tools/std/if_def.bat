@echo off & (call) & rem echo;%*
for %%i in (%*) do if not defined %%i <nul ( exit /b 255 )
exit /b 0

rem USAGE:
rem   if_def.bat <var>...

rem Description:
rem   The `if` script with a variable list in the command line.
rem   The script can NOT be chained by the `&&` and `||` operators.

rem CAUTION:
rem   The `for %%i in (%*)` statement still can expand the globbing characters
rem   for the files in a current directory. You must avoid them.

rem CAUTION:
rem   Spaces in a variable name is not supported. Quotes does not work in
rem   `if defined "..." ...` expression.

rem <var>:
rem   Variable name without spaces and globbing characters.

rem Examples:
rem   1. >set A=1
rem      >set B=2
rem      >call if_def.bat A B
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0
