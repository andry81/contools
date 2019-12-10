@echo off

setlocal

rem Microsoft Office ClickToRun
sc stop ClickToRunSvc
sc config ClickToRunSvc start= disabled

rem Office Software Protection Platform
sc stop osppsvc
sc config osppsvc start= disabled
