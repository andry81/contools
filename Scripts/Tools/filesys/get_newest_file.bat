@echo off

setlocal

set "FILE_PATH=%~1"

rem drop return value
set "FOUND_PATH="

set "LAST_FILE="
for /F "usebackq eol= tokens=* delims=" %%i in (`@dir "%%FILE_PATH:/=\%%" /A:-D /B /O:D /T:W 2^>nul`) do set "LAST_FILE=%%i"

call :GET_DIR "%%FILE_PATH%%"

(
  endlocal
  set "FOUND_PATH=%FILE_DIR%%LAST_FILE%"
)

exit /b 0

:GET_DIR
set "FILE_DIR=%~dp1"
exit /b
