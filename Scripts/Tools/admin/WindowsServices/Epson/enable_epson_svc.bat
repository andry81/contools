@echo off

setlocal

rem Print Spooler Service
sc config Spooler start= demand

rem Epson Scanner Service
sc config EpsonScanSvc start= demand
