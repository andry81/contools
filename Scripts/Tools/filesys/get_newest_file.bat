@echo off

setlocal

set "FILE_PATH=%~1"

rem drop return value
set "FOUND_PATH="

rem CAUTION:
rem   If a variable is empty, then it would not be expanded in the `cmd.exe` command line or in case of `for /F ...`!
rem   We must expand the command line into a variable.
rem
set ?.=@dir "%FILE_PATH:/=\%" /A:-D /B /O:D /T:W 2^>nul

set "LAST_FILE="
for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do set "LAST_FILE=%%i"

call :GET_DIR "%%FILE_PATH%%"

(
  endlocal
  set "FOUND_PATH=%FILE_DIR%%LAST_FILE%"
)

exit /b 0

:GET_DIR
set "FILE_DIR=%~dp1"
exit /b
