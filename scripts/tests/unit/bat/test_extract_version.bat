@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

call :TEST "1.7.5.1"      "1.7.5-1"
call :TEST "1.7.5.1"      "1.7.5-1" -d
call :TEST "2.1.0.1"      "2.1-1"
call :TEST "2.1.0.1"      "2.1-1" -d
call :TEST "1.4.6.10"     "1.4p6-10"
call :TEST "1.4.6.10"     "1.4p6-10" -d
call :TEST "00885.0.0.1"  "00885-1"
call :TEST "00885.0.0.1"  "00885-1" -d
call :TEST "1.3.30c.10"   "1.3.30c-10"
call :TEST "1.3.30.10"    "1.3.30c-10" -d
call :TEST "20050522.0.0.1"   "20050522-1"
call :TEST "20050522.0.0.1"   "20050522-1" -d
call :TEST "5.7.20091114.14"  "5.7_20091114-14"
call :TEST "5.7.20091114.14"  "5.7_20091114-14" -d
call :TEST "4.5.20.2.2"   "4.5.20.2-2"
call :TEST "4.5.20.2.2"   "4.5.20.2-2" -d
call :TEST "2009k.0.0.1"  "2009k-1"
call :TEST "2009.0.0.1"   "2009k-1" -d
call :TEST "1.2.3c.4.5"   "1.2.3c.4.5"
call :TEST "1.2.3.4.5"    "1.2.3c.4.5" -d

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
