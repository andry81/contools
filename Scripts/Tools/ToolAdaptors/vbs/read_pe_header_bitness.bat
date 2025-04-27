@echo off

setlocal

echo;^>cscript.exe //nologo "%~dpn0.vbs" %*
cscript.exe //nologo "%~dpn0.vbs" %*
