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
set "ECPASS=%~1"

rem backup all before start
call "%?~dp0%backup_logs.bat" || exit /b
call "%?~dp0%backup_config.bat" || exit /b

echo;

if defined ECPASS set AMULE_CMDLINE=/P "%ECPASS%"

echo;^>"%AMULE_CMD_EXECUTABLE%" %AMULE_CMDLINE%
"%AMULE_GUI_EXECUTABLE%" %AMULE_CMDLINE%
