@echo off

if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/entry\*" (
  if defined TEST_ENTRY (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/entry/%%TEST_ENTRY%%.bat" %%*
  ) else call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/entry/test.bat" %%*
) else if defined TEST_ENTRY (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/entry/%%TEST_ENTRY%%.bat" %%*
) else call "%%TEST_SCRIPT_HANDLERS_DIR%%/entry/test.bat" %%*

exit /b

rem USAGE:
rem   set TEST_ENTRY=<name>
rem   call test_entry.bat <command-line>...

rem Description:
rem   Optional entry point script to a user test entry script.
rem   A user test entry script must call to the `testlib/test.bat` script at
rem   the end.
rem
rem   Uses as a replacement for `call :TEST ...` in case of a long user test
rem   script.
rem
rem   Calls to:
rem
rem     /.<user_test_script>/entry/%TEST_ENTRY%.bat <command-line>
rem
rem   If TEST_ENTRY is empty, then calls to:
rem
rem     /.<user_test_script>/entry/test.bat <command-line>
