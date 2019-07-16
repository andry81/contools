@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || exit /b

rem script flags
set FLAG_PAUSE_ON_EXIT=0
set RESTORE_LOCALE=0

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%"

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:EXIT_MAIN
rem restore locale
if %RESTORE_LOCALE% NEQ 0 call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

if %FLAG_PAUSE_ON_EXIT% NEQ 0 pause

exit /b %LASTERROR%

:MAIN
rem script flags
set "FLAG_CHCP="
set FLAG_WAIT_EXIT=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-pause_on_exit" (
    set FLAG_PAUSE_ON_EXIT=1
  ) else if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else if "%FLAG%" == "-wait" (
    set FLAG_WAIT_EXIT=1
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "PWD=%~1"
shift

if not defined PWD goto NOPWD
cd /d "%PWD%" || exit /b 1

:NOPWD

set "FILES_LIST="
set NUM_FILES=0

set RANDOM_VALUE1=%RANDOM%_%RANDOM%
set RANDOM_VALUE2=%RANDOM%_%RANDOM%

set "FILE_IN_1=%~1"
set "FILE_IN_2=%~2"
set "FILE_OUT_1=%SCRIPT_TEMP_CURRENT_DIR%\%~n1.~%RANDOM_VALUE1%%~x1"
set "FILE_OUT_2=%SCRIPT_TEMP_CURRENT_DIR%\%~n2.~%RANDOM_VALUE2%%~x2"

if defined FLAG_CHCP (
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" "%FLAG_CHCP%"
  set RESTORE_LOCALE=1
)

rem read selected file names into variable
:CURDIR_FILTER_LOOP
if "%~1" == "" goto CURDIR_FILTER_LOOP_END
rem must be files, not sub directories
if exist "%~1\" exit /b 4

if %NUM_FILES% EQU 0 (
  set FILES_LIST="%SCRIPT_TEMP_CURRENT_DIR%\%~n1.~%RANDOM_VALUE1%%~x1"
) else if %NUM_FILES% EQU 1 (
  set FILES_LIST=%FILES_LIST% "%SCRIPT_TEMP_CURRENT_DIR%\%~n2.~%RANDOM_VALUE2%%~x2"
)

set /A NUM_FILES+=1

rem only 2 first files from the list is accepted
if %NUM_FILES% GTR 2 exit /b 2

shift

goto CURDIR_FILTER_LOOP

:CURDIR_FILTER_LOOP_END
if %NUM_FILES% NEQ 2 exit /b 2

if exist "%FILE_IN_1%" sort "%FILE_IN_1%" > "%FILE_OUT_1%"
if exist "%FILE_IN_2%" sort "%FILE_IN_2%" > "%FILE_OUT_2%"

if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" "%%CONSOLE_COMPARE_TOOL%%" /wait %%FILES_LIST%%
) else (
  call :CMD start /B "" "%%CONSOLE_COMPARE_TOOL%%" /nowait %%FILES_LIST%%
)

exit /b

:CMD
echo.^>%*
(%*)
