@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script calls xml_to_xpath_list.bat for files in arguments.

rem Flags:
rem  See xml_to_xpath_list.bat for details.

rem Examples:
rem 1. call xml_to_xpath_list_for_files.bat -lnodes 1251 *.xml *.xml.tmpl

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

set CODE_PAGE=%~1

shift

set "CMD_VA_ARGS="

:PROCESS_FILES_LOOP
if "%~1" == "" goto PROCESS_FILES_LOOP_END

set CMD_VA_ARGS=%CMD_VA_ARGS%%1 

:PROCESS_FILES_LOOP_END

rem get code page value from first parameter
set "LAST_CODE_PAGE="

shift

if "%CODE_PAGE%" == "" goto NOCODEPAGE

for /F "usebackq eol= tokens=1,* delims=:" %%i in (`chcp 2^>nul`) do set LAST_CODE_PAGE=%%j
set LAST_CODE_PAGE=%LAST_CODE_PAGE: =%

if not "%LAST_CODE_PAGE%" == "%CODE_PAGE%" chcp %CODE_PAGE% >nul

:NOCODEPAGE
for /F "usebackq eol= tokens=* delims=" %%i in (`dir /A:-D /B /S %CMD_VA_ARGS%`) do (
  echo.# ------------------------------------------------------------------------------
  echo # File: "%%i"
  echo.# ------------------------------------------------------------------------------
  call "%%TOOLS_PATH%%/xml/xml_to_xpath_list.bat" %%CMD_FLAG_ARGS%% "%%i"
  echo.
)

if not "%LAST_CODE_PAGE%" == "%CODE_PAGE%" chcp %LAST_CODE_PAGE% >nul
