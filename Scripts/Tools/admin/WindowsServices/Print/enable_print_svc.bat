@echo off

setlocal

rem Print Spooler Service
sc config Spooler start= demand
