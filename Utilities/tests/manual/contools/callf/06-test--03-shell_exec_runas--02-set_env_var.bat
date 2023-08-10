@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

"%CALLF_EXE_PATH%" /shell-exec runas /v "TEST" "123" "${COMSPEC}" "/c \"echo.TEST=%%TEST%% ^& pause\""

pause
