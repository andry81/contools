@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Converts input file/directory path to the windows form.

rem Examples:
rem 1. call canonicalpath.bat "blabla/../.."
rem    echo.PATH_VALUE=%PATH_VALUE%

rem Drop output values before request
(
  set PATH_VALUE=0
  set PATH_VALUE=
)

if "%~1" == "" (
  exit /b 65
)

rem Drop last error level.
cd .

set "PATH_VALUE=%~1"
set "PATH_VALUE=%PATH_VALUE:/=\%"
