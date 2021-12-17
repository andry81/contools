@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script calls xml_to_xpath_list.bat for files in arguments.

rem Flags:
rem  See xml_to_xpath_list.bat for details.

rem Examples:
rem 1. call xml_to_xpath_list_for_files.bat -lnodes 1251 *.xml *.xml.tmpl

rem Drop last error level
call;

setlocal

call "%%~dp0__init__.bat" || exit /b

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

set CODE_PAGE=%~1
shift

set "CMD_VA_ARGS="

:PROCESS_FILES_LOOP
if "%~1" == "" goto PROCESS_FILES_LOOP_END

set CMD_VA_ARGS=%CMD_VA_ARGS%%1 
shift

goto PROCESS_FILES_LOOP

:PROCESS_FILES_LOOP_END

rem get and set code page
call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%CODE_PAGE%%

for /F "usebackq eol= tokens=* delims=" %%i in (`dir /A:-D /B /O:N /S %CMD_VA_ARGS%`) do (
  echo.# ------------------------------------------------------------------------------
  echo # File: "%%i"
  echo.# ------------------------------------------------------------------------------
  call "%%CONTOOLS_XML_TOOLS_ROOT%%/xml_to_xpath_list.bat" %%CMD_FLAG_ARGS%% "%%i"
  echo.
)

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"
