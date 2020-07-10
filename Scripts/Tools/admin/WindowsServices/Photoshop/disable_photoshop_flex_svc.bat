@echo off

setlocal

rem Photoshop x86
sc stop "FLEXnet Licensing Service"
sc config "FLEXnet Licensing Service" start= disabled

rem Photoshop x64
sc stop "FLEXnet Licensing Service 64"
sc config "FLEXnet Licensing Service 64" start= disabled
