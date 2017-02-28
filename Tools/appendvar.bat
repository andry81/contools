@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script appends value to variable values splitted by separator.

rem Command arguments:
rem %1 - Variable name, which would be appended.
rem %2 - Appending value.
rem %3 - Separator character which may be trailing variable.

rem Examples:
rem 1. call appendvar.bat PATH "C:\blabla\blabla" ";"
rem 2. set "AAA=C:\blabla\blabla\"
rem    call appendvar.bat AAA "blabla\blabla" \

if "%~1" == "" exit /b 65
if "%~2" == "" exit /b 0

rem Drop last error level
cd .

rem Create local variable's stack
setlocal

set __VAR_VALUE=0
call set "__VAR_VALUE=%%%~1%%"

if not "%~3" == "" (
  set "__SEPARATOR=%~3"
  call set "__SEPARATOR=%%__SEPARATOR:~0,1%%"
)

if not "%__VAR_VALUE%" == "" (
  set "__VAR_TRAIL=%__VAR_VALUE:~-1%"
)

if not "%__SEPARATOR%" == "" (
  if not "%__VAR_VALUE%" == "" (
    if not "%~2" == "%__SEPARATOR%" (
      if "%__VAR_TRAIL%" == "%__SEPARATOR%" (
        set "%~1=%__VAR_VALUE%%~2"
      ) else (
        set "%~1=%__VAR_VALUE%%__SEPARATOR%%~2"
      )
    ) else (
      if not "%__VAR_TRAIL%" == "%__SEPARATOR%" (
        set "%~1=%__VAR_VALUE%%__SEPARATOR%"
      )
    )
  ) else (
    set "%~1=%~2"
  )
) else (
  set "%~1=%__VAR_VALUE%%~2"
)

rem Drop internal variables but use some changed value(s) for the return
call set "__ARGS__=%%~1=%%%~1%%"
(
  endlocal
  set "%__ARGS__%"
)

exit /b 0
