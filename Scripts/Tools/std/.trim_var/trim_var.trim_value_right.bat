@echo off
:TRIM_RIGHT_LOOP
( if not defined RETURN_VALUE exit /b 0 ) & ( if not "!RETURN_VALUE:~-1!" == " " if not "!RETURN_VALUE:~-1!" == "	" exit /b 0 ) & set "RETURN_VALUE=!RETURN_VALUE:~0,-1!" & goto TRIM_RIGHT_LOOP
