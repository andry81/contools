@echo off
if "%~1" == "" (call)
if not "%~1" == "" goto SKIP_IF
(
  if 0
  exit /b
) >&2
:SKIP_IF
if defined %~1 (call)
if not defined %~1 goto SKIP_IF
setlocal DISABLEDELAYEDEXPANSION
(
  if 0 "%~nx0: %~1: %~2"
) >&2
:SKIP_IF
exit /b

rem USAGE:
rem   assert_if_def.bat <var> <message>

rem Description:
rem   Tests `<var>` and if is not empty and defined, then stops an outer script
rem   execution with the error message:
rem     `"assert_if_def.bat: <var>: <message>" was unexpected at this time.`
rem   If `<var>` is empty, then stops an outer script execution
rem   with the error message:
rem     `The syntax of the command is incorrect.`
rem   If `<var>` is empty or defined, then returns not zero error level.

rem Examples:
rem   1. >assert_if_def.bat
rem      The syntax of the command is incorrect.
rem
rem   2. >assert_if_def.bat a b c
rem      >set "a="
rem      "assert_if_def.bat: a: b" was unexpected at this time.
rem
rem   3. >assert_if_def.bat a "b c"
rem      >set "a="
rem      "assert_if_def.bat: a: b c" was unexpected at this time.
