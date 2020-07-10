@echo off

setlocal

rem Photoshop x64
sc config "FLEXnet Licensing Service 64" start= demand

rem Photoshop x86
sc config "FLEXnet Licensing Service" start= demand
