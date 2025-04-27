@echo off

setlocal

echo;	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.

set CMDLINE=%*
set "CMDLINE_=%CMDLINE: =o%"
echo;%CMDLINE_%
echo;%CMDLINE%

echo;	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.

set ARGS==
for %%i in (%*) do setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!ARGS!") do endlocal & set "ARGS=%%j%%i="
echo;%ARGS%

echo;-%1-%2-%3-%4-%5-%6-%7-%8-%9-

echo;
