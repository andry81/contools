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

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" || exit /b

"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" ^
  /ret-child-exit /pause-on-exit /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1 ^
  /v IMPL_MODE 1 /ra "%%" "%%?01%%" /v "?01" "%%" ^
  "${COMSPEC}" "/c \"@\"${?~f0}\" {*}\"" %* || exit /b

exit /b 0

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
set "LINK_LIST_FILE=%~1"
set "LINK_SUFFIX=%~2"

if defined LINK_SUFFIX set "LINK_SUFFIX=|%LINK_SUFFIX%"

if not exist "%LINK_LIST_FILE%" (
  echo.%~nx0: error: LINK_LIST_FILE file path is not found: "%LINK_LIST_FILE%"
  exit /b 1
) >&2

set NUM_OVERALL_LINK_STR=0
for /F "usebackq eol=# tokens=* delims=" %%i in ("%LINK_LIST_FILE%") do (
  set "LINE_STR=%%i"
  call :COUNT
)

goto :COUNT_END

:COUNT
if not defined LINE_STR exit /b 0
if "%LINE_STR:~0,1%" == ":" exit /b 0

set /A NUM_OVERALL_LINK_STR+=1

exit /b 0

:COUNT_END

set NUM_LINK_STR=0
for /F "usebackq eol=# tokens=* delims=" %%i in ("%LINK_LIST_FILE%") do (
  set "EMULE_LINK_STR=%%i"
  call :ADD_LINK
)

exit /b 0

:ADD_LINK
if not defined EMULE_LINK_STR exit /b 0

set /A NUM_LINK_STR+=1

set EMULE_CMDLINE="%EMULE_LINK_STR%%LINK_SUFFIX%"

echo.%NUM_LINK_STR% of %NUM_OVERALL_LINK_STR%: ^>"%EMULE_EXECUTABLE%" %EMULE_CMDLINE%
"%EMULE_EXECUTABLE%" %EMULE_CMDLINE%
