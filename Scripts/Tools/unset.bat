@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script safely drops variable value without change the error level.

if defined %~1 set %~1=
