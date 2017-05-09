@echo off

rem Create local variable's stack
setlocal

call "%%~dp0__init__.bat"

set /A __NEST_LVL+=1

call "%%~dp0test_strlen.bat"
call "%%~dp0test_strchr.bat"
call "%%~dp0test_strrep.bat"
call "%%~dp0test_stresc.bat"
call "%%~dp0test_cstresc.bat"
call "%%~dp0test_extract_version.bat"
call "%%~dp0test_make_url_canonical.bat"
call "%%~dp0test_make_url_absolute.bat"
rem call "%%~dp0test_setvarsfromfile.bat"

call "%%~dp0test_xml_sed.bat"
call "%%~dp0test_xml__filter_xpath_list_by_xpath_list.bat"

set /A __NEST_LVL-=1

if %__NEST_LVL%0 EQU 0 (
  echo    %__PASSED_TESTS% of %__OVERALL_TESTS% tests is passed.
  echo.^
  pause
)
