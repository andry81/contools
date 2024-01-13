@echo off

setlocal

rem Windows XP
"%SystemRoot%\System32\fsutil.exe" behavior query disable8dot3
"%SystemRoot%\System32\fsutil.exe" behavior set disable8dot3 0

rem Window 7+
"%SystemRoot%\System32\fsutil.exe" 8dot3name query
"%SystemRoot%\System32\fsutil.exe" 8dot3name set 0
