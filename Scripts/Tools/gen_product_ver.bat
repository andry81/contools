@echo off

setlocal

set "VER_FILE_PATH=%~1"
set "VER_VALUE=%~2"

if exist "%VER_FILE_PATH%" (
  for /F "usebackq eol= tokens=1,2,3,* delims=." %%i in (%VER_FILE_PATH%) do (
    set MAJOR_VER=%%i
    set MINOR_VER=%%j
    set PATCH_VER=%%k
    set REVISION_VER=%%l
  )
) else (
  for /F "usebackq eol= tokens=1,2,3,* delims=." %%i in ('%VER_VALUE%') do (
    set MAJOR_VER=%%i
    set MINOR_VER=%%j
    set PATCH_VER=%%k
    set REVISION_VER=%%l
  )
)

set /A REVISION_VER+=1
echo.%MAJOR_VER%.%MINOR_VER%.%PATCH_VER%.%REVISION_VER%> "%VER_FILE_PATH%"
exit /b 0
