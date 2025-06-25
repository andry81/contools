@echo off

if defined CONTOOLS_PROJECT_TESTS_INIT0_DIR if exist "%CONTOOLS_PROJECT_TESTS_INIT0_DIR%\*" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

exit /b 0
