@echo off

rem USAGE:
rem   exec_gui_emule.bat [-backup-all] [-backup-config] [-backup-logs] [-backup-part-met]

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
rem script flags
set FLAG_BACKUP_ALL=0
set FLAG_BACKUP_CONFIG=0
set FLAG_BACKUP_LOGS=0
set FLAG_BACKUP_PART_MET=0
set BACKUP=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-backup-all" (
    set FLAG_BACKUP_ALL=1
    set BACKUP=1
  ) else if "%FLAG%" == "-backup-config" (
    set FLAG_BACKUP_CONFIG=1
    set BACKUP=1
  ) else if "%FLAG%" == "-backup-logs" (
    set FLAG_BACKUP_LOGS=1
    set BACKUP=1
  ) else if "%FLAG%" == "-backup-part-met" (
    set FLAG_BACKUP_PART_MET=1
    set BACKUP=1
  )

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

if %FLAG_BACKUP_ALL% NEQ 0 (
  set FLAG_BACKUP_CONFIG=1
  set FLAG_BACKUP_LOGS=1
  set FLAG_BACKUP_PART_MET=1
)

rem backup all before start
if %FLAG_BACKUP_CONFIG% NEQ 0 call "%?~dp0%backup_config.bat" || exit /b
if %FLAG_BACKUP_LOGS% NEQ 0 call "%?~dp0%backup_logs.bat" || exit /b
if %FLAG_BACKUP_PART_MET% NEQ 0 call "%?~dp0%backup_part_met_files.bat" || exit /b

if %BACKUP% NEQ 0 echo;

echo;^>"%EMULE_EXECUTABLE%"
start "" "%EMULE_EXECUTABLE%"
