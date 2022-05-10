@echo off

setlocal

rem Windows Update Service
sc config wuauserv start= demand
