@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal
set ARGS=echo "1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :CALLSHIFT 0
endlocal
echo;---

setlocal
set ARGS=echo "1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :CALLSHIFT -exe 0
endlocal
echo;---

setlocal
set ARGS=echo $*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :CALLSHIFT 0
endlocal
echo;---

setlocal
set ARGS=echo $*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :CALLSHIFT -exe 0
endlocal
echo;---

setlocal
rem instead of `echo.`, see "Different `echo?...` variants" : https://github.com/andry81/contools/discussions/22
set ARGS=echo:"1 2" 3 4 5
call :CALLSHIFT 2
endlocal
echo;---

setlocal
rem has difference versus `echo:`, see "Different `echo?...` variants" : https://github.com/andry81/contools/discussions/22
set ARGS=echo;"1 2" 3 4 5
call :CALLSHIFT 2
endlocal
echo;---

setlocal
rem does not work, see "Different `echo?...` variants" : https://github.com/andry81/contools/discussions/22
set ARGS=echo("1 2" 3 4 5
call :CALLSHIFT 2
endlocal
echo;---

rem setlocal
rem set "ARGS=set | sort"
rem call :CALLSHIFT .
rem endlocal
rem echo;---

setlocal
set "ARGS="
call "%%~dp0..\..\..\..\tools\std\errlvl.bat" 123
echo ERRORLEVEL=%ERRORLEVEL%
call :CALLSHIFT
echo ERRORLEVEL=%ERRORLEVEL%
set ARGS=echo:
call :CALLSHIFT 0
echo ERRORLEVEL=%ERRORLEVEL%
set ARGS=echo;
call :CALLSHIFT 0
echo ERRORLEVEL=%ERRORLEVEL%
set ARGS=echo;
call :CALLSHIFT -exe 0
echo ERRORLEVEL=%ERRORLEVEL%
set ARGS=echo 1 2 3
call :CALLSHIFT 0
echo ERRORLEVEL=%ERRORLEVEL%
set ARGS=echo 1;2,3=
call :CALLSHIFT 0
echo ERRORLEVEL=%ERRORLEVEL%
set ARGS=echo 1;2,3=
call :CALLSHIFT -exe 0
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo;---

setlocal
set ARGS=echo 1 2 3 4 5 6 7
call :CALLSHIFT 1
endlocal
echo;---

setlocal
set ARGS=echo 1 2 3 4 5 6 7
call :CALLSHIFT -num 3 1
endlocal
echo;---

setlocal
set ARGS=echo a b 1 2 3 4 5 6 7
call :CALLSHIFT -skip 2 -num 3 1
endlocal
echo;---

setlocal
set ARGS=echo 1 2 3 4 5 6 7
call :CALLSHIFT -3
endlocal
echo;---

setlocal
set ARGS=echo a b 1 2 3 4 5 6 7
call :CALLSHIFT -skip 2 -3
endlocal
echo;---

setlocal
set ARGS=echo a b 1 2 3 4 5 6 7 8
call :CALLSHIFT -skip 2 -num 4 -3
endlocal
echo;---

setlocal
call "%%~dp0..\..\..\..\tools\std\errlvl.bat" 123
echo ERRORLEVEL=%ERRORLEVEL%
set ARGS=exit /b 321
call :CALLSHIFT 0
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo;---

setlocal
call "%%~dp0..\..\..\..\tools\std\errlvl.bat" 123
echo ERRORLEVEL=%ERRORLEVEL%
set ARGS="%~dp0..\..\..\..\tools\std\errlvl.bat" 321
call :CALLSHIFT 0
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo;---

setlocal
set ARGS=echo  a  b  c  d
call :CALLSHIFT -notrim 1
endlocal
echo;---

setlocal
set "ARGS=echo;^>cmd param0 param1"
call :CALLSHIFT 0
endlocal
echo;---

echo;


exit /b

:CALLSHIFT
rem with ERRORLEVEL restore workaround
setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!ARGS!"') do endlocal & echo callshift.bat %* %%~i & call "%%~dp0..\..\..\..\tools\std\errlvl.bat" %ERRORLEVEL%
call "%%~dp0..\..\..\..\tools\std\callshift.bat" %%* %%ARGS%%
