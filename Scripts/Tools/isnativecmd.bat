@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script detects native Windows cmd.exe.
rem   Returns 0 if it is, and 1 - if not.

if not defined COMSPEC exit /b 1

call :CHECK "%%COMSPEC%%"
exit /b

:CHECK
if not "%~nx1" == "cmd.exe" exit /b 2
exit /b 0
