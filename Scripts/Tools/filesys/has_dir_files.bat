@echo off

setlocal

set "_nx0=%~nx0"

set "FLAGS= "

set "__ARGS__="

:LOOP
set "PARAM=%~1"

if not defined PARAM goto DIR

set "DIR="
if not "/" == "%PARAM:~0,1%" set "DIR=%PARAM:/=\%"

if not "%FLAGS%" == "%FLAGS:/S =%" call :SET_DIR_FROM_BASE

if not "/" == "%PARAM:~0,1%" (
  rem space at the end
  set __ARGS__=%__ARGS__%"%PARAM:/=\%" 
  if not exist "%DIR%" (
    echo.%_nx0%: error: Directory does not exist: "%DIR%">&2
    exit /b -1
  ) >&2
) else (
  rem space at the end
  set "FLAGS=%FLAGS%%PARAM% "
  set __ARGS__=%__ARGS__%%PARAM% 
)

shift

goto LOOP

:DIR
dir /A:-D /B /O:N %__ARGS__% >nul 2>nul
if %ERRORLEVEL% NEQ 0 exit /b 1

exit /b 0

:SET_DIR_FROM_BASE
set "DIR=%DIR:/=\%"
if "\" == "%DIR:~-1%" exit /b 0
call :SET_DIR_FROM_BASE_IMPL "%%DIR%%"
exit /b

:SET_DIR_FROM_BASE_IMPL
set "DIR=%~dp1"
set "DIR=%DIR:~0,-1%"
exit /b
