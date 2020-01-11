@echo off

setlocal

rem VMware Authorization Service
sc config VMAuthdService start= demand
