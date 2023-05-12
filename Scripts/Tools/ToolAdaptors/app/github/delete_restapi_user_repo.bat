@echo off

rem USAGE:
rem   delete_restapi_user_repo.bat [<Flags>] <OWNER> <REPO>

rem Description:
rem   Script to delete a repository using restapi.

rem <Flags>:
rem   --
rem     Stop flags parse.

rem <OWNER>:
rem   Owner name of a repository.
rem <REPO>:
rem   Repository name.

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

rem variables escaping
set "?~f0=%?~f0:{=\{%"
set "COMSPECLNK=%COMSPEC:{=\{%"

"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" ^
  /ret-child-exit /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1 ^
  /no-subst-pos-vars ^
  /v IMPL_MODE 1 /v INIT_VARS_FILE "%INIT_VARS_FILE%" ^
  /ra "%%" "%%?01%%" /v "?01" "%%" ^
  "${COMSPECLNK}" "/c \"@\"${?~f0}\" {*}\"" %*
set LASTERROR=%ERRORLEVEL%

if %NEST_LVL% EQU 0 (
  call "%%~dp0.impl/cleanup_log.bat"
  call "%%~dp0.impl/cleanup_init_vars.bat"

  if %LASTERROR% EQU 0 (
    rem copy log into backup directory
    call :XCOPY_DIR "%%PROJECT_LOG_DIR%%" "%%GH_ADAPTOR_BACKUP_DIR%%/bare/.log/%%PROJECT_LOG_DIR_NAME%%" /E /Y /D
  )
)

pause

exit /b %LASTERROR%

:IMPL

set /A NEST_LVL+=1

if %NEST_LVL% EQU 1 (
  rem load initialization environment variables
  if defined INIT_VARS_FILE call "%%CONTOOLS_ROOT%%/std/set_vars_from_file.bat" "%%INIT_VARS_FILE%%"
)

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

set /A NEST_LVL-=1

exit /b %LASTERROR%

:MAIN
rem script flags
set FLAG_CHECKOUT=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-checkout" (
    set FLAG_CHECKOUT=1
  ) else if "%FLAG%" == "--" (
    rem
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

set "OWNER=%~1"
set "REPO=%~2"

if not defined OWNER (
  echo.%?~n0%: error: OWNER is not defined.
  exit /b 255
) >&2

if not defined REPO (
  echo.%?~n0%: error: REPO is not defined.
  exit /b 255
) >&2

set "EMPTY_DIR_TMP=%SCRIPT_TEMP_CURRENT_DIR%\emptydir"

mkdir "%EMPTY_DIR_TMP%" || (
  echo.%?~n0%: error: could not create a directory: "%EMPTY_DIR_TMP%".
  exit /b 255
) >&2

set "GH_ADAPTOR_BACKUP_TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%\backup\restapi"

mkdir "%GH_ADAPTOR_BACKUP_TEMP_DIR%" || (
  echo.%?~n0%: error: could not create a directory: "%GH_ADAPTOR_BACKUP_TEMP_DIR%".
  exit /b 255
) >&2

set HAS_AUTH_USER=0

if defined GH_AUTH_USER if not "%GH_AUTH_USER%" == "{{USER}}" ^
if defined GH_AUTH_PASS_TO_DELETE if not "%GH_AUTH_PASS_TO_DELETE%" == "{{PASS-TO-DELETE}}" set HAS_AUTH_USER=1

if %HAS_AUTH_USER% EQU 0 (
  echo.%~nx0: error: GH_AUTH_USER or GH_AUTH_PASS_TO_DELETE is not defined.
  exit /b 255
) >&2

call set "GH_RESTAPI_DELETE_REPO_URL=%%GH_RESTAPI_DELETE_REPO_URL:{{OWNER}}=%OWNER%%%"
call set "GH_RESTAPI_DELETE_REPO_URL=%%GH_RESTAPI_DELETE_REPO_URL:{{REPO}}=%REPO%%%"

call :CURL "%%GH_RESTAPI_DELETE_REPO_URL%%"
set LASTERROR=%ERRORLEVEL%

echo.

exit /b %LASTERROR%

:CURL
if defined GH_AUTH_USER if not "%GH_AUTH_USER%" == "{{USER}}" goto CURL_WITH_USER

(
  echo.%?~n0%: error: GH_AUTH_USER is not set.
  exit /b 255
) >&2

exit /b

:CURL_WITH_USER
echo.^>%CURL_EXECUTABLE% %CURL_BARE_FLAGS% -X DELETE --user "%GH_AUTH_USER%:%GH_AUTH_PASS_TO_DELETE%" %*
(
  %CURL_EXECUTABLE% %CURL_BARE_FLAGS% -X DELETE --user "%GH_AUTH_USER%:%GH_AUTH_PASS_TO_DELETE%" %*
)
exit /b

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
