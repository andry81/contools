@echo off

rem USAGE:
rem   create-junction-points.bat <junction-list-file>

for /F "usebackq tokens=1,* delims=*"eol^= %%i in ("%~1") do echo."%%i" -^> "%%j"& mklink /j "%%i" "%%j"
