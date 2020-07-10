@echo off

setlocal

sc config gupdate start= demand

sc config gupdatem start= demand
