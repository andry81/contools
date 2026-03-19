@echo off

setlocal

echo;^>cscript.exe //nologo "%~dpn0_winxp.vbs" %*
cscript.exe //nologo "%~dpn0_winxp.vbs" %*
