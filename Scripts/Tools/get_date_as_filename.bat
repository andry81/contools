@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script gets date in file name compatible form.

rem drop return value
set "RETURN_VALUE="

setlocal

call "%%~dp0__init__.bat" || goto :EOF

call "%%CONTOOLS_ROOT%%/get_date.bat"

(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%"
)
