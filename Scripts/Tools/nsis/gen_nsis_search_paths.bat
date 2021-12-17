@echo off

setlocal

rem drop last error level
call;

set "SEARCH_PATH_LIST_FILE=%~1"

if not exist "%SEARCH_PATH_LIST_FILE%" (
  echo.%~nx0: error: SEARCH_PATH_LIST_FILE does not exist: "%SEARCH_PATH_LIST_FILE%"
  exit /b 1
) >&2

set "PREV_COMMAND="

rem generate nsis_search_paths.nsi
for /F "eol=# usebackq tokens=1,2 delims=|" %%i in ("%SEARCH_PATH_LIST_FILE%") do ( call :PROCESS_LINE "%%i" "%%j" || exit /b )
(
  endlocal
  rem return updated PATH variable
  set "PATH=%PATH%"
)
exit /b 0

:PROCESS_LINE
set "COMMAND=%~1"
set "VALUE=%~2"

if not "%COMMAND%" == "systemdir" goto GEN_OUTPUT

set "VALUE=%VALUE:{{=!%"
set "VALUE=%VALUE:}}=!%"

rem expand value
setlocal ENABLEDELAYEDEXPANSION
set "VALUE=%VALUE%"
(
  endlocal
  rem return expanded value
  set "VALUE=%VALUE:/=\%"
)

rem update PATH
set "PATH=%PATH%;%VALUE%"

exit /b

:GEN_OUTPUT
if defined PREV_COMMAND if not "%PREV_COMMAND%" == "%COMMAND%" echo.

set "PREV_COMMAND=%COMMAND%"

if "%COMMAND%" == "includedir" (
  echo.!add%COMMAND% "%VALUE%"
  exit /b
)
if "%COMMAND%" == "plugindir" (
  echo.!add%COMMAND% "%VALUE%"
  exit /b
)

echo.!%COMMAND% "%VALUE%"
exit /b
