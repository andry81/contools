@echo off

rem drop return value
set RETURN_VALUE=0

setlocal

set "FILE_PATH=%~1"
set "DELIMS=%~2"
set "FILE_VAR=%~3"
set "DIR_PATH_VAR=%~4"

if "%DIR_PATH_VAR%%FILE_VAR%" == "" (
  echo.%~nx0: error: at least one variable name must be set.
  exit /b 1
) >&2

if "%DELIMS%" == "" set DELIMS=/
set "SEPARATOR=%DELIMS:~0,1%"

set DIR_INDEX=0
set "DIR_PATH="
set "FILE=%FILE_PATH%"

if "%FILE%" == "" goto EXIT

set DIR_INDEX=1
set "SUBPATH="
set "NEXT_FILE=%FILE%"

:LOOP
set "SUBDIR="
for /F "eol=	 tokens=1,* delims=%DELIMS%" %%i in ("%NEXT_FILE%") do (
  set SUBDIR=%%i
  set NEXT_FILE=%%j
)
rem echo SUBDIR=%SUBDIR%
rem echo NEXT_FILE=%NEXT_FILE%
if "%SUBDIR%" == "" goto EXIT
if "%NEXT_FILE%" == "" goto EXIT

set "FILE=%NEXT_FILE%"

if not "%DIR_PATH%" == "" (
  set "DIR_PATH=%DIR_PATH%%SEPARATOR%%SUBDIR%"
) else (
  set "DIR_PATH=%SUBDIR%"
)

set /A DIR_INDEX+=1

goto LOOP

:EXIT
if "%DIR_PATH%" == "" call set "FILE_BUF=%%FILE:%DELIMS:~0,1%=%%"

if "%DIR_PATH%" == "" ^
if not "%FILE%" == "%FILE_BUF%" (
  rem swap
  set "DIR_PATH=%FILE%"
  set "FILE="
)

(
  endlocal
  rem return local variables
  set RETURN_VALUE=%DIR_INDEX%
  if not "%DIR_PATH_VAR%" == "" set "%DIR_PATH_VAR%=%DIR_PATH%"
  if not "%FILE_VAR%" == "" set "%FILE_VAR%=%FILE%"
)

exit /b 0
