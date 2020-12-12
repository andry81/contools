@echo off

setlocal

rem COM Server for VirtualBox API
sc stop VBoxSDS
sc config VBoxSDS start= disabled
