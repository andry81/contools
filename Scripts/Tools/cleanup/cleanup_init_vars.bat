@echo off

setlocal

if exist "%INIT_VARS_FILE%" (
  rem use `PROJECT_LOG_DIR` as current directory by default
  if exist "%PROJECT_LOG_DIR%" pushd "%PROJECT_LOG_DIR%" && (
    call "%%~dp0cleanup_file.bat" "%%INIT_VARS_FILE%%"

    rem delete GnuWin32 sed inplace backups
    del /F /Q /A:-D "sed*" 2>nul

    popd
  ) else for /F "tokens=* delims="eol^= %%i in ("%INIT_VARS_FILE%") do pushd "%%~di" && (
    call "%%~dp0cleanup_file.bat" "%%INIT_VARS_FILE%%"

    rem delete GnuWin32 sed inplace backups
    del /F /Q /A:-D "sed*" 2>nul

    popd
  )
)
