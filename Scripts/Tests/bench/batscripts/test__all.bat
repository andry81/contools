@echo off

rem Create local variable's stack
setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

call "%%TESTS_PROJECT_ROOT%%/test__copy_nul_tempfile.bat"
call "%%TESTS_PROJECT_ROOT%%/test__copy_nul_tempfile_single_redir.bat"
call "%%TESTS_PROJECT_ROOT%%/test__type_nul_tempfile.bat"
call "%%TESTS_PROJECT_ROOT%%/test__type_nul_tempfile_single_redir.bat"
