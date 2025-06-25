@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal
rem CAUTION: in case of globbing the result is dependent on the file system
set __STRING__="1 2";3 4;5,6;7=8;9!*?0
set __STRING__
call "%%~dp0..\..\..\..\tools\std\encode/encode_pathlist_chars_glob.bat"
for %%i in (%__STRING__%) do set "__STRING__=%%i" & ^
call "%%~dp0..\..\..\..\tools\std\encode/decode_pathlist_chars_glob.bat" & ^
call "%%~dp0..\..\..\..\tools\std\echo_var.bat" __STRING__ " " "|"
endlocal
echo;---

setlocal
rem CAUTION: in case of globbing the result is dependent on the file system
set __STRING__="1 2";3 4;5,6;7=8;9!*?0
set __STRING__
call "%%~dp0..\..\..\..\tools\std\encode/encode_pathlist_chars_glob.bat"
setlocal ENABLEDELAYEDEXPANSION & for %%i in (!__STRING__!) do endlocal & set "__STRING__=%%i" & ^
call "%%~dp0..\..\..\..\tools\std\encode/decode_pathlist_chars_glob.bat" & ^
call "%%~dp0..\..\..\..\tools\std\echo_var.bat" __STRING__ " " "|"
endlocal
echo;---

setlocal
rem CAUTION: in case of globbing the result is dependent on the file system
set __STRING__="?a/b/%%c%%!" ^;	 "!d! ^; e ; f" ; ; ; !AAA! ^^; g,g ;;; h h
set __STRING__
call "%%~dp0..\..\..\..\tools\std\encode/encode_pathlist_chars_glob.bat"
for %%i in (%__STRING__%) do set "__STRING__=%%i" & ^
call "%%~dp0..\..\..\..\tools\std\encode/decode_pathlist_chars_glob.bat" & ^
call "%%~dp0..\..\..\..\tools\std\echo_var.bat" __STRING__ " " "|"
endlocal
echo;---

setlocal
rem CAUTION: in case of globbing the result is dependent on the file system
set __STRING__="?a/b/%%c%%!" ^;	 "!d! ^; e ; f" ; ; ; !AAA! ^^; g,g ;;; h h
set __STRING__
call "%%~dp0..\..\..\..\tools\std\encode/encode_pathlist_chars_glob.bat"
setlocal ENABLEDELAYEDEXPANSION & for %%i in (!__STRING__!) do endlocal & set "__STRING__=%%i" & ^
call "%%~dp0..\..\..\..\tools\std\encode/decode_pathlist_chars_glob.bat" & ^
call "%%~dp0..\..\..\..\tools\std\echo_var.bat" __STRING__ " " "|"
endlocal
echo;---

echo;
