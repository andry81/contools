@echo off

setlocal

rem COM Server for VirtualBox API
sc config VBoxSDS start= demand
