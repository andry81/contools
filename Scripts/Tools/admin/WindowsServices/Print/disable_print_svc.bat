@echo off

setlocal

rem Print Spooler Service
sc stop Spooler
sc config Spooler start= disabled
