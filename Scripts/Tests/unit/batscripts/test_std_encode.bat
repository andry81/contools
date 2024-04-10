@echo off

rem Create local variable's stack
setlocal

if 0%__CTRL_SETLOCAL% EQU 1 (
  echo.%~nx0: error: cmd.exe is broken, please restart it!>&2
  exit /b 65535
)
set __CTRL_SETLOCAL=1

call "%%~dp0__init__/__init__.bat" || exit /b
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

echo.

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
