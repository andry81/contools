@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

setlocal
set ARGS="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call "%%~dp0..\..\..\Tools\std\setshift.bat" 0 x %%ARGS%%
set x
endlocal
echo.---

setlocal
set ARGS="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call "%%~dp0..\..\..\Tools\std\setshift.bat" -exe 0 x %%ARGS%%
set x
endlocal
echo.---

setlocal
set ARGS=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call "%%~dp0..\..\..\Tools\std\setshift.bat" 0 x %%ARGS%%
set x
endlocal
echo.---

setlocal
set ARGS=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call "%%~dp0..\..\..\Tools\std\setshift.bat" -exe 0 x %%ARGS%%
set x
endlocal
echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\setshift.bat" 2 x "1 2" 3 4 5
set x
endlocal
echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\errlvl.bat" 123
call "%%~dp0..\..\..\Tools\std\setshift.bat"
call "%%~dp0..\..\..\Tools\std\setshift.bat" 0 x
call "%%~dp0..\..\..\Tools\std\setshift.bat" 0 x 1 2 3
echo ERRORLEVEL=%ERRORLEVEL%
set x
endlocal
echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\setshift.bat" -3 x 1 2 3 4 5 6 7
set x
endlocal
echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\setshift.bat" -skip 2 -3 x a b 1 2 3 4 5 6 7
set x
endlocal
echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\setshift.bat" -no_trim 1 x  a  b  c  d
set x
endlocal
echo.---
