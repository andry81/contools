@echo off

for /F "usebackq eol= tokens=* delims=" %%i in (`@dir /A:L /B %* 2^>nul`) do echo.%%i
