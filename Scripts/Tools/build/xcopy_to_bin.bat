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
rem 1. call xcopy_to_bin.bat "%%PROJECT_STAGE_BIN_PATH%%" "%%MYPROJECT.PROJECT_BIN_PATH%%/%%PUBLISH_APP_DIR%%" "myapp.exe" "myapp_v2.exe" || goto :EOF

setlocal

set "FROM_PATH=%~dpf1"
set "TO_PATH=%~dpf2"
set "FROM_FILE=%~3"
set "TO_FILE=%~4"

if not exist "%~2" (
  echo.%~nx0: error: output path does not exist: "%~2"
  exit /b 127
) >&2

rem Drop last error level
type nul>nul

call "%%~dp0__init__.bat" || goto :EOF

( call :XCOPY_FILE "%%FROM_PATH%%" "%%FROM_FILE%%" "%%TO_PATH%%" /Y /D || goto :EOF ) && ^
if /i not "%TO_PATH%/%FROM_FILE%" == "%TO_PATH%/%TO_FILE%" (
  (
    call :COPY "%%TO_PATH%%/%%FROM_FILE%%" "%%TO_PATH%%/%%TO_FILE%%" /B /Y || goto :EOF
  ) && (
    call :DEL_FILE "%%TO_PATH%%/%%FROM_FILE%%" /F /Q || goto :EOF
  )
)

exit /b 0

:XCOPY_FILE
call "%%CONTOOLS_ROOT%%/xcopy_file.bat" %%* || goto :EOF
exit /b 0

:COPY
call "%%CONTOOLS_ROOT%%/copy.bat" %%* || goto :EOF
exit /b 0

:DEL_FILE
call "%%CONTOOLS_ROOT%%/del_file.bat" %%* || goto :EOF
exit /b 0
