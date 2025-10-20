@echo off

setlocal

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

for %%i in ("%~dp0test_*.bat") do (
  set "SCRIPT_FILE=%%i"
  call "%%~dp0..\..\..\tools\std\if_.bat" ^
    not "%%SCRIPT_FILE:*\%~nx0=%%" == "" if "%%SCRIPT_FILE:*\test__=%%" == "%%SCRIPT_FILE%%" ^
      && call "%%~dp0..\..\..\tools\std\call.bat" "%%SCRIPT_FILE%%"
)
