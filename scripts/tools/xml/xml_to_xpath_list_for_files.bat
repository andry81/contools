@echo off

rem Description:
rem   Script calls xml_to_xpath_list.bat for files in arguments.

rem Flags:
rem  See xml_to_xpath_list.bat for details.

rem Examples:
rem 1. call xml_to_xpath_list_for_files.bat -lnodes 1251 *.xml *.xml.tmpl

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

set CMD_VA_ARGS=%CMD_VA_ARGS% %1
shift

goto PROCESS_FILES_LOOP

:PROCESS_FILES_LOOP_END

rem get and set code page
call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%CODE_PAGE%%

rem CAUTION:
rem   1. If a variable is empty, then it would not be expanded in the `cmd.exe`
rem      command line or in the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement.
rem   2. The `cmd.exe` command line or the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement does expand twice.
rem
rem   We must expand the command line into a variable to avoid these above.
rem
set ?.=@dir%CMD_VA_ARGS% /A:-D /B /O:N /S 2^>nul

for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
  echo;# ------------------------------------------------------------------------------
  echo # File: "%%i"
  echo;# ------------------------------------------------------------------------------
  call "%%CONTOOLS_XML_TOOLS_ROOT%%/xml_to_xpath_list.bat" %%CMD_FLAG_ARGS%% "%%i"
  echo;
)

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"
