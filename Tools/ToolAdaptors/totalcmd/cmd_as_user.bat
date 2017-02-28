@echo off

setlocal

set "USER_NAME=%~1"
set "PWD=%~dpf2"

runas /user:%USER_NAME% "cmd.exe /K set \"PWD=%PWD%\\"&call %%PWD:~0,2%%&call cd \"%%PWD%%\"&title User: %%USERNAME%%"
