@echo off

setlocal

echo.ssh agent command line: %*>&2

start "" /WAIT /B "%~dp0plink.exe" -agent %*
