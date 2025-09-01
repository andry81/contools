@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

call "%%~dp0.impl\test_math__icmp.bat"
