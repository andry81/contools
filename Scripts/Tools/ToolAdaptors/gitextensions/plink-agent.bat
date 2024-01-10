@echo off

setlocal

echo.ssh agent command line: %*>&2

start "" /B /WAIT "%~dp0plink.exe" -agent %*
