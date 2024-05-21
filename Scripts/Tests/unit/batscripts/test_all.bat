@echo off

rem Create local variable's stack
setlocal

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

call "%%TESTS_PROJECT_ROOT%%/test_std_encode.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std__strlen.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std__allocate_temp_dir.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std__chcp.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std__trim_var.bat"
call "%%TESTS_PROJECT_ROOT%%/test_std__get_cmdline_var_len.bat"

call "%%TESTS_PROJECT_ROOT%%/test_build__load_config.bat"

call "%%TESTS_PROJECT_ROOT%%/test_extract_version.bat"

call "%%TESTS_PROJECT_ROOT%%/test_xml_sed.bat"
call "%%TESTS_PROJECT_ROOT%%/test_xml__filter_xpath_list_by_xpath_list.bat"

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b
