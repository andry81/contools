@echo off

setlocal

set "USER_NAME=%~1"
set "CWD=%~f2"

runas /user:%USER_NAME% "cmd.exe /K set \"CWD=%CWD%\\"&call cd /d \"%%CWD%%\"&title User: %%USERNAME%%"
