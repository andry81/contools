@echo off

setlocal

set "PATH_VALUE=%~dpf1"

set "RETURN_VALUE="

set "PREV_DIR_NAME="
set "LAST_DIR_NAME="

call :GET_BASE_DIR_NAME

(
  endlocal
  if not "%PREV_DIR_NAME%" == "" (
    set "RETURN_VALUE=%PREV_DIR_NAME%"
  ) else (
    set "RETURN_VALUE=%LAST_DIR_NAME%"
  )
)

goto :EOF

:GET_BASE_DIR_NAME
set DIR_INDEX=1
:GET_BASE_DIR_NAME_LOOP
set "DIR_NAME="
for /F "eol=	 tokens=%DIR_INDEX% delims=\" %%i in ("%PATH_VALUE%") do set "DIR_NAME=%%i"
if "%DIR_NAME%" == "" exit /b 0

set "PREV_DIR_NAME=%LAST_DIR_NAME%"
set "LAST_DIR_NAME=%DIR_NAME%"

set /A DIR_INDEX+=1

goto GET_BASE_DIR_NAME_LOOP
