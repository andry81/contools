@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal
set ARGS=echo "1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :CALL
endlocal
echo;---

setlocal
set ARGS=echo "1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :CALL -exe --
endlocal
echo;---

setlocal
set ARGS=echo $*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :CALL
endlocal
echo;---

setlocal
set ARGS=echo $*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :CALL -exe --
endlocal
echo;---

setlocal
rem instead of `echo.`, see "Different `echo?...` variants" : https://github.com/andry81/contools/discussions/22
set ARGS=echo:"1 2" 3 4 5
call :CALL
endlocal
echo;---

setlocal
rem has difference versus `echo:`, see "Different `echo?...` variants" : https://github.com/andry81/contools/discussions/22
set ARGS=echo;"1 2" 3 4 5
call :CALL
endlocal
echo;---

setlocal
rem does not work, see "Different `echo?...` variants" : https://github.com/andry81/contools/discussions/22
set ARGS=echo("1 2" 3 4 5
call :CALL
endlocal
echo;---

rem setlocal
rem set "ARGS=set | sort"
rem call :CALL .
rem endlocal
rem echo;---

setlocal
call "%%CONTOOLS_ROOT%%/std/errlvl.bat" 123
set "ARGS="
call :CALL
set ARGS=echo:
call :CALL
set ARGS=echo;
call :CALL
set ARGS=echo;
call :CALL -exe
set ARGS=echo 1 2 3
call :CALL
set ARGS=echo 1;2,3=
call :CALL
set ARGS=echo 1;2,3=
call :CALL -exe
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo;---

setlocal
set ARGS=exit /b 321
call :CALL
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo;---

setlocal
call "%%CONTOOLS_ROOT%%/std/errlvl.bat" 123
set ARGS="%CONTOOLS_ROOT%/std/errlvl.bat" 321
call :CALL
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo;---

setlocal
set "ARGS=echo;^>cmd param0 param1"
call :CALL
endlocal
echo;---

echo;


exit /b

:CALL
setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!ARGS!"') do endlocal & set "ECHO_ARGS=%%~i"
if defined ECHO_ARGS setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!ECHO_ARGS:%CONTOOLS_PROJECT_ROOT%=!") do endlocal & set "ECHO_ARGS=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!ECHO_ARGS!"') do endlocal & echo call.bat %* %%~i
call "%%CONTOOLS_ROOT%%/std/call.bat" %%* %%ARGS%%
