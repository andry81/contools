@echo off

setlocal DISABLEDELAYEDEXPANSION

rem call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal
call "%%~dp0..\..\..\..\tools\std\get_cmdline.bat"
set RETURN_VALUE
endlocal
echo;---

setlocal
set CMDLINE=  	 		  	 
call "%%~dp0..\..\..\..\tools\std\get_cmdline.bat" %%CMDLINE%%
set CMDLINE
set RETURN_VALUE
endlocal
echo;---

setlocal
set CMDLINE= 	 	 	 1 ! 2 ^^^| 3 ^^^& 4 ^^^^ 5 = 6 , 7 ; 8 * 9 # 0 %% 1 / 2 \ 3 ? 4 ^^^> 5 ^^^< 6 " 7 	 	 	 
call "%%~dp0..\..\..\..\tools\std\get_cmdline.bat" %%CMDLINE%%
set CMDLINE
set RETURN_VALUE
endlocal
echo;---

setlocal
set CMDLINE="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call "%%~dp0..\..\..\..\tools\std\get_cmdline.bat" %%CMDLINE%%
set CMDLINE
set RETURN_VALUE
endlocal
echo;---

setlocal
set CMDLINE=$*^^^|^^^&^^^(=^^^)^^^<^^^>^"='`^^%%!+?** ,;=
call "%%~dp0..\..\..\..\tools\std\get_cmdline.bat" %%CMDLINE%%
set CMDLINE
set RETURN_VALUE
endlocal
echo;---

echo;
