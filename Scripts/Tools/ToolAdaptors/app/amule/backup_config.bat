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
set "AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX=amule--config-"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           downloads.txt                 "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           amule.conf.bak                "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           server.met.bak                "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           amule.conf                    "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           addresses.dat                 "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           cryptkey.dat                  "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           ipfilter.dat                  "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           ipfilter_static.dat           "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           clients.met                   "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
if exist "%AMULE_CONFIG_DIR%\emfriends.met" (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"         emfriends.met                 "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
)
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           known.met                     "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
rem call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           known2_64.met                 "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           server.met                    "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
if exist "%AMULE_CONFIG_DIR%\staticservers.dat" (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"         staticservers.dat             "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
)
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           preferences.dat               "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10

rem Kademlia files
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           key_index.dat                 "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           load_index.dat                "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           nodes.dat                     "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           preferencesKad.dat            "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           src_index.dat                 "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%AMULE_CONFIG_DIR%%"           statistics.dat                "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10

echo;Archiving backup directory...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%AMULE_ADAPTOR_BACKUP_DIR%%" "%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%/*" "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%.7z" -sdel || exit /b 20
echo;

call "%%CONTOOLS_ROOT%%/std/rmdir.bat" "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /S /Q

exit /b 0
