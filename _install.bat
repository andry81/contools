@echo off

setlocal

rem CAUTION:
rem   Immediate Administrator permissions is required to pass a root project
rem   parameters into promoted environment of an external project script.
rem   So you must elevate now to avoid the elevation later.

call "%%~dp0._install/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

if %WINDOWS_X64_VER%0 NEQ 0 call "%%~dp0._install\install_system64.bat"
echo;

if %WINDOWS_X32_VER%0 NEQ 0 call "%%~dp0._install\install_system32.bat"
echo;
