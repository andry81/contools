@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to set project build time.

setlocal

call "%%~dp0__init__.bat" || goto :EOF

call "%%CONTOOLS_ROOT%%/get_date_as_filename.bat"
set "PROJECT_BUILD_DATE=%RETURN_VALUE%"

call "%%CONTOOLS_ROOT%%/get_time_as_filename.bat"
set "PROJECT_BUILD_TIME=%RETURN_VALUE%"

(
  endlocal
  set "PROJECT_BUILD_DATE=%PROJECT_BUILD_DATE%"
  set "PROJECT_BUILD_TIME=%PROJECT_BUILD_TIME%"
)
