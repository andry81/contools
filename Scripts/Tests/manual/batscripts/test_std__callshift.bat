@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b

set "?01=^|"
set "?02=^&"

setlocal
call "%%CONTOOLS_ROOT%%/std/callshift.bat" 0 echo "1 2" ! ^^? ^^* %%?02%% %%?01%% , ; = ^= "=" 3
endlocal
echo.---

setlocal
call "%%CONTOOLS_ROOT%%/std/callshift.bat" 2 echo."1 2" 3 4 5
endlocal
echo.---

rem setlocal
rem call "%%CONTOOLS_ROOT%%/std/callshift.bat" . set | sort
rem endlocal
rem echo.---

setlocal
call "%%CONTOOLS_ROOT%%/std/errlvl.bat" 123
call "%%CONTOOLS_ROOT%%/std/callshift.bat"
call "%%CONTOOLS_ROOT%%/std/callshift.bat" 0 echo.
call "%%CONTOOLS_ROOT%%/std/callshift.bat" 0 echo 1 2 3
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo.---

setlocal
call "%%CONTOOLS_ROOT%%/std/callshift.bat" -3 echo 1 2 3 4 5 6 7
endlocal
echo.---

setlocal
call "%%CONTOOLS_ROOT%%/std/callshift.bat" -skip 2 -3 echo a b 1 2 3 4 5 6 7
endlocal
echo.---

setlocal
call "%%CONTOOLS_ROOT%%/std/callshift.bat" 0 exit /b 123
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo.---

setlocal
call "%%CONTOOLS_ROOT%%/std/errlvl.bat" 123
call "%%CONTOOLS_ROOT%%/std/callshift.bat" 0 call "%%%%CONTOOLS_ROOT%%%%/std/errlvl.bat" 321
echo ERRORLEVEL=%ERRORLEVEL%
endlocal
echo.---

setlocal
call "%%CONTOOLS_ROOT%%/std/callshift.bat" -no_trim 1 echo  a  b  c  d
endlocal
echo.---
