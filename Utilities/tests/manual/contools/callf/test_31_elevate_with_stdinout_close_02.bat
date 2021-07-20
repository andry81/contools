@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

echo. >nul 2>nul

"%CALLF_EXE_PATH%" /elevate{ /no-window }{ /attach-parent-console } "" "cmd.exe /k"

pause
