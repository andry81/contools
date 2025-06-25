@echo off
(call)
(
  setlocal DISABLEDELAYEDEXPANSION
  if 0 "%~nx0: %~1"
) >&2
exit /b

rem USAGE:
rem   assert.bat <message>

rem Description:
rem   Tests `<message>` and if is not empty, then stops an outer script
rem   execution with the error message:
rem     `"assert.bat: <message>" was unexpected at this time.`
rem   If `<message>` is empty, then stops an outer script execution
rem   with the error message:
rem     `The syntax of the command is incorrect.`
rem   Returns not zero error level.

rem Examples:
rem   1. >assert.bat
rem      The syntax of the command is incorrect.
rem
rem   2. >assert.bat a b c
rem      "assert.bat: a" was unexpected at this time.
rem
rem   3. >assert.bat "a b c"
rem      "assert_if_def.bat: a b c" was unexpected at this time.
