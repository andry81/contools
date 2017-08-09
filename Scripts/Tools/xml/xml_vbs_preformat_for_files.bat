@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script calls vbs/xml_preformat.vbs for files in arguments.

rem   WARNING:
rem     Script will overwrite input files!

rem Flags:
rem  See vbs/xml_preformat.vbs for details.

rem Examples:
rem 1. call xml_vbs_preformat_for_files.bat *.xml *.xml.tmpl

rem Drop last error level
type nul>nul

setlocal

call "%%~dp0__init__.bat" || goto :EOF

set "?~nx0=%~nx0"
set "?~dp0=%~dp0"

rem script flags
set "CMD_FLAG_ARGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  set CMD_FLAG_ARGS=%CMD_FLAG_ARGS%%1 

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set NUM_CMD_VA_ARGS=0
set "CMD_VA_ARGS="

:PROCESS_FILES_LOOP
if "%~1" == "" goto PROCESS_FILES_LOOP_END

set CMD_VA_ARGS=%CMD_VA_ARGS%%1 
set /A NUM_CMD_VA_ARGS+=1
shift

goto PROCESS_FILES_LOOP

:PROCESS_FILES_LOOP_END

if %NUM_CMD_VA_ARGS% EQU 0 (
  echo.%?~nx0%: error: must set at least one wildcard token or directory path.
  exit /b 255
) >&2

for /F "usebackq eol=	 tokens=* delims=" %%i in (`dir /A:-D /B /S %CMD_VA_ARGS%`) do (
  echo.%%i
  call "%%XML_TOOLS_ROOT%%/vbs/xml_preformat.vbs" %%CMD_FLAG_ARGS%% "%%i" "%%i"
)
