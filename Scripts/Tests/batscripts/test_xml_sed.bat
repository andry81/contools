@echo off

rem Drop last error level
cd .

rem Create local variable's stack
setlocal

if 0%__CTRL_SETLOCAL% EQU 1 (
  echo.%~nx0: error: cmd.exe is broken, please restart it!>&2
  exit /b 65535
)
set __CTRL_SETLOCAL=1

call "%%~dp0__init__.bat" || goto :EOF

set "TEST_DATA_FILE_SCRIPT_NAME=%~n0"
set "?~nx0=%~nx0"

echo Running %~nx0...
title %~nx0 %*

set /A __NEST_LVL+=1

set __COUNTER1=1
set LASTERROR=0

rem xpath_filter_list/0X
call :TEST "xpath_filter_list/01_empty" -n -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_filter_list_to_flat_findstr_pttn_list.sed"
call :TEST "xpath_filter_list/11_inexact" -n -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_filter_list_to_flat_findstr_pttn_list.sed"
call :TEST "xpath_filter_list/12_exact" -n -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_filter_list_to_flat_findstr_pttn_exact_list.sed"

rem xpath_search_list/0X
call :TEST "xpath_search_list/01_empty" -n -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_search_list_to_flat_findstr_search_list.sed"
call :TEST "xpath_search_list/02" -n -f "%%CONTOOLS_ROOT%%/xml/sed/convert_xpath_search_list_to_flat_findstr_search_list.sed"

if %LASTERROR% EQU 0 echo.

goto EXIT

:TEST
setlocal

set LASTERROR=0
set INTERRORLEVEL=0

set "TEST_DATA_DIR=%TEST_DATA_FILE_SCRIPT_NAME%/%~1"
shift

set "TEST_DATA_SED_CMD_LINE="
:TEST_DATA_SED_CMD_LINE_LOOP
if "%~1" == "" goto TEST_DATA_SED_CMD_LINE_LOOP_END

set TEST_DATA_SED_CMD_LINE=%TEST_DATA_SED_CMD_LINE%%1 
shift

goto TEST_DATA_SED_CMD_LINE_LOOP

:TEST_DATA_SED_CMD_LINE_LOOP_END

set TEST_DO_TEARDOWN=0
if %TEST_SETUP%0 EQU 0 (
  set TEST_DO_TEARDOWN=1
  call :TEST_SETUP || ( set LASTERROR=%ERRORLEVEL% & goto TEST_EXIT ) )
)

call :TEST_IMPL

:TEST_EXIT
call :TEST_REPORT

if %TEST_DO_TEARDOWN%0 NEQ 0 (
  set "TEST_DO_TEARDOWN="
  call :TEST_TEARDOWN
)

goto TEST_END

:TEST_IMPL
call :GET_ABSOLUTE_PATH "%%TEST_DATA_BASE_DIR%%\%%TEST_DATA_DIR%%\input.txt"
set "TEST_DATA_IN_FILE=%RETURN_VALUE%"

call :GET_ABSOLUTE_PATH "%%TEST_DATA_BASE_DIR%%\%%TEST_DATA_DIR%%\output.txt"
set "TEST_DATA_REF_FILE=%RETURN_VALUE%"

rem builtin commands
(
  "%GNUWIN32_ROOT%/bin/sed.exe" %TEST_DATA_SED_CMD_LINE% "%TEST_DATA_IN_FILE%"
) > "%TEST_DATA_OUT_FILE%" || ( call set "INTERRORLEVEL=%%ERRORLEVEL%%" & set "LASTERROR=20" & goto LOCAL_EXIT1 )

if not exist "%TEST_DATA_OUT_FILE%" ( set "LASTERROR=21" & goto LOCAL_EXIT1 )
if not exist "%TEST_DATA_REF_FILE%" ( set "LASTERROR=22" & goto LOCAL_EXIT1 )

fc "%TEST_DATA_OUT_FILE%" "%TEST_DATA_REF_FILE%" > nul
if %ERRORLEVEL% NEQ 0 set LASTERROR=23

