@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script converts relative path to the DOS canonical path and prints it.

rem Command arguments:
rem %1 - Relative path.

rem Examples:
rem 1. call printdospath.bat "../Test"

rem Drop output values before request
(
  set PATH_VALUE=0
  set PATH_VALUE=
)

if "%~1" == "" exit /b 65

rem Drop last error level
cd .

echo "%~s1"
