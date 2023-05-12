@echo off

rem Description:
rem   Loads variables from a file using exclusion list with builtin and
rem   specific custom variables.

for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%~1") do ( call :FILTER && set "%%i=%%j" )
exit /b 0

:FILTER
for /F "usebackq eol=# tokens=* delims=" %%k in ("%~dp0.set_vars_from_file\exclusion.vars") do ( if /i "%%i" == "%%k" exit /b 1 )
exit /b 0
