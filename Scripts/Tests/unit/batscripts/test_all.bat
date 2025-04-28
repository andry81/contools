@echo off

rem Create local variable's stack
setlocal

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

for %%i in ("%TESTS_PROJECT_ROOT%\test_*.bat") do (
  set "SCRIPT_NAME=%%~ni"
  set "SCRIPT_FILE=%%i"
  call "%%CONTOOLS_ROOT%%/std/if_.bat" ^
    "%%SCRIPT_NAME:!=%%" == "%%SCRIPT_NAME%%" ^
    if not "%%SCRIPT_FILE:*\%~nx0=%%" == "" ^
    if "%%SCRIPT_FILE:*\test__=%%" == "%%SCRIPT_FILE%%" ^
      && call "%%CONTOOLS_ROOT%%/std/call.bat" "%%SCRIPT_FILE%%"
)

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b
