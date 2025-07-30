@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal
echo;	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.
set "TAB=	"
set ARGS=cmd %TAB% %TAB% param0  %TAB%%TAB%  %TAB%%TAB%  param1 %TAB% %TAB%param2 %TAB%param3
set "ARGS_=%ARGS: =o%"
echo;%ARGS_%
call "%%~dp0..\..\..\..\tools\std\setshift.bat" -notrim 0 x %%ARGS%%
set x
echo;	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.
endlocal
echo;---

setlocal
echo;	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.
set ARGS=0	1		2			3	 4	  5	 	6		 7	 8 		 9  	10
set "ARGS_=%ARGS: =o%"
echo;%ARGS_%
call "%%~dp0..\..\..\..\tools\std\setshift.bat" -notrim 0 x %%ARGS%%
set x
echo;	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.
endlocal
echo;---

setlocal
set ARGS=0 	1 		2 			3 	 4 	  5 	 	6 		 7 	 8 		 9  	10
for /L %%i in (0,1,10) do call "%%~dp0..\..\..\..\tools\std\setshift.bat" -notrim %%i CMDLINE %%ARGS%% & call :TEST
endlocal
echo;---

echo;

exit /b 0

:TEST
setlocal

echo;	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.

set "CMDLINE_=%CMDLINE: =o%"
echo;%CMDLINE_%
echo;%CMDLINE%

echo;	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.

call :PRINT_ARGS %%CMDLINE%%

echo;

exit /b 0

:PRINT_ARGS
setlocal
set ARGS==
for %%i in (%*) do setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!ARGS!") do endlocal & set "ARGS=%%j%%i="
echo;%ARGS%

echo;-%1-%2-%3-%4-%5-%6-%7-%8-%9-
