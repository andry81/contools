@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

if not exist "%~dp0.test_std__call_with_lock\.temp\*" mkdir "%~dp0.test_std__call_with_lock\.temp"

setlocal
for /L %%i in (1,1,1000) do call "%%~dp0..\..\..\..\tools\std\call.bat" -lockfile "%%~dp0.test_std__call_with_lock\.temp\lock0" echo;Exclusive wait lock print #%%i
endlocal
echo;---

echo;
