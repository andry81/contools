@echo off

rem USAGE:
rem   backup_restapi_org_repos_list.bat [<Flags>] <ORG> <TYPE>

rem Description:
rem   Script to request restapi response of repository list from a user
rem   organization account.

rem <Flags>:
rem   --
rem     Stop flags parse.

rem <ORG>:
rem   User organization name.
rem <TYPE>:
rem   Type of user repository request:
rem   - sources
rem   - all

setlocal

call "%%~dp0__init__/script_init.bat" backup restapi %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

:FREE_TEMP_DIR
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

set /A NEST_LVL-=1

exit /b %LAST_ERROR%

:MAIN
rem script flags

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "--" (
    shift
    set "FLAG="
    goto FLAGS_LOOP_END
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

:FLAGS_LOOP_END

set "ORG=%~1"
set "TYPE=%~2"

if not defined ORG (
  echo.%?~nx0%: error: ORG is not defined.
  exit /b 255
) >&2

if not defined TYPE (
  echo.%?~nx0%: error: TYPE is not defined.
  exit /b 255
) >&2

set "QUERY_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\query.txt"

set "GH_ADAPTOR_BACKUP_TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%\backup\restapi"

set "GH_REPOS_BACKUP_TEMP_DIR=%GH_ADAPTOR_BACKUP_TEMP_DIR%/repos/org/%ORG%"
set "GH_REPOS_BACKUP_DIR=%GH_ADAPTOR_BACKUP_DIR%/restapi/repos/org/%ORG%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir.bat" "%%GH_REPOS_BACKUP_TEMP_DIR%%" >nul || exit /b 255

if defined GH_RESTAPI_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GH_RESTAPI_BACKUP_USE_TIMEOUT_MS%%"

set PAGE=1

:PAGE_LOOP
call set "GH_RESTAPI_ORG_REPOS_URL_PATH=%%GH_RESTAPI_ORG_REPOS_URL:{{ORG}}=%ORG%%%"

set "GH_RESTAPI_ORG_REPOS_URL_PATH=%GH_RESTAPI_ORG_REPOS_URL_PATH%?type=%TYPE%&per_page=%GH_RESTAPI_PARAM_PER_PAGE%&page=%PAGE%"

set "CURL_OUTPUT_FILE=%GH_REPOS_BACKUP_TEMP_DIR%/%GH_RESTAPI_ORG_REPOS_FILE%"

call set "CURL_OUTPUT_FILE=%%CURL_OUTPUT_FILE:{{TYPE}}=%TYPE%%%"
call set "CURL_OUTPUT_FILE=%%CURL_OUTPUT_FILE:{{PAGE}}=%PAGE%%%"

call :CURL "%%GH_RESTAPI_ORG_REPOS_URL_PATH%%" || goto MAIN_EXIT
echo.

"%JQ_EXECUTABLE%" "length" "%CURL_OUTPUT_FILE%" 2>nul > "%QUERY_TEMP_FILE%"

set QUERY_LEN=0
for /F "usebackq eol= tokens=* delims=" %%i in ("%QUERY_TEMP_FILE%") do set QUERY_LEN=%%i

if not defined QUERY_LEN set QUERY_LEN=0
if "%QUERY_LEN%" == "null" set QUERY_LEN=0

rem just in case
if %PAGE% GEQ 100 (
  echo.%?~nx0%: error: too many pages, skip processing.
  goto PAGE_LOOP_END
) >&2

if %QUERY_LEN% GEQ %GH_RESTAPI_PARAM_PER_PAGE% ( set /A "PAGE+=1" & goto PAGE_LOOP )

:PAGE_LOOP_END

if %PAGE% LSS 2 if %QUERY_LEN% EQU 0 (
  echo.%?~nx0%: warning: query response is empty.
  goto SKIP_ARCHIVE
) >&2

echo.Archiving backup directory...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%GH_REPOS_BACKUP_DIR%%" && ^
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%GH_ADAPTOR_BACKUP_TEMP_DIR%%" "*" "%%GH_REPOS_BACKUP_DIR%%/org-repos--[%%ORG%%][%%TYPE%%]--%%PROJECT_LOG_FILE_NAME_DATE_TIME%%.7z" -sdel || exit /b 20
echo.

:SKIP_ARCHIVE

:MAIN_EXIT
set LAST_ERROR=%ERRORLEVEL%

echo.

exit /b %LAST_ERROR%

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
