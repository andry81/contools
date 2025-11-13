@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

for %%i in ("%TESTS_PROJECT_ROOT%\test__*.bat") do (
  set "SCRIPT_NAME=%%~ni"
  set "SCRIPT_FILE=%%i"
  call "%%CONTOOLS_ROOT%%/std/if_.bat" ^
    "%%SCRIPT_NAME:!=%%" == "%%SCRIPT_NAME%%" ^
    if not "%%SCRIPT_FILE:*\%~nx0=%%" == "" ^
    if "%%SCRIPT_FILE:*\test___=%%" == "%%SCRIPT_FILE%%" ^
      && call "%%CONTOOLS_ROOT%%/std/call.bat" "%%SCRIPT_FILE%%"
)
