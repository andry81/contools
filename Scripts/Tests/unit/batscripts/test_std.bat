@echo off

rem Create local variable's stack
setlocal

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

for %%i in ("%TESTS_PROJECT_ROOT%\%~n0\%~n0__*.bat") do (
  set "SCRIPT_FILE=%%i"
  call "%%CONTOOLS_ROOT%%/std/call.bat" "%%SCRIPT_FILE%%"
)

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b
