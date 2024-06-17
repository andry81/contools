@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

setlocal
set __STRING__="1 2" ! ? * ^& ^| , ; = ^^= "=" 3
set __STRING__
call "%%~dp0..\..\..\Tools\std\encode/encode_pathlist_chars.bat"
set __STRING__
call "%%~dp0..\..\..\Tools\std\encode/decode_pathlist_chars.bat"
set __STRING__
endlocal
echo.---

setlocal
set __STRING__=$*^|^&^(=^)^<^>^"='`^^%%!+?** ,;=
set __STRING__
call "%%~dp0..\..\..\Tools\std\encode/encode_pathlist_chars.bat"
set __STRING__
call "%%~dp0..\..\..\Tools\std\encode/decode_pathlist_chars.bat"
set __STRING__
endlocal
echo.---

setlocal
set __STRING__="1 2";3 4;5,6;7=8;9!*?0
set __STRING__
call "%%~dp0..\..\..\Tools\std\encode/encode_pathlist_chars.bat"
for %%i in (%__STRING__%) do set "__STRING__=%%i" & ^
call "%%~dp0..\..\..\Tools\std\encode/decode_pathlist_chars.bat" & ^
call "%%~dp0..\..\..\Tools\std\echo_var.bat" __STRING__ " "
endlocal
echo.---

setlocal
set __STRING__="1 2";3 4;5,6;7=8;9*?0
set __STRING__
call "%%~dp0..\..\..\Tools\std\encode/encode_pathlist_chars.bat"
setlocal ENABLEDELAYEDEXPANSION
for %%i in (!__STRING__!) do set "__STRING__=%%i" & ^
call "%%~dp0..\..\..\Tools\std\encode/decode_pathlist_chars.bat" & ^
call "%%~dp0..\..\..\Tools\std\echo_var.bat" __STRING__ " "
endlocal
echo.---
