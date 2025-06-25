@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal
set __STRING__="1 2" ! ? * ^& ^| , ; = ^^= "=" 3
set __STRING__
call "%%~dp0..\..\..\..\tools\std\encode/encode_asterisk_char.bat"
set __STRING__
call "%%~dp0..\..\..\..\tools\std\encode/decode_asterisk_char.bat"
set __STRING__
endlocal
echo;---

setlocal
set __STRING__=$*^|^&^(=^)^<^>^"='`^^%%!+?** ,;=
set __STRING__
call "%%~dp0..\..\..\..\tools\std\encode/encode_asterisk_char.bat"
set __STRING__
call "%%~dp0..\..\..\..\tools\std\encode/decode_asterisk_char.bat"
set __STRING__
endlocal
echo;---

echo;
