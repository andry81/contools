@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal
set __LIST__="1 2" ! ? * ^& ^| , ; = ^^= "=" 3
set __LIST__
call "%%~dp0..\..\..\..\tools\std\echo_path_var.bat" __LIST__ " " "|"
endlocal
echo;---

setlocal
set __STRING__="1 2" ! ? * ^& ^| , ; = ^^= "=" 3
set __STRING__
call "%%~dp0..\..\..\..\tools\std\echo_path_var.bat" __STRING__ " " "|"
endlocal
echo;---

setlocal
set __LIST__=$*^|^&^(=^)^<^>^"='`^^%%!+?** ,;=
set __LIST__
call "%%~dp0..\..\..\..\tools\std\echo_path_var.bat" __LIST__ " " "|"
endlocal
echo;---

setlocal
set __STRING__=$*^|^&^(=^)^<^>^"='`^^%%!+?** ,;=
set __STRING__
call "%%~dp0..\..\..\..\tools\std\echo_path_var.bat" __STRING__ " " "|"
endlocal
echo;---

setlocal
set __LIST__="1 2";3 4;5,6;7=8;9!*?0
set __LIST__
call "%%~dp0..\..\..\..\tools\std\echo_path_var.bat" __LIST__ " " "|"
endlocal
echo;---

setlocal
set __STRING__="1 2";3 4;5,6;7=8;9!*?0
set __STRING__
call "%%~dp0..\..\..\..\tools\std\echo_path_var.bat" __STRING__ " " "|"
endlocal
echo;---

setlocal
set __LIST__="?a/b/%%c%%!" ^;	 "!d! ^; e ; f" ; ; ; !AAA! ^^; g,g ;;; h h
set __LIST__
call "%%~dp0..\..\..\..\tools\std\echo_path_var.bat" __LIST__ " " "|"
endlocal
echo;---

setlocal
set __STRING__="?a/b/%%c%%!" ^;	 "!d! ^; e ; f" ; ; ; !AAA! ^^; g,g ;;; h h
set __STRING__
call "%%~dp0..\..\..\..\tools\std\echo_path_var.bat" __STRING__ " " "|"
endlocal
echo;---

echo;
