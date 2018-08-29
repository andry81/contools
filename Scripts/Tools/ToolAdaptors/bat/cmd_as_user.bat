@echo off

setlocal

set "USER_NAME=%~1"
set "PWD=%~dpf2"

runas /user:%USER_NAME% "cmd.exe /K set \"PWD=%PWD%\\"&call cd /d \"%%PWD%%\"&title User: %%USERNAME%%"
