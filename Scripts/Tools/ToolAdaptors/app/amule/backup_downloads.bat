@echo off

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%~dp0__init__\__init__.bat" || exit /b

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%* || exit /b

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/check_vars.bat" CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT || exit /b

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" || exit /b

call "%%CONTOOLS_ROOT%%/build/init_vars_file.bat" || exit /b

call "%%CONTOOLS_ROOT%%/exec/exec_callf_prefix.bat" -X /pause-on-exit -- %%* || exit /b

exit /b 0

:IMPL
rem CAUTION: We must to reinit the builtin variables in case if `IMPL_MODE` was already setup outside.
call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

rem load initialization environment variables
if defined INIT_VARS_FILE call "%%CONTOOLS_ROOT%%/std/set_vars_from_file.bat" "%%INIT_VARS_FILE%%"

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

set "AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX=amule--downloads-"

if defined ECPASS set AMULE_CMDLINE=/P "%ECPASS%"
set AMULE_CMDLINE=%AMULE_CMDLINE% -c "show dl"

if not exist "\\?\%AMULE_ADAPTOR_BACKUP_DIR%\%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%PROJECT_LOG_FILE_NAME_DATE_TIME%" mkdir "%AMULE_ADAPTOR_BACKUP_DIR%\%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%PROJECT_LOG_FILE_NAME_DATE_TIME%"

echo.^>"%AMULE_CMD_EXECUTABLE%" %AMULE_CMDLINE%

"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" ^
  /ret-child-exit /tee-stdout "%AMULE_ADAPTOR_BACKUP_DIR%/%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%PROJECT_LOG_FILE_NAME_DATE_TIME%/downloads.txt" /tee-stderr-dup 1 ^
  "${AMULE_CMD_EXECUTABLE}" "{*}" ${AMULE_CMDLINE} || exit /b

echo.Archiving backup directory...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%AMULE_ADAPTOR_BACKUP_DIR%%" "%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%/*" "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%.7z" -sdel || exit /b 20
echo.

call :CMD rmdir /S /Q "%%AMULE_ADAPTOR_BACKUP_DIR%%/%%AMULE_ADAPTOR_BACKUP_FILE_NAME_PREFIX%%%%PROJECT_LOG_FILE_NAME_DATE_TIME%%"

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
