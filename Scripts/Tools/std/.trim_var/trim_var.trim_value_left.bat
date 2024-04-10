@echo off

setlocal ENABLEDELAYEDEXPANSION
:TRIM_LEFT_LOOP
( if not defined RETURN_VALUE goto EXIT ) & ( if not "!RETURN_VALUE:~0,1!" == " " if not "!RETURN_VALUE:~0,1!" == "	" goto EXIT ) & set "RETURN_VALUE=%RETURN_VALUE:~1%" & goto TRIM_LEFT_LOOP

:EXIT
if defined RETURN_VALUE ( for /F "eol= tokens=* delims=" %%i in ("!RETURN_VALUE!") do endlocal & set "RETURN_VALUE=%%i" ) else endlocal & set "RETURN_VALUE="
