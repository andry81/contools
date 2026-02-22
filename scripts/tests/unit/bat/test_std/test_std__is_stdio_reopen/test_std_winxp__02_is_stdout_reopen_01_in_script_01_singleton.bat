@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%TEST_SCRIPT_FILE_NAME%%" "" "%%TEST_DATA_TEMP_ROOT%%" || exit /b

set "TEST_TEMP_DIR_PATH=%SCRIPT_TEMP_CURRENT_DIR%"

rem initialize setup parameters
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TESTS_LIST_FILE       "%%TESTS_PROJECT_ROOT%%/test_std/test_std__is_stdio_reopen/.tests/02_stdout/input.lst"

type "%TESTS_LIST_FILE:/=\%" ^
  | "%CONTOOLS_MSYS2_USR_ROOT%/bin/sed.exe" -r -b -e "s|/std/is_stdout_reopen.bat|/std/winxp/is_stdout_reopen.bat|mg" > "%TEST_TEMP_DIR_PATH%/test_input.lst" ^
  || goto SKIP_TESTS

set "TESTS_LIST_FILE=%TEST_TEMP_DIR_PATH%/test_input.lst"

set TEST_DEBUG=0

call "%%TESTS_PROJECT_ROOT%%/test_std/test_std__is_stdio_reopen/.impl/test_std__test_singleton_impl.bat" %%*

echo;

:SKIP_TESTS
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b
