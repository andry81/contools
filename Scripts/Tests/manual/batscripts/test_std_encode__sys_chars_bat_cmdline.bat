@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b

setlocal
set __STRING__="1 2" ! ? * ^& ^| , ; = ^^= "=" 3
set __STRING__
call "%%CONTOOLS_ROOT%%/std/encode/encode_sys_chars_bat_cmdline.bat"
set __STRING__
call "%%CONTOOLS_ROOT%%/std/encode/decode_sys_chars_bat_cmdline.bat"
set __STRING__
endlocal
echo.---

setlocal
set __STRING__=$*^|^&^(=^)^<^>^"='`^^%%!+?** ,;=
set __STRING__
call "%%CONTOOLS_ROOT%%/std/encode/encode_sys_chars_bat_cmdline.bat"
set __STRING__
call "%%CONTOOLS_ROOT%%/std/encode/decode_sys_chars_bat_cmdline.bat"
set __STRING__
endlocal
echo.---