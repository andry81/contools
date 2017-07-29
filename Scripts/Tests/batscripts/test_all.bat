@echo off

rem Create local variable's stack
setlocal

call "%%~dp0__init__.bat" || goto :EOF
call "%%TESTLIB_ROOT%%/init.bat" "%%~dpf0" || goto :EOF

call "%%TESTS_ROOT%%/test_strlen.bat"
call "%%TESTS_ROOT%%/test_strchr.bat"
call "%%TESTS_ROOT%%/test_strrep.bat"
call "%%TESTS_ROOT%%/test_stresc.bat"
call "%%TESTS_ROOT%%/test_cstresc.bat"
call "%%TESTS_ROOT%%/test_extract_version.bat"
rem call "%%TESTS_ROOT%%/test_setvarsfromfile.bat"

call "%%TESTS_ROOT%%/test_std_allocate_temp_dir.bat"
call "%%TESTS_ROOT%%/test_xml_sed.bat"
call "%%TESTS_ROOT%%/test_xml__filter_xpath_list_by_xpath_list.bat"

rem WARNING: must be called without the call prefix!
"%TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b
