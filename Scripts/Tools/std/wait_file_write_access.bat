@echo off

setlocal

if "%~1" == "" exit /b 0
if exist "%~1\*" exit /b 0

if not "%~2" == "" if %~20 LSS 0 (
  if exist "%~1" ( move /Y "%~1" "%~1" >nul 2>nul & exit /b )
  exit /b 0
)

rem check file on write access
:LOOP
if exist "%~1" move /Y "%~1" "%~1" >nul 2>nul || ( call "%%~dp0sleep.bat" %2 & goto LOOP )
exit /b 0

rem Based on:
rem   https://stackoverflow.com/questions/1999988/how-to-check-whether-a-file-dir-is-writable-in-batch-scripts/59884789#59884789
rem
