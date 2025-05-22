@echo off
(
  if 0 %*
) >&2
exit /b

rem Description:
rem   Stops an outer script execution with the message:
rem     `The syntax of the command is incorrect.` if `%1` is empty, otherwise
rem     `%1 was unexpected at this time.` if not.
rem   Does not change the error level.

rem Examples:
rem   1. >assert.bat
rem      The syntax of the command is incorrect.
rem
rem   2. >assert.bat a b c
rem      a was unexpected at this time.
rem
rem   3. >assert.bat "a b c"
rem      "a b c" was unexpected at this time.
