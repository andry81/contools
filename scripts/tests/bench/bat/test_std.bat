@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

for %%i in ("%TESTS_PROJECT_ROOT%\%~n0\%~n0__*.bat") do (
  set "SCRIPT_FILE=%%i"
  call "%%CONTOOLS_ROOT%%/std/call.bat" "%%SCRIPT_FILE%%"
)
