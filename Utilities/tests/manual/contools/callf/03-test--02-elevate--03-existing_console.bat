@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

start "" /WAIT "%CALLFG_EXE_PATH%" /elevate /promote{ /attach-parent-console } "" "\"${COMSPEC}\" /c echo.\"{0} {1}\"" "1 2" "3 4"

pause
