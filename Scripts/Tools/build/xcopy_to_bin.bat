@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to copy file(s) from one directory to another with rename option
rem   through the copy-and-delete. If output name is different than the input
rem   one then the script will copy the file into output directory w/o renaming
rem   it and only after that will try to rename the file. If the file would be
rem   somehow locked on a moment of rename then the original file will be left
rem   unrenamed in the output directory to manual rename later.

rem Examples:
rem 1. call xcopy_to_bin.bat "%%UPSTREAM.PROJECT_STAGE_POSTBUILDBUILD_ROOT.BIN_DIR%%" "%%DOWNSTREAM.PROJECT_STAGE_BUILD_ROOT.BIN_DIR%%/%%PUBLISH_APP_DIR%%" "myapp.exe" "myapp_v2.exe" || goto :EOF

setlocal

set "?~dp0=%~dp0"

set "FROM_ROOT=%~dpf1"
set "TO_ROOT=%~dpf2"
set "FROM_FILE=%~3"
set "TO_FILE=%~4"

if not exist "%~2" (
  echo.%~nx0: error: output path does not exist: "%~2"
  exit /b 127
) >&2

rem Drop last error level
type nul>nul

call "%%?~dp0%%__init__.bat" || goto :EOF

( call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat" "%%FROM_ROOT%%" "%%FROM_FILE%%" "%%TO_ROOT%%" /Y /D || goto :EOF ) && ^
if /i not "%TO_ROOT%/%FROM_FILE%" == "%TO_ROOT%/%TO_FILE%" (
  (
    call "%%CONTOOLS_ROOT%%/std/copy.bat" "%%TO_ROOT%%/%%FROM_FILE%%" "%%TO_ROOT%%/%%TO_FILE%%" /B /Y || goto :EOF
  ) && (
    call "%%CONTOOLS_ROOT%%/std/del_file.bat" "%%TO_ROOT%%/%%FROM_FILE%%" /F /Q || goto :EOF
  )
)

exit /b 0
