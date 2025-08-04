@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" ".01_piped_handlers" || exit /b

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_CONV_SCRIPT  "%%CONTOOLS_ROOT%%/encoding/dos2unix.bat"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TESTS_LIST_FILE   "%%TESTS_PROJECT_ROOT%%/test_encoding/.tests/02_dos2unix.lst"

set "CONTOOLS_GNUWIN32_ROOT="

set TEST_CONV_SCRIPT
set TESTS_LIST_FILE
set CONTOOLS_GNUWIN32_ROOT
set CONTOOLS_MSYS2_ROOT

if not defined CONTOOLS_MSYS2_ROOT goto SKIP_MSYS2
if not exist "%CONTOOLS_MSYS2_ROOT%/*" goto SKIP_MSYS2

for /f "usebackq eol=# tokens=* delims=" %%i in ("%TESTS_LIST_FILE%") do call :TEST "%%i"

echo;

goto END

:SKIP_MSYS2
echo;SKIPPED: CONTOOLS_MSYS2_ROOT is not defined or not exist
echo;

:END

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
