@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script gets directory path from full path.
rem   If success script setups variable FOUND_PATH and returns 0.
rem   Otherwise returns non zero error level.

rem Command arguments:
rem %1 - Full path.
rem %2 - Flags:
rem    -e - (Default) Set FOUND_PATH only if full path is exist.
rem    -i - Ignore existance of full path.

rem Examples:
rem 1. call dirpath.bat C:\blabla\blabla -i
rem    echo FOUND_PATH=%FOUND_PATH%

rem Drop variable FOUND_PATH.
set "FOUND_PATH="

if "%~1" == "" exit /b 65

rem Drop last error level.
cd .

if not "%~2" == "-i" (
  if not exist "%~1" exit /b 1
)

set "FOUND_PATH=%~dp1"
