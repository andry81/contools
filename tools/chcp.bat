@echo off

rem Description:
rem   Script to call `System64\chcp.com` variant of the executable if
rem   `System32\chcp.com` is not found. Has meaning in Windows XP x64.

setlocal

if exist "%SystemRoot%\System32\chcp.com" "%SystemRoot%\System32\chcp.com" %* & exit /b
if exist "%SystemRoot%\System64\chcp.com" "%SystemRoot%\System64\chcp.com" %* & exit /b
if exist "%SystemRoot%\SysWOW64\chcp.com" "%SystemRoot%\SysWOW64\chcp.com" %* & exit /b

chcp.com %*
