@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script extracts URL scheme component from SVN URL.

rem Examples:
rem 1. call extract_url_scheme.bat file:///root/subdir
rem    echo "RETURN_VALUE=%RETURN_VALUE%"
rem 2. call extract_url_scheme.bat https://root/subdir
rem    echo "RETURN_VALUE=%RETURN_VALUE%"

set "RETURN_VALUE="

rem Drop last error level
cd .

setlocal

set "URL=%~1"

for /F "eol= tokens=1,* delims=:" %%i in ("%URL%") do set "RETURN_VALUE=%%i"

(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE%"
)

exit /b 0
