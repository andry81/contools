@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script reads file size by file path. If success script returns file size,
rem   otherwise -1.

rem Command arguments:
rem %1 - File path.

rem Examples:
rem 1. call filesize.bat "C:\blabla\blabla.ext"

if "%~1" == "" exit /b -1

rem Drop last error level.
cd .

if not exist "%~1" exit /b -1

exit /b %~z1
