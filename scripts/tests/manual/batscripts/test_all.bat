@echo off

rem Create local variable's stack
setlocal

rem call "%%~dp0__init__/__init__.bat" || exit /b

for %%i in ("%~dp0test_*.bat") do (
  set "SCRIPT_FILE=%%i"
  call "%%~dp0..\..\..\tools\std\if_.bat" ^
    not "%%SCRIPT_FILE:*\%~nx0=%%" == "" if "%%SCRIPT_FILE:*\test__=%%" == "%%SCRIPT_FILE%%" ^
      && call "%%~dp0..\..\..\tools\std\call.bat" "%%SCRIPT_FILE%%"
)
