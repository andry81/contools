@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

"%CALLF_EXE_PATH%" /elevate{ /no-window }{ /attach-parent-console } "" "\"${COMSPEC}\" /c echo.\"{0} {1}\"" "1 2" "3 4"

pause
