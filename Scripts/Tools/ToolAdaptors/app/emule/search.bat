@echo off

setlocal

set "?~0=%~0"
set "?~f0=%~f0"
set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"
set "?~x0=%~x0"

call "%%~dp0__init__\__init__.bat" || exit /b

for %%i in (CONTOOLS_PROJECT_ROOT PROJECT_LOG_ROOT CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

if %IMPL_MODE%0 NEQ 0 goto IMPL

rem use stdout/stderr redirection with logging
call "%%CONTOOLS_ROOT%%\wmi\get_wmic_local_datetime.bat"
set "PROJECT_LOG_FILE_NAME_SUFFIX=%RETURN_VALUE:~0,4%'%RETURN_VALUE:~4,2%'%RETURN_VALUE:~6,2%_%RETURN_VALUE:~8,2%'%RETURN_VALUE:~10,2%'%RETURN_VALUE:~12,2%''%RETURN_VALUE:~15,3%"

set "PROJECT_LOG_DIR=%PROJECT_LOG_ROOT%\%PROJECT_LOG_FILE_NAME_SUFFIX%.%?~n0%"
set "PROJECT_LOG_FILE=%PROJECT_LOG_DIR%\%PROJECT_LOG_FILE_NAME_SUFFIX%.%?~n0%.log"

if not exist "%PROJECT_LOG_DIR%" ( mkdir "%PROJECT_LOG_DIR%" || exit /b )

set ?__CMDLINE__=%*
"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" ^
  /ret-child-exit /pause-on-exit /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1 ^
  /v IMPL_MODE 1 /ra "%%" "%%?01%%" /v "?01" "%%" ^
  /E0 /S1 /E2 /E3 ^
  "${COMSPEC}" "/c \"@\"{0}\" {1}\"" "${?~f0}" "${?__CMDLINE__}"
exit /b

:IMPL
rem call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || (
rem   echo.%?~nx0%: error: could not allocate temporary directory: "%SCRIPT_TEMP_CURRENT_DIR%"
rem   set LASTERROR=255
rem   goto FREE_TEMP_DIR
rem ) >&2

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

rem :FREE_TEMP_DIR
rem rem cleanup temporary files
rem call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LASTERROR%

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
