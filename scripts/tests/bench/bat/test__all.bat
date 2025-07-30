@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

for %%i in ("%TESTS_PROJECT_ROOT%\test__*.bat") do (
  set "SCRIPT_FILE=%%i"
  call "%%CONTOOLS_ROOT%%/std/if_.bat" ^
    not "%%SCRIPT_FILE:*\%~nx0=%%" == "" if "%%SCRIPT_FILE:*\test___=%%" == "%%SCRIPT_FILE%%" ^
      && call "%%CONTOOLS_ROOT%%/std/call.bat" "%%SCRIPT_FILE%%"
)
