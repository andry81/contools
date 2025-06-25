@echo off

rem drop return value
set RETURN_VALUE=0

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "FILE_PATH=%~1"
set "DELIMS=%~2"
set "FILE_VAR=%~3"
set "DIR_PATH_VAR=%~4"

if not defined DIR_PATH_VAR if not defined FILE_VAR (
  echo;%?~%: error: at least one variable name must be set.
  exit /b 1
) >&2

if not defined DELIMS set DELIMS=/
set "SEPARATOR=%DELIMS:~0,1%"

set DIR_INDEX=0
set "DIR_PATH="
set "FILE=%FILE_PATH%"

if not defined FILE goto EXIT

set DIR_INDEX=1
set "SUBPATH="
set "NEXT_FILE=%FILE%"

:LOOP
set "SUBDIR="
for /F "tokens=1,* delims=%DELIMS%"eol^= %%i in ("%NEXT_FILE%") do set "SUBDIR=%%i" & set "NEXT_FILE=%%j"

rem echo SUBDIR=%SUBDIR%
rem echo NEXT_FILE=%NEXT_FILE%
if not defined SUBDIR goto EXIT
if not defined NEXT_FILE goto EXIT

set "FILE=%NEXT_FILE%"

if defined DIR_PATH (
  set "DIR_PATH=%DIR_PATH%%SEPARATOR%%SUBDIR%"
) else set "DIR_PATH=%SUBDIR%"

set /A DIR_INDEX+=1

goto LOOP

:EXIT
if not defined DIR_PATH call set "FILE_BUF=%%FILE:%DELIMS:~0,1%=%%"

rem swap
if not defined DIR_PATH ^
if not "%FILE%" == "%FILE_BUF%" set "DIR_PATH=%FILE%" & set "FILE="

(
  endlocal
  rem return local variables
  set RETURN_VALUE=%DIR_INDEX%
  if not "%DIR_PATH_VAR%" == "" set "%DIR_PATH_VAR%=%DIR_PATH%"
  if not "%FILE_VAR%" == "" set "%FILE_VAR%=%FILE%"
)

exit /b 0
