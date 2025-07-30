@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal
for /L %%i in (1,1,1000) do call "%%~dp0..\..\..\..\tools\std\callshift.bat" -lockfile "%%~dp0.temp\test_std__callshift_with_lock\lock0" 0 echo;Exclusive wait lock print #%%i
endlocal
echo;---

echo;
