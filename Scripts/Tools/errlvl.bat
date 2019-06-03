@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script returns error level passed as first argument. If first argument is
rem   empty, then returns previous error level.

rem Examples:
rem 1. call errlvl.bat 10
rem    echo ERRORLEVEL=%ERRORLEVEL%

if "%~1" == "" exit /b
exit /b %~1
