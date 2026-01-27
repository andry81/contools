@echo off & (call)
(
  setlocal DISABLEDELAYEDEXPANSION
  if 0 "%~nx0: %~1"
) >&2
exit /b

rem USAGE:
rem   assert.bat <message>

rem Description:
rem   Stops an outer script execution with the error message:
rem     `"assert.bat: <message>" was unexpected at this time.`
rem   Returns not zero error level.

rem Examples:
rem   1. >assert.bat
rem      "assert.bat: " was unexpected at this time.
rem
rem   2. >assert.bat a b c
rem      "assert.bat: a" was unexpected at this time.
rem
rem   3. >assert.bat "a b c"
rem      "assert.bat: a b c" was unexpected at this time.
