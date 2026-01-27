@echo off & (call) & if "%~1" == "" exit /b 255
if not defined %~1 <nul ( exit /b 255 )
setlocal DISABLEDELAYEDEXPANSION & call set "FILE_PATH=%%%~1:"=%%"
if not defined FILE_PATH exit /b 255
if not exist "%FILE_PATH%" exit /b 255
if exist "%FILE_PATH%\*" exit /b 255
exit /b 0

rem USAGE:
rem   if_def_and_file_exist.bat <var>

rem Description:
rem   The `if defined ... if exist ...` expression script with a file path in a
rem   variable.

rem <var>:
rem   Variable name without spaces and globbing characters.

rem Examples:
rem   1. >set A=C:\Windows\System32\cmd.exe
rem      >call if_def_and_file_exist.bat A
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0
