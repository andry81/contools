@echo off

setlocal

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

rem call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

rem :FREE_TEMP_DIR
rem rem cleanup temporary files
rem call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LAST_ERROR%

:MAIN
rem backup all before start
rem call "%?~dp0%backup_config.bat" || exit /b
rem call "%?~dp0%backup_part_met_files.bat" || exit /b

rem echo.

echo.^>"%EMULE_EXECUTABLE%"
"%EMULE_EXECUTABLE%"
