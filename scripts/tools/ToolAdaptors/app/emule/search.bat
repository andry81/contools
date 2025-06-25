@echo off

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
set "SEARCH_LIST_FILE=%~1"
set "SEARCH_EXPR_SUFFIX=%~2"

if defined SEARCH_EXPR_SUFFIX set "SEARCH_EXPR_SUFFIX= %SEARCH_EXPR_SUFFIX%"

if not exist "%SEARCH_LIST_FILE%" (
  echo;%?~%: error: SEARCH_LIST_FILE file path is not found: "%SEARCH_LIST_FILE%"
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
if "%EMULE_SEARCH_STR:~0,1%" == ":" for /F "tokens=1,* delims=:"eol^= %%i in ("%EMULE_SEARCH_STR%") do if "%%i" == "wait" set "WAIT_TIMEOUT=%%j"
if not defined WAIT_TIMEOUT set WAIT_TIMEOUT=0

if %WAIT_TIMEOUT% NEQ 0 (
  echo;waiting %WAIT_TIMEOUT% seconds...
  timeout /t %WAIT_TIMEOUT%
  exit /b 0
)

set /A NUM_SEARCH_STR+=1

set EMULE_CMDLINE="ed2k://|search|%EMULE_SEARCH_STR%%SEARCH_EXPR_SUFFIX%|/"

echo;%NUM_SEARCH_STR% of %NUM_OVERALL_SEARCH_STR%: ^>"%EMULE_EXECUTABLE%" %EMULE_CMDLINE%
"%EMULE_EXECUTABLE%" %EMULE_CMDLINE%
