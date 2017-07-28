@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script gets file size.

rem Examples:
rem 1. call get_filesize.bat file
rem    echo %ERRORLEVEL%

rem Drop last error level
type nul>nul

setlocal

set "FILE=%~1"

if not exist "%FILE%" exit /b -1

for /F "eol=	 tokens=* delims=" %%i in ("%FILE%") do exit /b %%~zi

exit /b -1
