@echo off

rem Create local variable's stack
setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

call "%%TESTS_PROJECT_ROOT%%/test_std.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std_encode.bat"
call "%%TESTS_PROJECT_ROOT%%/test_build.bat"
