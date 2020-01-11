@echo off

setlocal

rem VMware Authorization Service
sc stop VMAuthdService
sc config VMAuthdService start= disabled
