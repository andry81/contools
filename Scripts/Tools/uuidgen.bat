@echo off

rem Drop return value
set "RETURN_VALUE="

for /F "usebackq eol=	 tokens=* delims=" %%i in (`"%~dp0uuidgen.exe"`) do set "RETURN_VALUE=%%i"

set "RETURN_VALUE=%RETURN_VALUE:-=_%"
