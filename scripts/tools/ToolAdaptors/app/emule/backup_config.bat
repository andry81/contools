@echo off

setlocal

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

:FREE_TEMP_DIR
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LAST_ERROR%

:MAIN
set "EMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX=emule--config-"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%EMULE_CONFIG_DIR%%"          preferences.ini               "%%EMULE_ADAPTOR_BACKUP_DIR%%/%%EMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%EMULE_CONFIG_DIR%%"          statistics.ini                "%%EMULE_ADAPTOR_BACKUP_DIR%%/%%EMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%EMULE_CONFIG_DIR%%"          fileinfo.ini                  "%%EMULE_ADAPTOR_BACKUP_DIR%%/%%EMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H

echo;Archiving backup directory...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%EMULE_ADAPTOR_BACKUP_DIR%%" "%%EMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%/*" "%%EMULE_ADAPTOR_BACKUP_DIR%%/%%EMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%.7z" -sdel || exit /b 20
echo;

call "%%CONTOOLS_ROOT%%/std/rmdir.bat" "%%EMULE_ADAPTOR_BACKUP_DIR%%/%%EMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /S /Q

exit /b 0
