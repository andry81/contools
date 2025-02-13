@echo off

setlocal DISABLEDELAYEDEXPANSION

for /F "tokens=* delims="eol^= %%i in ("%~2\.") do set "RETURN_VALUE=%%~fi"
rem set "RETURN_VALUE=%RETURN_VALUE:\=/%"
endlocal & set "%~1=%RETURN_VALUE%"

exit /b 0
