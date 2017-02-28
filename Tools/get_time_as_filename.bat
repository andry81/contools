@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script gets time in file name compatible form.

rem drop return value
set "RETURN_VALUE="

setlocal

call "%%~dp0get_time.bat"
set "RETURN_VALUE=%RETURN_VALUE:.=_%"

(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE:~0,2%_%RETURN_VALUE:~2,2%_%RETURN_VALUE:~4,6%"
)
