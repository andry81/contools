@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

for %%i in ("%~dpn0\test__for__*.bat") do (
  set "SCRIPT_FILE=%%i"
  call "%%CONTOOLS_ROOT%%/std/call.bat" "%%SCRIPT_FILE%%"
)
