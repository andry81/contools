@echo off

setlocal

rem Epson Scanner Service
sc stop EpsonScanSvc
sc config EpsonScanSvc start= disabled
