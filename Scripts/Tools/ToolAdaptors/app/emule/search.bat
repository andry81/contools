@echo off

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%~dp0__init__\__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/check_vars.bat" CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/init_project_log.bat" "%%?~n0%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/init_vars_file.bat" || exit /b

call "%%CONTOOLS_ROOT%%/exec/exec_callf_prefix.bat" -X /pause-on-exit -- %%* || exit /b

exit /b 0

:IMPL
rem CAUTION: We must to reinit the builtin variables in case if `IMPL_MODE` was already setup outside.
call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

rem load initialization environment variables
if defined INIT_VARS_FILE call "%%CONTOOLS_ROOT%%/std/set_vars_from_file.bat" "%%INIT_VARS_FILE%%"

rem call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

rem :FREE_TEMP_DIR
rem rem cleanup temporary files
rem call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LAST_ERROR%

:MAIN
set "SEARCH_LIST_FILE=%~1"
set "SEARCH_EXPR_SUFFIX=%~2"

if defined SEARCH_EXPR_SUFFIX set "SEARCH_EXPR_SUFFIX= %SEARCH_EXPR_SUFFIX%"

if not exist "%SEARCH_LIST_FILE%" (
  echo.%~nx0: error: SEARCH_LIST_FILE file path is not found: "%SEARCH_LIST_FILE%"
  exit /b 1
) >&2

set NUM_OVERALL_SEARCH_STR=0
for /F "usebackq eol=# tokens=* delims=" %%i in ("%SEARCH_LIST_FILE%") do (
  set "LINE_STR=%%i"
  call :COUNT
)

goto :COUNT_END

:COUNT
if not defined LINE_STR exit /b 0
if "%LINE_STR:~0,1%" == ":" exit /b 0

set /A NUM_OVERALL_SEARCH_STR+=1

exit /b 0

:COUNT_END

set NUM_SEARCH_STR=0
for /F "usebackq eol=# tokens=* delims=" %%i in ("%SEARCH_LIST_FILE%") do (
  set "EMULE_SEARCH_STR=%%i"
  call :RESCAN
)

exit /b 0

:RESCAN
if not defined EMULE_SEARCH_STR exit /b 0

set WAIT_TIMEOUT=0
if "%EMULE_SEARCH_STR:~0,1%" == ":" for /F "eol= tokens=1,* delims=:" %%i in ("%EMULE_SEARCH_STR%") do if "%%i" == "wait" set "WAIT_TIMEOUT=%%j"
if not defined WAIT_TIMEOUT set WAIT_TIMEOUT=0

if %WAIT_TIMEOUT% NEQ 0 (
  echo.waiting %WAIT_TIMEOUT% seconds...
  timeout /t %WAIT_TIMEOUT%
  exit /b 0
)

set /A NUM_SEARCH_STR+=1

set EMULE_CMDLINE="ed2k://|search|%EMULE_SEARCH_STR%%SEARCH_EXPR_SUFFIX%|/"

echo.%NUM_SEARCH_STR% of %NUM_OVERALL_SEARCH_STR%: ^>"%EMULE_EXECUTABLE%" %EMULE_CMDLINE%
"%EMULE_EXECUTABLE%" %EMULE_CMDLINE%
