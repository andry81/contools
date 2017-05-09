@echo off

rem Create local variable's stack
setlocal

call "%%~dp0__init__.bat"

set /A __NEST_LVL+=1

call "%%TESTS_ROOT%%/test_strlen.bat"
call "%%TESTS_ROOT%%/test_strchr.bat"
call "%%TESTS_ROOT%%/test_strrep.bat"
call "%%TESTS_ROOT%%/test_stresc.bat"
call "%%TESTS_ROOT%%/test_cstresc.bat"
call "%%TESTS_ROOT%%/test_extract_version.bat"
call "%%TESTS_ROOT%%/test_make_url_canonical.bat"
call "%%TESTS_ROOT%%/test_make_url_absolute.bat"
rem call "%%TESTS_ROOT%%/test_setvarsfromfile.bat"

call "%%TESTS_ROOT%%/test_xml_sed.bat"
call "%%TESTS_ROOT%%/test_xml__filter_xpath_list_by_xpath_list.bat"

set /A __NEST_LVL-=1

if %__NEST_LVL%0 EQU 0 (
  echo    %__PASSED_TESTS% of %__OVERALL_TESTS% tests is passed.
  echo.^
  pause
)