:LOCAL_EXIT1
exit /b %LASTERROR%

:TEST_SETUP
if %TEST_SETUP%0 NEQ 0 exit /b -1
set TEST_SETUP=1
set "TEST_TEARDOWN="

set LASTERROR=0
set INTERRORLEVEL=0

call "%%CONTOOLS_ROOT%%/get_datetime.bat"
set "SYNC_DATE=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%"
set "SYNC_TIME=%RETURN_VALUE:~8,2%_%RETURN_VALUE:~10,2%_%RETURN_VALUE:~12,2%_%RETURN_VALUE:~15,3%"

set "TEST_TEMP_DIR_NAME=%TEST_DATA_FILE_SCRIPT_NAME%.%SYNC_DATE%.%SYNC_TIME%"
set "TEST_TEMP_DIR_PATH=%TEST_TEMP_BASE_DIR%\%TEST_TEMP_DIR_NAME%"

mkdir "%TEST_TEMP_DIR_PATH%" || exit /b 1

rem initialize TEST_SETUP parameters
call :GET_ABSOLUTE_PATH "%TEST_TEMP_DIR_PATH%\output.txt"
set "TEST_DATA_OUT_FILE=%RETURN_VALUE%"

exit /b 0

:GET_ABSOLUTE_PATH
set "RETURN_VALUE=%~dpf1"
exit /b 0

:TEST_TEARDOWN
if %TEST_SETUP%0 EQU 0 exit /b -1
set "TEST_SETUP="
set TEST_TEARDOWN=1

rem cleanup temporary files
if not "%TEST_TEMP_DIR_PATH%" == "" ^
if exist "%TEST_TEMP_DIR_PATH%\" rmdir /S /Q "%TEST_TEMP_DIR_PATH%"

exit /b 0

:TEST_REPORT
if %LASTERROR% NEQ 0 (
  rem copy workingset on error
  mkdir "%TEST_SRC_BASE_DIR%\_output\%TEST_TEMP_DIR_NAME%\reference\%TEST_DATA_DIR:*/=%"
  call "%%CONTOOLS_ROOT%%/xcopy_dir.bat" "%%TEST_TEMP_DIR_PATH%%" "%%TEST_SRC_BASE_DIR%%\_output\%%TEST_TEMP_DIR_NAME%%" /Y /H /E > nul
  call "%%CONTOOLS_ROOT%%/xcopy_dir.bat" "%%TEST_DATA_BASE_DIR%%\%%TEST_DATA_DIR%%" "%%TEST_SRC_BASE_DIR%%\_output\%%TEST_TEMP_DIR_NAME%%\reference\%TEST_DATA_DIR:*/=%" /Y /H /E > nul

  echo.FAILED: %__COUNTER1%: ERROR=%LASTERROR%.%INTERRORLEVEL% REFERENCE=`%TEST_DATA_REF_FILE%` OUTPUT=`%TEST_SRC_BASE_DIR%\_output\%TEST_TEMP_DIR_NAME%`
  echo.
  exit /b 0
)

echo.PASSED: %__COUNTER1%: REFERENCE=`%TEST_DATA_REF_FILE%`

set /A __PASSED_TESTS+=1

exit /b 0

:TEST_END
set /A __OVERALL_TESTS+=1
set /A __COUNTER1+=1

rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set LASTERROR=%LASTERROR%
  set __PASSED_TESTS=%__PASSED_TESTS%
  set __OVERALL_TESTS=%__OVERALL_TESTS%
  set __COUNTER1=%__COUNTER1%
)

goto :EOF

:EXIT
rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set LASTERROR=%LASTERROR%
  set __PASSED_TESTS=%__PASSED_TESTS%
  set __OVERALL_TESTS=%__OVERALL_TESTS%
  set __NEST_LVL=%__NEST_LVL%
)

set /A __NEST_LVL-=1

if %__NEST_LVL%0 EQU 0 (
  echo    %__PASSED_TESTS% of %__OVERALL_TESTS% tests is passed.
  pause
)
