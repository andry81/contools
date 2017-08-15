@echo off

rem drop return values
set "MAKENSIS_CMD_LINE.COMPILE="

setlocal DISABLEDELAYEDEXPANSION

set "CONFIG_ROOT=%~1"

if defined CONFIG_ROOT (
  if "\" == "%CONFIG_ROOT:~0,1%" exit /b 1
  if "\" == "%CONFIG_ROOT:~-1%" set "CONFIG_ROOT=%CONFIG_ROOT:~0,-1%"
)

if not defined CONFIG_ROOT exit /b 1

set "?~nx0=%~nx0"

set CMD_LINE_FILES_LIST=.nsis\00_compile.lst

for %%i in (%CMD_LINE_FILES_LIST%) do (
  set "CMD_LINE_FILE=%%i"
  call :PROCESS_CMD_LINE_FILE
)

rem special variable return trick to return variables with special characters
setlocal ENABLEDELAYEDEXPANSION

set "RETURN_EXEC_LINE=type nul>nul"
if defined MAKENSIS_CMD_LINE.COMPILE set RETURN_EXEC_LINE=!RETURN_EXEC_LINE! ^& set "MAKENSIS_CMD_LINE.COMPILE=%%i"

if defined MAKENSIS_CMD_LINE.COMPILE for /F tokens^=^*^ delims^=^ eol^= %%i in ("!MAKENSIS_CMD_LINE.COMPILE!") do (
  endlocal
  endlocal
  %RETURN_EXEC_LINE%
)

exit /b 0

:PROCESS_CMD_LINE_FILE
if "%CMD_LINE_FILE:_install.=%" == "%CMD_LINE_FILE%" (
  if not exist "%CONFIG_ROOT%\%CMD_LINE_FILE%" (
    echo.%?~nx0%: error: makensis command line file must exist: "%CONFIG_ROOT%\%CMD_LINE_FILE%"
    exit /b 2
  )
) else if not exist "%CONFIG_ROOT%\%CMD_LINE_FILE%" exit /b 0

set "CMD_LINE_VAR_NAME="
if not "%CMD_LINE_FILE:_compile.=%" == "%CMD_LINE_FILE%" (
  set "CMD_LINE_VAR_NAME=MAKENSIS_CMD_LINE.COMPILE"
)

call "%%CONTOOLS_ROOT%%/joinvars.bat" %%CMD_LINE_VAR_NAME%% "%CONFIG_ROOT%\%CMD_LINE_FILE%" " "

if not "%CMD_LINE_VAR_NAME%" == "MAKENSIS_CMD_LINE.INSTALL" (
  if not defined %CMD_LINE_VAR_NAME% (
    echo.%?~nx0%: error: makensis command line file must not be empty: "%CONFIG_ROOT%\%CMD_LINE_FILE%"
    exit /b 3
  )
)
