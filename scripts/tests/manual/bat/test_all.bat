@echo off

setlocal

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

for %%i in ("%TESTS_PROJECT_ROOT%\test_*.bat") do (
  set "SCRIPT_FILE=%%i"
  call "%%CONTOOLS_ROOT%%/std/if_.bat" ^
    not "%%SCRIPT_FILE:*\%~nx0=%%" == "" if "%%SCRIPT_FILE:*\test__=%%" == "%%SCRIPT_FILE%%" ^
      && call "%%CONTOOLS_ROOT%%/std/call.bat" "%%SCRIPT_FILE%%"
)
