@echo off

rem USAGE:
rem   print_source_repos_from_restapi_json.bat.bat [<Flags>] <JSON_FILE>

rem Description:
rem   Script prints source only repositories from the json file.

rem <Flags>:
rem   --
rem     Stop flags parse.
rem   -skip-sort
rem     Skip repositories list alphabetic sort and print as is from the json
rem     file.
rem   -no-url-domain-remove
rem     Don't remove url domain from the output.

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%~dp0__init__\__init__.bat" || exit /b

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%* || exit /b

for %%i in (CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" >&2 || exit /b

call "%%CONTOOLS_ROOT%%/build/init_vars_file.bat" || exit /b

call "%%CONTOOLS_ROOT%%/exec/exec_callf_prefix.bat" -- %%*
set LASTERROR=%ERRORLEVEL%

pause >&2

exit /b %LASTERROR%

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
rem script flags
set FLAG_SKIP_SORT=0
set FLAG_NO_URL_DOMAIN_REMOVE=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-skip-sort" (
    set FLAG_SKIP_SORT=1
  ) else if "%FLAG%" == "-no-url-domain-remove" (
    set FLAG_NO_URL_DOMAIN_REMOVE=1
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

set "INOUT_LIST_FILE_TMP0=%SCRIPT_TEMP_CURRENT_DIR%\inout0.lst"
set "INOUT_LIST_FILE_TMP1=%SCRIPT_TEMP_CURRENT_DIR%\inout1.lst"
set "INOUT_LIST_FILE_TMP2=%SCRIPT_TEMP_CURRENT_DIR%\inout2.lst"

set "JSON_FILE=%~1"

if not defined JSON_FILE (
  echo.%?~n0%: error: JSON_FILE is not defined.
  exit /b 255
) >&2

if not exist "%JSON_FILE%" (
  echo.%?~n0%: error: JSON_FILE is not found: "%JSON_FILE%".
  exit /b 255
) >&2

if %FLAG_SKIP_SORT% EQU 0 goto SORT_LIST

"%JQ_EXECUTABLE%" -c -r ".[] | select(.fork == false).html_url" "%JSON_FILE%"
exit /b

:SORT_LIST
"%JQ_EXECUTABLE%" -c -r ".[] | select(.fork == false).html_url" "%JSON_FILE%" > "%INOUT_LIST_FILE_TMP0%"
set LASTERROR=%ERRORLEVEL%

sort "%INOUT_LIST_FILE_TMP0%" /O "%INOUT_LIST_FILE_TMP1%"

if %FLAG_NO_URL_DOMAIN_REMOVE% NEQ 0 goto NO_URL_DOMAIN_REMOVE

for /F "usebackq eol= tokens=* delims=" %%i in ("%INOUT_LIST_FILE_TMP1%") do (
  set "URL=%%i"
  call :PROCESS_URL
) >> "%INOUT_LIST_FILE_TMP2%"

type "%INOUT_LIST_FILE_TMP2%"

exit /b %LASTERROR%

:PROCESS_URL
set "URL=%URL:https:/=%"
set "URL=%URL:/github.com/=%"
echo.%URL%
exit /b

:NO_URL_DOMAIN_REMOVE
type "%INOUT_LIST_FILE_TMP1%"

exit /b %LASTERROR%

:CMD
echo.^>%*
(
  %*
)
exit /b
