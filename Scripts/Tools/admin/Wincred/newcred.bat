@echo off

rem Example:
rem   newcred.bat git:https://github.com USER PASS Enterprise
rem   newcred.bat git:https://USER@github.com USER PASS LocalMachine

setlocal

call :IS_ADMIN_ELEVATED && goto MAIN

(
  echo.%~nx0: error: process must be elevated before continue.
  exit /b 255
) >&2

:IS_ADMIN_ELEVATED
if exist "%SystemRoot%\System32\whoami.exe" "%SystemRoot%\System32\whoami.exe" /groups | "%SystemRoot%\System32\find.exe" "S-1-16-12288" >nul 2>nul && exit /b
if exist "%SystemRoot%\System32\fltmc.exe" "%SystemRoot%\System32\fltmc.exe" >nul 2>nul && exit /b
if exist "%SystemRoot%\System64\openfiles.exe" "%SystemRoot%\System64\openfiles.exe" >nul 2>nul && exit /b
if exist "%SystemRoot%\System32\openfiles.exe" "%SystemRoot%\System32\openfiles.exe" >nul 2>nul && exit /b
if exist "%SystemRoot%\System32\config\system" exit /b 0
exit /b 255

:MAIN
where "powershell.exe" || (
  echo.%~nx0: error: `powershell.exe` is not found.
  exit /b 255
) >&2

set "TARGET=%~1"
set "USER=%~2"
set "PASS=%~3"
set "PERSIST=%~4"

powershell.exe -NoLogo -Command "& {New-StoredCredential -Target "'"%TARGET:'=''%"'" -UserName "'"%USER:'=''%"'" -Password "'"%PASS:'=''%"'" -Persist "'"%PERSIST:'=''%"'"}"
