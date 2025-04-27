@echo off

rem script flags
set FLAG_SHIFT=0
set CREATE_DIR_FROM_ARCHIVE_FILE_NAME=1
set CREATE_EXTRACT_TO_DIR=0
set SKIP_ARCHIVES_WITH_EXISTED_EXTRACTED_PREFIX_PATH=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-i" (
    set CREATE_DIR_FROM_ARCHIVE_FILE_NAME=0
  ) else if "%FLAG%" == "-p" (
    set CREATE_EXTRACT_TO_DIR=1
  ) else if "%FLAG%" == "-k" (
    set SKIP_ARCHIVES_WITH_EXISTED_EXTRACTED_PREFIX_PATH=1
  ) else (
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift
  set /A FLAG_SHIFT+=1

  rem read until no flags
  goto FLAGS_LOOP
)

exit /b 0
