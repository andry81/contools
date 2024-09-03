@echo off

rem USAGE:
rem   create-junction-points.bat <junction-list-file>

for /F "usebackq eol= tokens=1,* delims=*" %%i in ("%~1") do echo."%%i" -^> "%%j"& mklink /j "%%i" "%%j"
