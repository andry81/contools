@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

set myvar1=              1 ! 2 ^| 3 ^& 4 ^^ 5 = 6 , 7 ; 8 * 9 # 0 %% 1 / 2 \ 3 ? 4 ^> 5 ^< 6 " 7             

call "%%~dp0..\..\..\Tools\std\trim_var.bat" myvar1 myvar2

call "%%~dp0..\..\..\Tools\std\echo_var.bat" myvar1 - -
call "%%~dp0..\..\..\Tools\std\echo_var.bat" myvar2 - -
