@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script expands variable %2 with numeric expression, store result in
rem   variable %1 and returns with previous error level.

if "%~1" == "" exit /b

rem Drop output variable
set "%~1="

if "%~2" == "" exit /b

(
  rem Expand string %2.
  call set /A "%%~1=%~2"
  rem Exit with previous error level.
  exit /b %ERRORLEVEL%
)

rem Exit with current error level.
