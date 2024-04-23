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

call "%%~dp0__init__/script_init.bat" delete restapi %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

rem call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

rem :FREE_TEMP_DIR
rem rem cleanup temporary files
rem call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

set /A NEST_LVL-=1

exit /b %LAST_ERROR%

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

set "OWNER=%~1"
set "REPO=%~2"

if not defined OWNER (
  echo.%?~nx0%: error: OWNER is not defined.
  exit /b 255
) >&2

if not defined REPO (
  echo.%?~nx0%: error: REPO is not defined.
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
set LAST_ERROR=%ERRORLEVEL%

echo.

exit /b %LAST_ERROR%

:CURL
if defined GH_AUTH_USER if not "%GH_AUTH_USER%" == "{{USER}}" goto CURL_WITH_USER

(
  echo.%?~nx0%: error: GH_AUTH_USER is not set.
  exit /b 255
) >&2

exit /b

:CURL_WITH_USER
echo.^>%CURL_EXECUTABLE% %CURL_BARE_FLAGS% -X DELETE --user "%GH_AUTH_USER%:%GH_AUTH_PASS_TO_DELETE%" %*
(
  %CURL_EXECUTABLE% %CURL_BARE_FLAGS% -X DELETE --user "%GH_AUTH_USER%:%GH_AUTH_PASS_TO_DELETE%" %*
)
exit /b
