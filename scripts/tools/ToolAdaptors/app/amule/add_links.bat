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
set "LINK_LIST_FILE=%~1"
set "LINK_SUFFIX=%~2"
set "ECPASS=%~3"

if defined LINK_SUFFIX set "LINK_SUFFIX=|%LINK_SUFFIX%"

if not exist "%LINK_LIST_FILE%" (
  echo;%?~%: error: LINK_LIST_FILE file path is not found: "%LINK_LIST_FILE%"
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
  set "AMULE_LINK_STR=%%i"
  call :ADD_LINK
)

exit /b 0

:ADD_LINK
if not defined AMULE_LINK_STR exit /b 0

set /A NUM_LINK_STR+=1

if defined ECPASS set AMULE_CMDLINE=/P "%ECPASS%"
set AMULE_CMDLINE=%AMULE_CMDLINE% /c "add %AMULE_LINK_STR%%LINK_SUFFIX%"

echo;%NUM_LINK_STR% of %NUM_OVERALL_LINK_STR%: ^>"%AMULE_CMD_EXECUTABLE%" %AMULE_CMDLINE%
"%AMULE_CMD_EXECUTABLE%" %AMULE_CMDLINE%
