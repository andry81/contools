@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script expands variable %*, store result in variable EXPANDED_VALUE and
rem   returns with previous error level.

rem Drop EXPANDED_VALUE
set "EXPANDED_VALUE="

if "%~1" == "" exit /b
if "%~2" == "" exit /b

(
  rem Expand string %*.
  call set EXPANDED_VALUE=%*
  rem Exit with previous error level.
  exit /b %ERRORLEVEL%
)

rem Exit with current error level.
