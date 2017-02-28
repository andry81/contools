@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script safely drops variable value without change the error level.

if not "%~1" == "" (
  set %~1=0
  set %~1=
)
