@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

set "STRING_TO_TRIM="
set "STRING_REFERENCE="
call :TEST

set "STRING_TO_TRIM= 	 		  	 "
set "STRING_REFERENCE="
call :TEST

set STRING_TO_TRIM= 	 	 	 1 ! 2 ^| 3 ^& 4 ^^ 5 = 6 , 7 ; 8 * 9 # 0 %% 1 / 2 \ 3 ? 4 ^> 5 ^< 6 " 7 	 	 	 
set STRING_REFERENCE=1 ! 2 ^| 3 ^& 4 ^^ 5 = 6 , 7 ; 8 * 9 # 0 %% 1 / 2 \ 3 ? 4 ^> 5 ^< 6 " 7
call :TEST

set STRING_TO_TRIM="1 2" ! ? * ^& ^| , ; = ^= "=" 3
set STRING_REFERENCE="1 2" ! ? * ^& ^| , ; = ^= "=" 3
call :TEST

set STRING_TO_TRIM=$*^|^&(=)^<^>^"='`^^%%!+?** ,;=
set STRING_REFERENCE=$*^|^&(=)^<^>^"='`^^%%!+?** ,;=
call :TEST

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
