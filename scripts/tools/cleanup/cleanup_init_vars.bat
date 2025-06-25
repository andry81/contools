@echo off

setlocal

rem in case if relative
for /F "tokens=* delims="eol^= %%i in ("%INIT_VARS_FILE%") do set "INIT_VARS_FILE=%%~fi"

if exist "%INIT_VARS_FILE%" (
  rem use `PROJECT_LOG_DIR` as current directory by default
  if exist "%PROJECT_LOG_DIR%" pushd "%PROJECT_LOG_DIR%" && (
    call "%%~dp0cleanup_file.bat" "%%INIT_VARS_FILE%%"

    rem delete sed inplace backups
    del /F /Q /A:-D "sed*" 2>nul

    popd
  ) else for /F "tokens=* delims="eol^= %%i in ("%INIT_VARS_FILE%") do pushd "%%~di" && (
    call "%%~dp0cleanup_file.bat" "%%INIT_VARS_FILE%%"

    rem delete sed inplace backups
    del /F /Q /A:-D "sed*" 2>nul

    popd
  )
)
