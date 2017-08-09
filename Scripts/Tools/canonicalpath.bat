@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Converts input file/directory path to the canonical windows form.

rem Examples:
rem 1. call canonicalpath.bat "blabla/../.."
rem    echo.PATH_VALUE=%PATH_VALUE%

rem Drop output values before request
set "PATH_VALUE="

if "%~1" == "" exit /b 65

set "PATH_VALUE=%~dpf1"
set "PATH_VALUE=%PATH_VALUE:/=\%"

rem remove trailing backslash
if defined PATH_VALUE (
  if "%PATH_VALUE:~-1,1%" == "\" set "PATH_VALUE=%PATH_VALUE:~0,-1%"
)

exit /b 0
