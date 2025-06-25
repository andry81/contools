@echo off

rem Description:
rem   Script calls vbs/xml_preformat.vbs for files in arguments.

rem   WARNING:
rem     Script will overwrite input files!

rem Flags:
rem  See vbs/xml_preformat.vbs for details.

rem Examples:
rem 1. call xml_vbs_preformat_for_files.bat *.xml *.xml.tmpl

setlocal

call "%%~dp0__init__.bat" || exit /b

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

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

set CMD_VA_ARGS=%CMD_VA_ARGS% %1
set /A NUM_CMD_VA_ARGS+=1
shift

goto PROCESS_FILES_LOOP

:PROCESS_FILES_LOOP_END

if %NUM_CMD_VA_ARGS% EQU 0 (
  echo;%?~%: error: must set at least one wildcard token or directory path.
  exit /b 255
) >&2

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
  echo;%%i
  call "%%CONTOOLS_XML_TOOLS_ROOT%%/vbs/xml_preformat.vbs" %%CMD_FLAG_ARGS%% "%%i" "%%i"
)
