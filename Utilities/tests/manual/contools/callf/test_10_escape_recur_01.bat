@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

"%CALLF_EXE_PATH%" "" "\"${COMSPEC}\" /c echo.{0}" "%%TIME%%"

pause
