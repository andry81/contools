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
rem CAUTION:
rem   1. If a variable is empty, then it would not be expanded in the `cmd.exe`
rem      command line or in the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement.
rem   2. The `cmd.exe` command line or the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement does expand twice.
rem
rem   We must expand the command line into a variable to avoid these above.
rem
set ?.=@dir "%FLYLINKDC_SETTINGS_PATH%\*.sqlite" /A:-D /B /O:N 2^>nul

for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
  set "FILE_NAME=%%i"
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%FLYLINKDC_SETTINGS_PATH%%" "%%FILE_NAME%%"  "%%FLYLINK_ADAPTOR_BACKUP_DIR%%/flylink--%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10
)

echo;Archiving backup directory...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%FLYLINK_ADAPTOR_BACKUP_DIR%%" "flylink--%%PROJECT_LOG_FILE_NAME_DATE_TIME%%/*.*" "%%FLYLINK_ADAPTOR_BACKUP_DIR%%/flylink--%%PROJECT_LOG_FILE_NAME_DATE_TIME%%.7z" -sdel || exit /b 20
echo;

call "%%CONTOOLS_ROOT%%/std/rmdir.bat" "%%FLYLINK_ADAPTOR_BACKUP_DIR%%/flylink--%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /S /Q

exit /b 0
