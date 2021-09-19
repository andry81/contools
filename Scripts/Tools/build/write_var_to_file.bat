@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to set project build time.

rem Examples:
rem 1. call write_var_to_file.bat PROJECT_NAME c:\_b\MyProject\build\vars\post_build.vars "" STAGE_OUT.PROJECT_NAME || exit /b

setlocal

set "__VAR_NAME_OUT=%~1"
set "__FILE_OUT=%~f2"
set "__VAR_VALUE=%~3"
set "__VAR_NAME_IN=%~4"

set "__FILE_OUT_DIR=%~dp2"

if not defined __VAR_NAME_IN set "__VAR_NAME_IN=%__VAR_NAME_OUT%"

if not defined __VAR_VALUE call set "__VAR_VALUE=%%%__VAR_NAME_IN%%%"

echo.%__VAR_NAME_IN% -^> %__VAR_NAME_OUT%="%__VAR_VALUE%"

if not exist "%__FILE_OUT_DIR%" (
  echo.%~nx0: error: directory does not exist to write output file: "%__FILE_OUT%">&2
  exit /b -1
)

echo."%__VAR_NAME_OUT%=%__VAR_VALUE%">> "%__FILE_OUT%"

exit /b
