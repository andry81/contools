@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

echo.^>%~nx0

setlocal
set ARGS="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call "%%~dp0..\..\..\Tools\std\callshift.bat" 0 echo %%ARGS%%
endlocal
echo.---

setlocal
set ARGS="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call "%%~dp0..\..\..\Tools\std\callshift.bat" -exe 0 echo %%ARGS%%
endlocal
echo.---

setlocal
set ARGS=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call "%%~dp0..\..\..\Tools\std\callshift.bat" 0 echo %%ARGS%%
endlocal
echo.---

setlocal
set ARGS=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call "%%~dp0..\..\..\Tools\std\callshift.bat" -exe 0 echo %%ARGS%%
endlocal
echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\callshift.bat" 2 echo."1 2" 3 4 5
endlocal
echo.---

rem setlocal
rem call "%%~dp0..\..\..\Tools\std\callshift.bat" . set | sort
rem endlocal
rem echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\errlvl.bat" 123
call "%%~dp0..\..\..\Tools\std\callshift.bat"
call "%%~dp0..\..\..\Tools\std\callshift.bat" 0 echo.
call "%%~dp0..\..\..\Tools\std\callshift.bat" 0 echo 1 2 3
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\callshift.bat" -3 echo 1 2 3 4 5 6 7
endlocal
echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\callshift.bat" -skip 2 -3 echo a b 1 2 3 4 5 6 7
endlocal
echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\callshift.bat" 0 exit /b 321
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\errlvl.bat" 123
call "%%~dp0..\..\..\Tools\std\callshift.bat" 0 "%%~dp0..\..\..\Tools\std\errlvl.bat" 321
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\callshift.bat" -no_trim 1 echo  a  b  c  d
endlocal
echo.---

setlocal
set "$5E$3E=^>"
call "%%~dp0..\..\..\Tools\std\callshift.bat" 0 echo.%%$5E$3E%%cmd param0 param1
endlocal
echo.---

setlocal
set "TAB=	"
call "%%~dp0..\..\..\Tools\std\callshift.bat" -no_trim 0 echo.cmd %%TAB%% %%TAB%% param0  %%TAB%%%%TAB%%  %%TAB%%%%TAB%%  param1 %%TAB%% %%TAB%%param2 %%TAB%%param3
endlocal
echo.---

echo.
