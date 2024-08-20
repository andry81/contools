@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

echo.^>%~nx0

setlocal
set ARGS="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call "%%~dp0..\..\..\Tools\std\call.bat" echo %%ARGS%%
endlocal
echo.---

setlocal
set ARGS="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call "%%~dp0..\..\..\Tools\std\call.bat" -exe echo %%ARGS%%
endlocal
echo.---

setlocal
set ARGS=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call "%%~dp0..\..\..\Tools\std\call.bat" echo %%ARGS%%
endlocal
echo.---

setlocal
set ARGS=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call "%%~dp0..\..\..\Tools\std\call.bat" -exe echo %%ARGS%%
endlocal
echo.---

rem setlocal
rem call "%%~dp0..\..\..\Tools\std\call.bat" . set | sort
rem endlocal
rem echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\errlvl.bat" 123
call "%%~dp0..\..\..\Tools\std\call.bat"
call "%%~dp0..\..\..\Tools\std\call.bat" echo.
call "%%~dp0..\..\..\Tools\std\call.bat" echo 1 2 3
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\call.bat" exit /b 321
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo.---

setlocal
call "%%~dp0..\..\..\Tools\std\errlvl.bat" 123
call "%%~dp0..\..\..\Tools\std\call.bat" "%%~dp0..\..\..\Tools\std\errlvl.bat" 321
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo.---

setlocal
set "$5E$3E=^>"
call "%%~dp0..\..\..\Tools\std\call.bat" echo.%%$5E$3E%%cmd param0 param1
endlocal
echo.---

setlocal
set "TAB=	"
call "%%~dp0..\..\..\Tools\std\call.bat" echo.cmd %%TAB%% %%TAB%% param0  %%TAB%%%%TAB%%  %%TAB%%%%TAB%%  param1 %%TAB%% %%TAB%%param2 %%TAB%%param3
endlocal
echo.---

echo.
