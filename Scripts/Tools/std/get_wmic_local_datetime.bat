@echo off

rem Description:
rem   Independent to Windows locale date/time request.

rem Drop last error level
type nul>nul

rem drop return value
set "RETURN_VALUE="

for /F "usebackq eol=	 tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>nul`) do if "%%i" == "LocalDateTime" set "RETURN_VALUE=%%j"

if defined RETURN_VALUE (
  set "RETURN_VALUE=%RETURN_VALUE:~0,18%"
  exit /b 0
)

exit /b 1
