@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

"%CALLFG_EXE_PATH%" /elevate /create-console "" "\"${COMSPEC}\" /c echo.\"{0} {1}\" & pause" "1 2" "3 4"

pause
