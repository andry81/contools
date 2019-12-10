@echo off

setlocal

rem Office Software Protection Platform
sc config osppsvc start= demand

rem Microsoft Office ClickToRun
sc config ClickToRunSvc start= demand
