@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

set myvar1= 	 	 	 1 ! 2 ^| 3 ^& 4 ^^ 5 = 6 , 7 ; 8 * 9 # 0 %% 1 / 2 \ 3 ? 4 ^> 5 ^< 6 " 7 	 	 	 

call "%%CONTOOLS_ROOT%%/std/trim_var.bat" myvar1 myvar2

call "%%CONTOOLS_ROOT%%/std/echo_var.bat" myvar1 - -
call "%%CONTOOLS_ROOT%%/std/echo_var.bat" myvar2 - -

echo;
