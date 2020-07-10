@echo off

setlocal

sc stop gupdate
sc config gupdate start= disabled

sc stop gupdatem
sc config gupdatem start= disabled
