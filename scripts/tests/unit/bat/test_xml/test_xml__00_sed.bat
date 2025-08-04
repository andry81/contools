@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem xpath_filter_list/0X
call :TEST "xpath_filter_list/01_empty"   -n -b -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_filter_list_to_flat_findstr_pttn_list.sed"
call :TEST "xpath_filter_list/11_inexact" -n -b -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_filter_list_to_flat_findstr_pttn_list.sed"
call :TEST "xpath_filter_list/12_exact"   -n -b -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_filter_list_to_flat_findstr_pttn_exact_list.sed"

rem xpath_search_list/0X
call :TEST "xpath_search_list/01_empty"   -n -b -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_search_list_to_flat_findstr_search_list.sed"
call :TEST "xpath_search_list/02"         -n -b -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_search_list_to_flat_findstr_search_list.sed"

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
