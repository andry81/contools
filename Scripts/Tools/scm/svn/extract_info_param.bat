@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script extracts parameter value from a text file in special format:
rem     Name : Value

rem Examples:
rem 1. call extract_info_param.bat info.txt URL
rem    echo "RETURN_VALUE=%RETURN_VALUE%"

rem drop return value
set "RETURN_VALUE="

rem Drop last error level
cd .

setlocal

set "INFO_PARAM_FILE=%~1"
set "INFO_PARAM_NAME=%~2"

if not exist "%INFO_PARAM_FILE%" (
  echo.%~nx0: error: info file does not exist: "%INFO_PARAM_FILE%"
  exit /b 1
) >&2

if "%INFO_PARAM_NAME%" == "" (
  echo.%~nx0: error: info param name is not set.
  exit /b 2
) >&2

for /F "usebackq eol= tokens=* delims=" %%i in ("%INFO_PARAM_FILE%") do (
  set "BRANCH_INFO_LINE=%%i"
  call :EXTRACT_INFO_PARAM_LINE && goto EXIT_ON_SUCCESS
)

exit /b 254

:EXIT_ON_SUCCESS
(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE%"
)

exit /b 0

:EXTRACT_INFO_PARAM_LINE
for /F "eol= tokens=1,* delims=:" %%i in ("%BRANCH_INFO_LINE%") do (
  set "INFO_PARAM_LINE_NAME=%%i"
  set "INFO_PARAM_LINE_VALUE=%%j"
  call :PROCESS_INFO_PARAM_LINE && exit /b 0
)
exit /b 1

:PROCESS_INFO_PARAM_LINE
if not "%INFO_PARAM_NAME%" == "%INFO_PARAM_LINE_NAME%" exit /b 1
call :TRIM_BEGINNING_SPACES "%%INFO_PARAM_LINE_VALUE%%"
exit /b 0

:TRIM_BEGINNING_SPACES
rem drop return value
set "RETURN_VALUE="
for /F "eol= tokens=* delims=	 " %%i in ("%~1") do set "RETURN_VALUE=%%i"
exit /b 0
