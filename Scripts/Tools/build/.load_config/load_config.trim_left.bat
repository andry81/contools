@echo off
:TRIM_LEFT_LOOP
( if not defined %~1 exit /b 0 ) & ( if not "!%~1:~0,1!" == " " if not "!%~1:~0,1!" == "	" exit /b 0 ) & set "%~1=!%~1:~1!" & goto TRIM_LEFT_LOOP
