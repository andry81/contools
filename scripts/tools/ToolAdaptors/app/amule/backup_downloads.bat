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
set "AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX=amule--downloads-"

if defined ECPASS set AMULE_CMDLINE=/P "%ECPASS%"
set AMULE_CMDLINE=%AMULE_CMDLINE% -c "show dl"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%AMULE_ADAPTOR_BACKUP_DIR%%\%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" || exit /b

echo;^>"%AMULE_CMD_EXECUTABLE%" %AMULE_CMDLINE%

"%CONTOOLS_UTILS_BIN_ROOT%/contools/callf.exe" ^
  /ret-child-exit /tee-stdout "%AMULE_ADAPTOR_BACKUP_DIR%/%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%PROJECT_LOG_FILE_NAME_DATE_TIME%/downloads.txt" /tee-stderr-dup 1 ^
  "${AMULE_CMD_EXECUTABLE}" "{*}" ${AMULE_CMDLINE} || exit /b

echo;Archiving backup directory...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%AMULE_ADAPTOR_BACKUP_DIR%%" "%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%/*" "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%.7z" -sdel || exit /b 20
echo;

call "%%CONTOOLS_ROOT%%/std/rmdir.bat" "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /S /Q

exit /b 0
