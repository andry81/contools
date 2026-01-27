@echo off & for %%i in (%*) do set /A %%~i+=0
exit /b

rem USAGE:
rem   case_to_int.bat <var>...

rem Description:
rem   Cast to integer script with a variable list in the command line.
rem   The script can NOT be chained by the `&&` and `||` operators.

rem CAUTION:
rem   The `for %%i in (%*)` statement still can expand the globbing characters
rem   for the files in a current directory. You must avoid them.

rem NOTE:
rem   A variable can be quoted in case of spaces.

rem <var>:
rem   Variable name without globbing characters.

rem Examples:
rem   1. >set A=abc
rem      >set B=1+1
rem      >set C=123
rem      >call cast_to_int.bat A B C
rem      >set A
rem      A=0
rem      >set B
rem      B=1
rem      >set C
rem      C=123
