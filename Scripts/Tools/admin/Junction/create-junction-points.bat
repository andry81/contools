@echo off

for /F "usebackq eol= tokens=1,* delims=*" %%i in ("%~1") do ( echo."%%i" -^> "%%j" & mklink /j "%%i" "%%j" )
