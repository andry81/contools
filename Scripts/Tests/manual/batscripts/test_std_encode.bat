@echo off

rem Create local variable's stack
setlocal

rem call "%%~dp0__init__/__init__.bat" || exit /b

for %%i in ("%~dp0test_std_encode__*.bat") do (
  set "SCRIPT_FILE=%%i"
  call "%%~dp0..\..\..\Tools\std\if_.bat" not "%%SCRIPT_FILE:*\test_std_encode.bat=%%" == "" && call "%%~dp0..\..\..\Tools\std\call.bat" "%%SCRIPT_FILE%%"
)
