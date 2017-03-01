@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to set project build time.

setlocal

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0.."
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

call "%%TOOLS_PATH%%/get_date_as_filename.bat"
set "PROJECT_BUILD_DATE=%RETURN_VALUE%"

call "%%TOOLS_PATH%%/get_time_as_filename.bat"
set "PROJECT_BUILD_TIME=%RETURN_VALUE%"

(
  endlocal
  set "PROJECT_BUILD_DATE=%PROJECT_BUILD_DATE%"
  set "PROJECT_BUILD_TIME=%PROJECT_BUILD_TIME%"
)
