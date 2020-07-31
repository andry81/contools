@echo off

rem Drop last error level
type nul>nul

rem Create local variable's stack
setlocal

if 0%__CTRL_SETLOCAL% EQU 1 (
  echo.%~nx0: error: cmd.exe is broken, please restart it!>&2
  exit /b 65535
)
set __CTRL_SETLOCAL=1

call "%%~dp0__init__.bat" || exit /b
call "%%TESTLIB_ROOT%%/init.bat" "%%~dpf0" || exit /b

rem xpath_filter_list/0X
call :TEST "xpath_filter_list/01_empty" -n -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_filter_list_to_flat_findstr_pttn_list.sed"
call :TEST "xpath_filter_list/11_inexact" -n -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_filter_list_to_flat_findstr_pttn_list.sed"
call :TEST "xpath_filter_list/12_exact" -n -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_filter_list_to_flat_findstr_pttn_exact_list.sed"

rem xpath_search_list/0X
call :TEST "xpath_search_list/01_empty" -n -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_search_list_to_flat_findstr_search_list.sed"
call :TEST "xpath_search_list/02" -n -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_search_list_to_flat_findstr_search_list.sed"

echo.

rem WARNING: must be called without the call prefix!
"%TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%TESTLIB_ROOT%%/test.bat" %%*
exit /b
