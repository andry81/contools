@echo off

if defined CONTOOLS_PROJECT_ROOT_INIT0_DIR if exist "%CONTOOLS_PROJECT_ROOT_INIT0_DIR%\*" exit /b 0

call "%%~dp0__init__.bat" || exit /b

call "%%~dp0..\..\__init__\script_init.bat" %%* || exit /b
