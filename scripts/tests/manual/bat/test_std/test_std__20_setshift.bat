@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal
set ARGS="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :SETSHIFT 0 x
set x
endlocal
echo;---

setlocal
set ARGS="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :SETSHIFT -exe 0 x
set x
endlocal
echo;---

setlocal
set ARGS=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :SETSHIFT 0 x
set x
endlocal
echo;---

setlocal
set ARGS=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :SETSHIFT -exe 0 x
set x
endlocal
echo;---

setlocal
set ARGS="1 2" 3 4 5
call :SETSHIFT 2 x
set x
endlocal
echo;---

setlocal
call "%%~dp0..\..\..\..\tools\std\errlvl.bat" 123
set "ARGS="
call :SETSHIFT
call :SETSHIFT 0 x
set ARGS=1 2 3
call :SETSHIFT 0 x
echo ERRORLEVEL=%ERRORLEVEL%
set x
endlocal
echo;---

setlocal
set ARGS=1 2 3 4 5 6 7
call :SETSHIFT -3 x
set x
endlocal
echo;---

setlocal
set ARGS=a b 1 2 3 4 5 6 7
call :SETSHIFT -skip 2 -3 x
set x
endlocal
echo;---

setlocal
set ARGS= a  b  c  d
call :SETSHIFT -notrim 1 x
set x
endlocal
echo;---

setlocal
set "ARGS=^>cmd param0 param1"
call :SETSHIFT 0 x
set x
endlocal
echo;---

echo;

exit /b

:SETSHIFT
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!ARGS!") do endlocal & echo setshift.bat %* %%i
call "%%~dp0..\..\..\..\tools\std\setshift.bat" %%* %%ARGS%%
