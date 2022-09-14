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

rem variables escaping
set "?~f0=%?~f0:{=\{%"
set "COMSPECLNK=%COMSPEC:{=\{%"

"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" ^
  /ret-child-exit /pause-on-exit /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1 ^
  /no-subst-pos-vars ^
  /v IMPL_MODE 1 /v INIT_VARS_FILE "%INIT_VARS_FILE%" ^
  /ra "%%" "%%?01%%" /v "?01" "%%" ^
  "${COMSPECLNK}" "/c \"@\"${?~f0}\" {*}\"" %* || exit /b

exit /b 0

:IMPL

rem load initialization environment variables
if defined INIT_VARS_FILE for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%INIT_VARS_FILE%") do set "%%i=%%j"

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
set "QUERY_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\query.txt"

mkdir "%EMPTY_DIR_TMP%" || (
  echo.%?~n0%: error: could not create a directory: "%EMPTY_DIR_TMP%".
  exit /b 255
) >&2

set "GH_ADAPTOR_BACKUP_TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%\backup\restapi"

set "GH_REPOS_BACKUP_TEMP_DIR=%GH_ADAPTOR_BACKUP_TEMP_DIR%/releases/%OWNER%/%REPO%"
set "GH_REPOS_BACKUP_DIR=%GH_ADAPTOR_BACKUP_DIR%/restapi/releases/%OWNER%/%REPO%"

mkdir "%GH_REPOS_BACKUP_TEMP_DIR%" || (
  echo.%?~n0%: error: could not create a directory: "%GH_REPOS_BACKUP_TEMP_DIR%".
  exit /b 255
) >&2

set PAGE=1

:PAGE_LOOP
call set "GH_RESTAPI_REPO_RELEASES_URL_PATH=%%GH_RESTAPI_REPO_RELEASES_URL:{{OWNER}}=%OWNER%%%"
call set "GH_RESTAPI_REPO_RELEASES_URL_PATH=%%GH_RESTAPI_REPO_RELEASES_URL_PATH:{{REPO}}=%REPO%%%"

set "GH_RESTAPI_REPO_RELEASES_URL_PATH=%GH_RESTAPI_REPO_RELEASES_URL_PATH%?per_page=%GH_RESTAPI_PARAM_PER_PAGE%&page=%PAGE%"

set "CURL_OUTPUT_FILE=%GH_REPOS_BACKUP_TEMP_DIR%/%GH_RESTAPI_REPO_RELEASES_FILE%"

call set "CURL_OUTPUT_FILE=%%CURL_OUTPUT_FILE:{{PAGE}}=%PAGE%%%"

call :CURL "%%GH_RESTAPI_REPO_RELEASES_URL_PATH%%" || goto MAIN_EXIT
echo.

"%JQ_EXECUTABLE%" "length" "%CURL_OUTPUT_FILE%" 2>nul > "%QUERY_TEMP_FILE%"

set QUERY_LEN=0
for /F "usebackq eol= tokens=* delims=" %%i in ("%QUERY_TEMP_FILE%") do set QUERY_LEN=%%i

if not defined QUERY_LEN set QUERY_LEN=0
if "%QUERY_LEN%" == "null" set QUERY_LEN=0

rem just in case
if %PAGE% GEQ 100 (
  echo.%?~n0%: error: too many pages, skip processing.
  goto PAGE_LOOP_END
) >&2

if %QUERY_LEN% GEQ %GH_RESTAPI_PARAM_PER_PAGE% ( set /A "PAGE+=1" & goto PAGE_LOOP )

:PAGE_LOOP_END

if %PAGE% LSS 2 if %QUERY_LEN% EQU 0 (
  echo.%?~n0%: warning: query response is empty.
  goto SKIP_ARCHIVE
) >&2

echo.Archiving backup directory...
if not exist "%GH_REPOS_BACKUP_DIR%\" mkdir "%GH_REPOS_BACKUP_DIR%"
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%GH_ADAPTOR_BACKUP_TEMP_DIR%%" "*" "%%GH_REPOS_BACKUP_DIR%%/releases--[%%OWNER%%][%%REPO%%]--%%PROJECT_LOG_FILE_NAME_SUFFIX%%.7z" -sdel || exit /b 20
echo.

:SKIP_ARCHIVE

:MAIN_EXIT
set LASTERROR=%ERRORLEVEL%

echo.

exit /b %LASTERROR%

:CURL
if defined GH_AUTH_USER if not "%GH_AUTH_USER%" == "{{USER}}" goto CURL_WITH_USER

echo.^>%CURL_EXECUTABLE% %CURL_BARE_FLAGS% %*
(
  %CURL_EXECUTABLE% %CURL_BARE_FLAGS% %*
) > "%CURL_OUTPUT_FILE%"
exit /b

:CURL_WITH_USER
echo.^>%CURL_EXECUTABLE% %CURL_BARE_FLAGS% --user "%GH_AUTH_USER%:%GH_AUTH_PASS%" %*
(
  %CURL_EXECUTABLE% %CURL_BARE_FLAGS% --user "%GH_AUTH_USER%:%GH_AUTH_PASS%" %*
) > "%CURL_OUTPUT_FILE%"
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
