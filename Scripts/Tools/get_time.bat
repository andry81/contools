@echo off

rem Description:
rem   Independent to Windows locale time request.

rem Drop last error level
cd .

rem drop return value
set "RETURN_VALUE="

for /F "usebackq eol= tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if "%%i" == "LocalDateTime" set "RETURN_VALUE=%%j"

if not "%RETURN_VALUE%" == "" (
  set "RETURN_VALUE=%RETURN_VALUE:~8,10%"
  exit /b 0
)

exit /b 1
