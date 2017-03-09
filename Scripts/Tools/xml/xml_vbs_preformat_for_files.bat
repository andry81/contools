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
cd .

setlocal

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0.."
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

set "?~nx0=%~nx0"
set "?~dp0=%~dp0"

rem script flags
set "CMD_FLAG_ARGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
  set CMD_FLAG_ARGS=%CMD_FLAG_ARGS%%1 

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "CMD_VA_ARGS="

:PROCESS_FILES_LOOP
if "%~1" == "" goto PROCESS_FILES_LOOP_END

set CMD_VA_ARGS=%CMD_VA_ARGS%%1 
shift

goto PROCESS_FILES_LOOP

:PROCESS_FILES_LOOP_END

for /F "usebackq eol= tokens=* delims=" %%i in (`dir /A:-D /B /S %CMD_VA_ARGS%`) do (
  echo.%%i
  call "%%TOOLS_PATH%%/xml/vbs/xml_preformat.vbs" %%CMD_FLAG_ARGS%% "%%i" "%%i"
)