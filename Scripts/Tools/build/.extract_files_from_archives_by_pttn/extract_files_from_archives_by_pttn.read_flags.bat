@echo off

rem script flags
set FLAG_SHIFT=0
set CREATE_DIR_FROM_ARCHIVE_FILE_NAME=1

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-i" (
    set CREATE_DIR_FROM_ARCHIVE_FILE_NAME=0
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift
  set /A FLAG_SHIFT+=1

  rem read until no flags
  goto FLAGS_LOOP
)
