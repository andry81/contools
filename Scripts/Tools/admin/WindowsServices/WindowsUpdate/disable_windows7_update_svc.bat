@echo off

setlocal

rem Windows Update Service
sc stop wuauserv
sc config wuauserv start= disabled
