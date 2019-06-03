@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script expands variable %2, store result in variable %1 and returns with
rem   previous error level.

rem Examples:
rem 1. call errlvl.bat 10
rem    set "AAA=BBB"
rem    set "BBB=C:\blabla\%%CCC%%"
rem    set "CCC=blabla\blabla"
rem    call expandvar.bat DDD "%%%AAA%%%"
rem    echo "DDD=%DDD%"

if "%~1" == "" exit /b

rem Drop output variable
set "%~1="

if "%~2" == "" exit /b

(
  rem Expand string %2.
  call set "%%~1=%~2"
  rem Exit with previous error level.
  exit /b %ERRORLEVEL%
)

rem Exit with current error level.
