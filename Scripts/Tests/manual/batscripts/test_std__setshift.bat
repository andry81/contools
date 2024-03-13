@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b

set "?01=^|"
set "?02=^&"

setlocal
call "%%CONTOOLS_ROOT%%/std/setshift.bat" 0 x "1 2" ! ^^? ^^* %%?02%% %%?01%% , ; = ^= "=" 3
set x
endlocal
echo.---

setlocal
call "%%CONTOOLS_ROOT%%/std/setshift.bat" 2 x "1 2" 3 4 5
set x
endlocal
echo.---

setlocal
call "%%CONTOOLS_ROOT%%/std/errlvl.bat" 123
call "%%CONTOOLS_ROOT%%/std/setshift.bat"
call "%%CONTOOLS_ROOT%%/std/setshift.bat" 0 x
call "%%CONTOOLS_ROOT%%/std/setshift.bat" 0 x 1 2 3
echo ERRORLEVEL=%ERRORLEVEL%
set x
endlocal
echo.---

setlocal
call "%%CONTOOLS_ROOT%%/std/setshift.bat" -3 x 1 2 3 4 5 6 7
set x
endlocal
echo.---

setlocal
call "%%CONTOOLS_ROOT%%/std/setshift.bat" -skip 2 -3 x a b 1 2 3 4 5 6 7
set x
endlocal
echo.---

setlocal
call "%%CONTOOLS_ROOT%%/std/setshift.bat" -no_trim 1 x  a  b  c  d
set x
endlocal
echo.---
