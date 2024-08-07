@echo off

rem Create local variable's stack
setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

call "%%TESTS_PROJECT_ROOT%%/test_std__strlen.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std__trim_var.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std__echo_path_var.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std__echo_pathglob_var.bat"
