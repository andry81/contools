@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal
echo;	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.
set "TAB=	"
set CMDLINE=cmd %TAB% %TAB% param0  %TAB%%TAB%  %TAB%%TAB%  param1 %TAB% %TAB%param2 %TAB%param3
set "CMDLINE_=%CMDLINE: =o%"
echo;%CMDLINE_%
call "%%CONTOOLS_ROOT%%/std/setshift_var.bat" 0 x CMDLINE -notrim
set x
call "%%CONTOOLS_ROOT%%/std/setshift_var.bat" 0 x x -notrim
set x
echo;	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.
endlocal
echo;---

setlocal
echo;	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.
set CMDLINE=0	1		2			3	 4	  5	 	6		 7	 8 		 9  	10
set "CMDLINE_=%CMDLINE: =o%"
echo;%CMDLINE_%
call "%%CONTOOLS_ROOT%%/std/setshift_var.bat" 0 x CMDLINE -notrim
set x
call "%%CONTOOLS_ROOT%%/std/setshift_var.bat" 0 x x -notrim
set x
echo;	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.
endlocal
echo;---

setlocal
set CMDLINE_VAR=0 	1 		2 			3 	 4 	  5 	 	6 		 7 	 8 		 9  	10
for /L %%i in (0,1,10) do call "%%CONTOOLS_ROOT%%/std/setshift_var.bat" %%i CMDLINE CMDLINE_VAR -notrim & call :TEST
endlocal
echo;---

rem repeat of the previous except the shift by 1 and set into the same variable
setlocal
set CMDLINE=0 	1 		2 			3 	 4 	  5 	 	6 		 7 	 8 		 9  	10
for /L %%i in (0,1,9) do call "%%CONTOOLS_ROOT%%/std/setshift_var.bat" 1 CMDLINE CMDLINE -notrim & call :TEST
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

call :PRINT_CMDLINE %%CMDLINE%%

echo;

exit /b 0

:PRINT_CMDLINE
setlocal
set CMDLINE==
for %%i in (%*) do setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!CMDLINE!") do endlocal & set "CMDLINE=%%j%%i="
echo;%CMDLINE%

echo;-%1-%2-%3-%4-%5-%6-%7-%8-%9-
