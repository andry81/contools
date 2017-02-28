@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script converts relative path to the DOS canonical path.

rem Command arguments:
rem %1 - Relative path.

rem Examples:
rem 1. call dospath.bat "../Test"
rem    echo PATH_VALUE=%PATH_VALUE%

rem Drop output values before request
set "PATH_VALUE="

if "%~1" == "" exit /b 65

rem Drop last error level
cd .

set "PATH_VALUE=%~s1"
