@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script trims input string from spaces and tabs to a variable.

rem Command arguments:
rem %1 - String to trim.
rem %2 - Variable which would store trimmed string.
rem

if "%~2" == "" exit /b 1

rem Create local variable's stack
setlocal

for /f "tokens=* delims=	 " %%i in ("%~1") do set "__STRING__=%%i"

call :TRIM_RIGHT "%%__STRING__%%

(
  endlocal
  set "%~2=%__STRING__%"
)

exit /b

:TRIM_RIGHT
set "__STRING__=%~1"
