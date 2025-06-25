@echo off

rem Create local variable's stack
setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

set __STRING__="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :TEST equal_char

set __STRING__=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :TEST equal_char

set __STRING__="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :TEST asterisk_char

set __STRING__=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :TEST asterisk_char

set __STRING__="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :TEST sys_chars

set __STRING__=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :TEST sys_chars

set __STRING__="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :TEST sys_chars_bat_cmdline

set __STRING__=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :TEST sys_chars_bat_cmdline

set __STRING__="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :TEST sys_chars_exe_cmdline

set __STRING__=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :TEST sys_chars_exe_cmdline

set __STRING__="1 2" ! ? * ^^^& ^^^| , ; = ^^= "=" 3
call :TEST pathlist_chars

set __STRING__=$*^^^|^^^&^(=^)^^^<^^^>^"='`^^%%!+?** ,;=
call :TEST pathlist_chars

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
