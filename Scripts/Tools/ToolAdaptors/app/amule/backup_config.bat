@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%*

for %%i in (CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" || exit /b

set "INIT_VARS_FILE=%PROJECT_LOG_DIR%\init.vars"

rem register all environment variables
set 2>nul > "%INIT_VARS_FILE%"

"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" ^
  /ret-child-exit /pause-on-exit /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1 ^
  /v IMPL_MODE 1 /v INIT_VARS_FILE "%INIT_VARS_FILE%" ^
  /ra "%%" "%%?01%%" /v "?01" "%%" ^
  "${COMSPEC}" "/c \"@\"${?~f0}\" {*}\"" %* || exit /b

exit /b 0

:IMPL

rem load initialization environment variables
for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%INIT_VARS_FILE%") do set "%%i=%%j"

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || (
  echo.%?~nx0%: error: could not allocate temporary directory: "%SCRIPT_TEMP_CURRENT_DIR%"
  set LASTERROR=255
  goto FREE_TEMP_DIR
) >&2

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:FREE_TEMP_DIR
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LASTERROR%

:MAIN
set "EMPTY_DIR_TMP=%SCRIPT_TEMP_CURRENT_DIR%\emptydir"

mkdir "%EMPTY_DIR_TMP%" || (
  echo.%?~n0%: error: could not create a directory: "%EMPTY_DIR_TMP%".
  exit /b 255
) >&2

set "AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX=amule--config-"

call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           downloads.txt                 "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10

call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           amule.conf.bak                "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           server.met.bak                "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10

call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           amule.conf                    "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10

call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           addresses.dat                 "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           cryptkey.dat                  "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10

call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           ipfilter.dat                  "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           ipfilter_static.dat           "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10

call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           clients.met                   "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
if exist "%AMULE_CONFIG_DIR%\emfriends.met" (
  call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"         emfriends.met                 "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
)
call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           known.met                     "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
rem call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           known2_64.met                 "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           server.met                    "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
if exist "%AMULE_CONFIG_DIR%\staticservers.dat" (
  call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"         staticservers.dat             "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
)
call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           preferences.dat               "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10

rem Kademlia files
call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           key_index.dat                 "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           load_index.dat                "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           nodes.dat                     "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           preferencesKad.dat            "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           src_index.dat                 "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10

call :XCOPY_FILE "%%AMULE_CONFIG_DIR%%"           statistics.dat                "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10

echo.Archiving backup directory...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%AMULE_ADAPTOR_BACKUP_DIR%%" "%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%/*" "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%.7z" -sdel || exit /b 20
echo.

call :CMD rmdir /S /Q "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_SUFFIX%%"

exit /b 0

:CMD
echo.^>%*
(
  %*
)
exit /b

:XCOPY_FILE
if not exist "\\?\%~f3" (
  echo.^>mkdir "%~3"
  call :MAKE_DIR "%%~3" || (
    echo.%?~nx0%: error: could not create a target file directory: "%~3".
    exit /b 255
  ) >&2
  echo.
)
call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat" %%*
exit /b

:XCOPY_DIR
if not exist "\\?\%~f2" (
  echo.^>mkdir "%~2"
  call :MAKE_DIR "%%~2" || (
    echo.%?~nx0%: error: could not create a target directory: "%~2".
    exit /b 255
  ) >&2
  echo.
)
call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat" %%*
exit /b

:MAKE_DIR
for /F "eol= tokens=* delims=" %%i in ("%~1\.") do set "FILE_PATH=%%~fi"

mkdir "%FILE_PATH%" 2>nul || if exist "%SystemRoot%\System32\robocopy.exe" ( "%SystemRoot%\System32\robocopy.exe" /CREATE "%EMPTY_DIR_TMP%" "%FILE_PATH%" >nul ) else type 2>nul || (
  echo.%?~nx0%: error: could not create a target file directory: "%FILE_PATH%".
  exit /b 1
) >&2
exit /b