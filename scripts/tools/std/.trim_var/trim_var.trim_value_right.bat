@echo off & setlocal ENABLEDELAYEDEXPANSION
:TRIM_RIGHT_LOOP
( if not defined RETURN_VALUE endlocal & set "RETURN_VALUE=" & exit /b 0 ) ^
  & ( if not "!RETURN_VALUE:~-1!" == " " if not "!RETURN_VALUE:~-1!" == "	" for /F "tokens=* delims="eol^= %%i in ("!RETURN_VALUE!") do endlocal & set "RETURN_VALUE=%%i" & exit /b 0 ) ^
  & set "RETURN_VALUE=!RETURN_VALUE:~0,-1!" & goto TRIM_RIGHT_LOOP
