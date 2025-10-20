@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal
call "%%CONTOOLS_ROOT%%/std/get_cmdline_len.bat" --
echo ARGS_COUNT(bat)=%ERRORLEVEL%
call "%%CONTOOLS_ROOT%%/std/get_cmdline_len.bat" -exe --
echo ARGS_COUNT(exe)=%ERRORLEVEL%
endlocal
echo;---

setlocal
set CMDLINE=  	 		  	 
call "%%CONTOOLS_ROOT%%/std/get_cmdline_len.bat" -- %%CMDLINE%%
echo ARGS_COUNT(bat)=%ERRORLEVEL%
call "%%CONTOOLS_ROOT%%/std/get_cmdline_len.bat" -exe -- %%CMDLINE%%
echo ARGS_COUNT(exe)=%ERRORLEVEL%
set CMDLINE
endlocal
echo;---

setlocal
set CMDLINE= 	 	 	 1 ! 2 ^^^| 3 ^^^& 4 ^^^^ 5 = 6 , 7 ; 8 * 9 # 0 %% 1 / 2 \ 3 ? 4 ^^^> 5 ^^^< 6 " 7 	 	 	 
call "%%CONTOOLS_ROOT%%/std/get_cmdline_len.bat" -- %%CMDLINE%%
echo ARGS_COUNT(bat)=%ERRORLEVEL%
call "%%CONTOOLS_ROOT%%/std/get_cmdline_len.bat" -exe -- %%CMDLINE%%
echo ARGS_COUNT(exe)=%ERRORLEVEL%
set CMDLINE
endlocal
echo;---

setlocal
set CMDLINE="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call "%%CONTOOLS_ROOT%%/std/get_cmdline_len.bat" -- %%CMDLINE%%
echo ARGS_COUNT(bat)=%ERRORLEVEL%
call "%%CONTOOLS_ROOT%%/std/get_cmdline_len.bat" -exe -- %%CMDLINE%%
echo ARGS_COUNT(exe)=%ERRORLEVEL%
set CMDLINE
endlocal
echo;---

setlocal
set CMDLINE=$*^^^|^^^&^^^(=^^^)^^^<^^^>^"='`^^%%!+?** ,;=
call "%%CONTOOLS_ROOT%%/std/get_cmdline_len.bat" -- %%CMDLINE%%
echo ARGS_COUNT(bat)=%ERRORLEVEL%
call "%%CONTOOLS_ROOT%%/std/get_cmdline_len.bat" -exe -- %%CMDLINE%%
echo ARGS_COUNT(exe)=%ERRORLEVEL%
set CMDLINE
endlocal
echo;---

echo;
