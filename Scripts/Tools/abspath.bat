@echo off

rem Author: Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script converts a file path to absolute canonical path.

rem Command arguments:
rem %1 - File path.

rem Examples:
rem 1. call abspath.bat "../Test"
rem    echo RETURN_VALUE=%RETURN_VALUE%

rem Drop return value
set "RETURN_VALUE="

if "%~1" == "" exit /b -255

set "RETURN_VALUE=%~dpf1"

exit /b 0
