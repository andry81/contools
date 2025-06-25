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
set "QBITTORRENT_ADAPTOR_BACKUP_FILE_NAME_PREFIX=qbittorrent--config-"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%QBITTORRENT_ROAMING_CONFIG_DIR%%"           qBittorrent.ini         "%%QBITTORRENT_ADAPTOR_BACKUP_DIR%%/%%QBITTORRENT_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%QBITTORRENT_ROAMING_CONFIG_DIR%%"           qBittorrent-data.ini    "%%QBITTORRENT_ADAPTOR_BACKUP_DIR%%/%%QBITTORRENT_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10

echo;Archiving backup directory...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%QBITTORRENT_ADAPTOR_BACKUP_DIR%%" "%%QBITTORRENT_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%/*.*" "%%QBITTORRENT_ADAPTOR_BACKUP_DIR%%/%%QBITTORRENT_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%.7z" -sdel || exit /b 20
echo;

call "%%CONTOOLS_ROOT%%/std/rmdir.bat" "%%QBITTORRENT_ADAPTOR_BACKUP_DIR%%/%%QBITTORRENT_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /S /Q

exit /b 0
