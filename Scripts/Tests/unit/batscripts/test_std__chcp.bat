@echo off

rem Drop last error level
call;

rem Create local variable's stack
setlocal

if 0%__CTRL_SETLOCAL% EQU 1 (
  echo.%~nx0: error: cmd.exe is broken, please restart it!>&2
  exit /b 65535
)
set __CTRL_SETLOCAL=1

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

call :TEST chcp 65000 866 "866|"
call :TEST chcp 65001 65000 "65000|866|"
call :TEST restorecp 65000 65001 "866|"
call :TEST restorecp 866 65000 ""
call :TEST chcp 866 866 "866|"
call :TEST chcp 866 866 "866|866|"
call :TEST restorecp 866 866 "866|"
call :TEST restorecp 866 866 ""

echo.

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
