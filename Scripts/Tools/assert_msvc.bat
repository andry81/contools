@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script checks if it is running under Visual Studio environment.

rem Drop last error level.
call;

if not defined VS_UNICODE_OUTPUT (
  echo This is script must be called inside of Visual Studio Project ^(*.vcproj^) under command line of project/file event
  exit /b 65534
)
