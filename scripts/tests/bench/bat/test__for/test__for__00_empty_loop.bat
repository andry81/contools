@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

for %%i in ("%~dpn0\test__for__*.bat") do (
  set "SCRIPT_FILE=%%i"
  call "%%SCRIPT_FILE%%"
)
