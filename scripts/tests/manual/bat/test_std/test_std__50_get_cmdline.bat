@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal
call "%%CONTOOLS_ROOT%%/std/get_cmdline.bat"
set RETURN_VALUE
endlocal
echo;---

setlocal
set CMDLINE=  	 		  	 
call "%%CONTOOLS_ROOT%%/std/get_cmdline.bat" %%CMDLINE%%
set CMDLINE
set RETURN_VALUE
endlocal
echo;---

setlocal
set CMDLINE= 	 	 	 1 ! 2 ^^^| 3 ^^^& 4 ^^^^ 5 = 6 , 7 ; 8 * 9 # 0 %% 1 / 2 \ 3 ? 4 ^^^> 5 ^^^< 6 " 7 	 	 	 
call "%%CONTOOLS_ROOT%%/std/get_cmdline.bat" %%CMDLINE%%
set CMDLINE
set RETURN_VALUE
endlocal
echo;---

setlocal
set CMDLINE="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call "%%CONTOOLS_ROOT%%/std/get_cmdline.bat" %%CMDLINE%%
set CMDLINE
set RETURN_VALUE
endlocal
echo;---

setlocal
set CMDLINE=$*^^^|^^^&^^^(=^^^)^^^<^^^>^"='`^^%%!+?** ,;=
call "%%CONTOOLS_ROOT%%/std/get_cmdline.bat" %%CMDLINE%%
set CMDLINE
set RETURN_VALUE
endlocal
echo;---

echo;
