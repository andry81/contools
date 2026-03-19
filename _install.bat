@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

if %WINDOWS_X64_VER%0 NEQ 0 call "%%~dp0._install\install_system64.bat"
echo;

if %WINDOWS_X32_VER%0 NEQ 0 call "%%~dp0._install\install_system32.bat"
echo;
