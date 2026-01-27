@echo off & (call) & if "%~1" == "" exit /b 255
if not defined %~1 <nul ( exit /b 255 )
setlocal DISABLEDELAYEDEXPANSION & call set "DIR_PATH=%%%~1:"=%%"
if not defined DIR_PATH exit /b 255
if not exist "%DIR_PATH%\*" exit /b 255
exit /b 0

rem USAGE:
rem   if_def_and_dir_exist.bat <var>

rem Description:
rem   The `if defined ... if exist ...` expression script with a directory path
rem   in a variable.

rem <var>:
rem   Variable name without spaces and globbing characters.

rem Examples:
rem   1. >set A=C:\Windows
rem      >call if_def_and_dir_exist.bat A
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=0
