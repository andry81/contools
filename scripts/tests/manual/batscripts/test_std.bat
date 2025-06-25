@echo off

rem Create local variable's stack
setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

for %%i in ("%~dpn0\%~n0__*.bat") do (
  set "SCRIPT_NAME=%%~ni"
  set "SCRIPT_FILE=%%i"
  call "%%~dp0..\..\..\tools\std\if_.bat" ^
    "%%SCRIPT_NAME:!=%%" == "%%SCRIPT_NAME%%" ^
      && call "%%~dp0..\..\..\tools\std\call.bat" "%%SCRIPT_FILE%%"
)
