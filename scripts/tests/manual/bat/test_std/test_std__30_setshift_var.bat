@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal
set CMDLINE="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :SETSHIFT_VAR 0 x CMDLINE
set x
endlocal
echo;---

setlocal
set CMDLINE="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :SETSHIFT_VAR 0 x CMDLINE -exe
set x
endlocal
echo;---

setlocal
set CMDLINE=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :SETSHIFT_VAR 0 x CMDLINE
set x
endlocal
echo;---

setlocal
set CMDLINE=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :SETSHIFT_VAR 0 x CMDLINE -exe
set x
endlocal
echo;---

setlocal
set CMDLINE="1 2" 3 4 5
call :SETSHIFT_VAR 2 x CMDLINE
set x
endlocal
echo;---

setlocal
set "CMDLINE="
set "x=" & set "y="
set x
call "%%CONTOOLS_ROOT%%/std/errlvl.bat" 123
echo ERRORLEVEL=%ERRORLEVEL%
call :SETSHIFT_VAR
echo ERRORLEVEL=%ERRORLEVEL%
call :SETSHIFT_VAR 0 x
echo ERRORLEVEL=%ERRORLEVEL%
call :SETSHIFT_VAR 0 y CMDLINE
echo ERRORLEVEL=%ERRORLEVEL%
rem with ERRORLEVEL restore workaround
set x & set y & call "%%CONTOOLS_ROOT%%/std/errlvl.bat" %ERRORLEVEL%
set CMDLINE=1 2 3
call :SETSHIFT_VAR 0 x
echo ERRORLEVEL=%ERRORLEVEL%
call :SETSHIFT_VAR 0 y CMDLINE
echo ERRORLEVEL=%ERRORLEVEL%
rem with ERRORLEVEL restore workaround
set x & set y & call "%%CONTOOLS_ROOT%%/std/errlvl.bat" %ERRORLEVEL%
set CMDLINE=1;2,3=
call :SETSHIFT_VAR 0 x
echo ERRORLEVEL=%ERRORLEVEL%
call :SETSHIFT_VAR 0 y CMDLINE
echo ERRORLEVEL=%ERRORLEVEL%
set x & set y
endlocal
echo;---

setlocal
set CMDLINE=1 2 3 4 5 6 7
call :SETSHIFT_VAR -0 x CMDLINE
set x
endlocal
echo;---

setlocal
set CMDLINE=1 2 3 4 5 6 7
call :SETSHIFT_VAR +0 x CMDLINE
set x
endlocal
echo;---

setlocal
set CMDLINE=1 2 3 4 5 6 7
call :SETSHIFT_VAR 1 x CMDLINE
set x
endlocal
echo;---

setlocal
set CMDLINE=1 2 3 4 5 6 7
call :SETSHIFT_VAR 1 x CMDLINE -num 3
set x
endlocal
echo;---

setlocal
set CMDLINE=1 2 3 4 5 6 7
call :SETSHIFT_VAR 1 x CMDLINE -skip 2 -num 3
set x
endlocal
echo;---

setlocal
set CMDLINE=1 2 3 4 5 6 7
call :SETSHIFT_VAR -3 x CMDLINE
set x
endlocal
echo;---

setlocal
set CMDLINE=a b 1 2 3 4 5 6 7
call :SETSHIFT_VAR -3 x CMDLINE -skip 2
set x
endlocal
echo;---

setlocal
set CMDLINE=a b 1 2 3 4 5 6 7 8
call :SETSHIFT_VAR -3 x CMDLINE -skip 2 -num 4
set x
endlocal
echo;---

setlocal
set CMDLINE= a  b  c  d
call :SETSHIFT_VAR 1 x CMDLINE -notrim
set x
endlocal
echo;---

setlocal
set "CMDLINE=^>cmd param0 param1"
call :SETSHIFT_VAR 0 x CMDLINE
set x
endlocal
echo;---

echo;

exit /b

:SETSHIFT_VAR
rem with ERRORLEVEL restore workaround
    ( setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!CMDLINE!"') do endlocal & set "ECHO_CMDLINE=%%~i" ) ^
  & ( if defined ECHO_CMDLINE setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!ECHO_CMDLINE:%CONTOOLS_PROJECT_ROOT%=!") do endlocal & set "ECHO_CMDLINE=%%i" ) ^
  & ( setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!ECHO_CMDLINE!"') do endlocal & (echo;CMDLINE=%%~i) & echo setshift_var.bat %* & call "%%CONTOOLS_ROOT%%/std/errlvl.bat" %ERRORLEVEL% )
call "%%CONTOOLS_ROOT%%/std/setshift_var.bat" %%* %%CMDLINE%%
