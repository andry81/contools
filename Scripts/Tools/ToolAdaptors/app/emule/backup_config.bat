@echo off

setlocal

set "?~0=%~0"
set "?~f0=%~f0"
set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"
set "?~x0=%~x0"

call "%%~dp0__init__\__init__.bat" || exit /b

for %%i in (CONTOOLS_PROJECT_ROOT PROJECT_LOG_ROOT CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~nx0%%" || exit /b

"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" ^
  /ret-child-exit /pause-on-exit /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1 ^
  /v IMPL_MODE 1 /ra "%%" "%%?01%%" /v "?01" "%%" ^
  "${COMSPEC}" "/c \"@\"${?~f0}\" {*}\"" %* || exit /b

exit /b 0

:IMPL
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

call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           downloads.txt                 "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10

call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           clients.met                   "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           known.met                     "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           KnownPrefs.met                "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           server.met                    "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           emfriends.met                 "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           addresses.dat                 "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           cryptkey.dat                  "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           preferences.dat               "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10

rem Kademlia files
call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           key_index.dat                 "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           load_index.dat                "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           nodes.dat                     "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           preferencesKad.dat            "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           src_index.dat                 "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10

call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           preferences.ini               "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10
call :XCOPY_FILE "%%EMULE_CONFIG_DIR%%"           statistics.ini                "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10

echo.Archiving backup directory...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%EMULE_ADAPTOR_BACKUP_DIR%%" "emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%/*.*" "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%.7z" -sdel || exit /b 20
echo.

call :CMD rmdir /S /Q "%%EMULE_ADAPTOR_BACKUP_DIR%%/emule--%%PROJECT_LOG_FILE_NAME_SUFFIX%%"

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

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("%~2\.") do set "RETURN_VALUE=%%~fi"
rem set "RETURN_VALUE=%RETURN_VALUE:\=/%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0
