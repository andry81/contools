@echo off

rem Create local variable's stack
setlocal

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

call :TEST chcp 65000 "%%SETUP_CP%%" "%%SETUP_CP%%|"
call :TEST chcp 65001 65000 "65000|%%SETUP_CP%%|"
call :TEST restorecp 65000 65001 "%%SETUP_CP%%|"
call :TEST restorecp "%%SETUP_CP%%" 65000 ""
call :TEST chcp 866 "%%SETUP_CP%%" "%%SETUP_CP%%|"
call :TEST chcp 866 866 "866|%%SETUP_CP%%|"
call :TEST chcp 437 866 "866|866|%%SETUP_CP%%|"
call :TEST restorecp 866 437 "866|%%SETUP_CP%%|"
call :TEST restorecp 866 866 "%%SETUP_CP%%|"
call :TEST restorecp "%%SETUP_CP%%" 866 ""
call :TEST restorecp "%%SETUP_CP%%" 866 ""

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
