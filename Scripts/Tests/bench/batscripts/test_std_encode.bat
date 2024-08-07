@echo off

rem Create local variable's stack
setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

call "%%TESTS_PROJECT_ROOT%%/test_std_encode__asterisk_char.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std_encode__equal_char.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std_encode__pathlist_chars.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std_encode__pathlist_chars_glob.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std_encode__sys_chars.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std_encode__sys_chars_bat_cmdline.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std_encode__sys_chars_exe_cmdline.bat"
