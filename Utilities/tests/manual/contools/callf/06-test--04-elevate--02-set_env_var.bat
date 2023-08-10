@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

"%CALLF_EXE_PATH%" /elevate /v "TEST" "123" "" "cmd.exe /c \"echo.TEST=%%TEST%% ^& pause\""

pause
