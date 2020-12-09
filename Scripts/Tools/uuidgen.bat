@echo off

setlocal

rem Drop return value
set "RETURN_VALUE="

for /F "usebackq eol= tokens=* delims=" %%i in (`@"%CONTOOLS_UTILITIES_BIN_ROOT%/Microsoft/uuidgen.exe"`) do set "RETURN_VALUE=%%i"

(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE:-=_%"
)
