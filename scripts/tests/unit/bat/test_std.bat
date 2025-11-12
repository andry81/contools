@echo off

setlocal

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

for %%i in ("%TESTS_PROJECT_ROOT%\%~n0\%~n0__*.bat") do (
  set "SCRIPT_FILE=%%i"
  call "%%CONTOOLS_ROOT%%/std/call.bat" "%%SCRIPT_FILE%%"
)

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b
