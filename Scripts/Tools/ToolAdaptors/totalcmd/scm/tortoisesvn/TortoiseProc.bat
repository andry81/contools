@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || goto :EOF

rem builtin defaults
if not defined TORTOISEPROC_MAX_CALLS set TORTOISEPROC_MAX_CALLS=10

rem wait TrotoiseProc.exe to exit
set FLAG_WAIT_EXIT=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-wait" (
    set FLAG_WAIT_EXIT=1
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  )

  rem read until no flags
  goto FLAGS_LOOP
)

set "COMMAND=%~1"
set "PWD=%~2"
shift
shift

if not defined PWD goto NOPWD
( %PWD:~0,2% && cd "%PWD%" ) || exit /b 1

:NOPWD

rem run only first TORTOISEPROC_MAX_CALLS
set CALL_INDEX=0

rem run COMMAND over selected files/directories in the PWD directory
:CURDIR_LOOP
if %CALL_INDEX% GEQ %TORTOISEPROC_MAX_CALLS% exit /b 0

set "FILENAME=%~1"
if not defined FILENAME exit /b 0

rem reduce relative path to avoid . and .. characters
call "%%CONTOOLS_ROOT%%/reduce_relative_path.bat" "%%FILENAME%%"
set "FILENAME=%RETURN_VALUE%"

set "FILENAME_DECORATED=\%FILENAME%\"

rem cut off suffix with .svn subdirectory
if "%FILENAME_DECORATED:\.svn\=%" == "%FILENAME_DECORATED%" goto IGNORE_FILENAME_WCROOT_PATH_CUTOFF

set "FILENAME_WCROOT_SUFFIX=%FILENAME_DECORATED:*.svn\=%"

set "FILENAME_WCROOT_PREFIX=%FILENAME_DECORATED%"
if not defined FILENAME_WCROOT_SUFFIX goto CUTOFF_WCROOT_PREFIX

call set "FILENAME_WCROOT_PREFIX=%%FILENAME_DECORATED:\%FILENAME_WCROOT_SUFFIX%=%%"

:CUTOFF_WCROOT_PREFIX
rem remove bounds character and extract diretory path
if "%FILENAME_DECORATED:~-1%" == "\" set "FILENAME_DECORATED=%FILENAME_DECORATED:~0,-1%"
call "%%CONTOOLS_ROOT%%/split_pathstr.bat" "%%FILENAME_DECORATED:~1%%" \ "" FILENAME

rem should not be empty
if not defined FILENAME set FILENAME=.

:IGNORE_FILENAME_WCROOT_PATH_CUTOFF

if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" TortoiseProc.exe %%COMMAND%% /path:"%%FILENAME%%"
) else (
  call :CMD start /B "" TortoiseProc.exe %%COMMAND%% /path:"%%FILENAME%%"
)

set /A CALL_INDEX+=1

shift

goto CURDIR_LOOP

:CMD
echo.^>%*
(%*)
