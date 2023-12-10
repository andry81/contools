@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

call "%%~dp0_cleanup_by_recent_list.bat" "%%~dp0lists\windows_shell.lst"
