@echo off

setlocal

echo.^>cscript.exe //nologo "%~dpn0.js" %*
cscript.exe //nologo "%~dpn0.js" %*
