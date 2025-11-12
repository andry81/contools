@echo off & goto DOC_END

rem Description:
rem   The tests initialization script. Must be called one time in a user test
rem   script before the first call to the `test.bat` script.
rem
rem   The first argument must be the full path to the user test script file
rem   from which this script calls.
rem
rem   The second argument (optional) can point to a directory with user handler
rem   scripts. Can be absolute or relative. If is a relative then relative to
rem   the directory path from the first argument.
rem
rem CAUTION:
rem   We must use an uniform code page to avoid a code page change between calls
rem   and so accidental recode on a file read/write.
rem
rem CAUTION:
rem   The script can be nest called, but nesting is limited up to 31 calls.
rem
rem CAUTION:
rem   If the script is returned the zero code, then you must call to `exit.bat`
rem   respectively, otherwise the code page may be left changed.
:DOC_END

rem initialize testlib module
call "%%~dp0__init__.bat" || exit /b

if %TESTLIB__INIT%0 GEQ 320 (
  echo;%~nx0: error: test initialization is reached the nest limit: 31.
  exit /b 255
) >&2

rem reread current code page for each test, before init and after init

set "TESTLIB__CHCP_EXE="
if exist "%SystemRoot%\System32\chcp.com" set "TESTLIB__CHCP_EXE=%SystemRoot%\System32\chcp.com"
if not defined TESTLIB__CHCP_EXE if exist "%SystemRoot%\System64\chcp.com" set "TESTLIB__CHCP_EXE=%SystemRoot%\System64\chcp.com"

if not defined TESTLIB__CHCP_EXE  (
  echo;%~nx0: error: `chcp.com` is not found.
  exit /b 255
) >&2

if not defined SETUP_CP goto SKIP_SETUP_CP
if not defined CHCP goto SKIP_SETUP_CP
if %NO_CHCP%0 NEQ 0 goto SKIP_SETUP_CP

rem reads the current code page into `TESTLIB__TEST_CP` variable
call "%%CONTOOLS_TESTLIB_ROOT%%/getcp.bat"

rem previous code page before init
set "TESTLIB__PREV_CP=%TESTLIB__TEST_CP%"

rem assigns the inner code page (`CHCP`, must be not 65000) if is different with a current code page (`TESTLIB__TEST_CP`)
call "%%CONTOOLS_TESTLIB_ROOT%%/set_inner_cp.bat"

:SKIP_SETUP_CP

call :MAIN %%*
set TEST_LAST_ERROR=%ERRORLEVEL%

:EXIT_MAIN
if %TESTLIB__TEST_SETUP%0 EQU 0 goto SKIP_UPDATE_CURRENT_CP

rem reads the current code page into `TESTLIB__TEST_CP` variable
if defined SETUP_CP if defined CHCP if %NO_CHCP%0 EQU 0 call "%%CONTOOLS_TESTLIB_ROOT%%/getcp.bat"

:SKIP_UPDATE_CURRENT_CP

if %TEST_LAST_ERROR% NEQ 0 (
  rem restores a previous code page before the init (`TESTLIB__PREV_CP`) if is different with a current code page (`TESTLIB__TEST_CP`)
  if defined SETUP_CP if defined CHCP if %NO_CHCP%0 EQU 0 call "%%CONTOOLS_TESTLIB_ROOT%%/set_prev_cp.bat"

  rem skip init finalization if the init is incomplete
  if not defined TESTLIB__INITING (
    rem calls to `set_inner_cp.bat` at the beginning
    call "%%CONTOOLS_TESTLIB_ROOT%%/update_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%" ^
      TEST_LAST_ERROR TESTLIB__INIT TESTLIB__INIT_INDEX TESTLIB__TEST_SETUP TESTLIB__PREV_CP TESTLIB__TEST_CP
    copy /Y /B "%TEST_SCRIPT_SHARED_VARS_FILE_PATH%" "%TEST_SCRIPT_INIT_VARS_FILE_PATH%" >nul
  )

  exit /b %TEST_LAST_ERROR%
)

set /A TESTLIB__INIT+=1
set /A TESTLIB__INIT_INDEX+=1

rem calls to `set_inner_cp.bat` at the beginning
call "%%CONTOOLS_TESTLIB_ROOT%%/update_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%" ^
  TEST_LAST_ERROR TESTLIB__INIT TESTLIB__INIT_INDEX TESTLIB__TEST_SETUP TESTLIB__PREV_CP TESTLIB__TEST_CP
copy /Y /B "%TEST_SCRIPT_SHARED_VARS_FILE_PATH%" "%TEST_SCRIPT_INIT_VARS_FILE_PATH%" >nul

rem restores an outer code page (`TESTLIB__TEST_CP`) if is different with the inner code page (`CHCP`, must be not 65000)
if defined SETUP_CP if defined CHCP if %NO_CHCP%0 EQU 0 call "%%CONTOOLS_TESTLIB_ROOT%%/set_outer_cp.bat"

exit /b 0

:MAIN
set TESTLIB__INITING=1

call "%%CONTOOLS_TESTLIB_ROOT%%/load_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%"

rem cast to integer
set /A "TESTLIB__INIT+=0"       & rem nest level
set /A "TESTLIB__INIT_INDEX+=0" & rem init index
set /A "TESTLIB__TEST_SETUP+=0" & rem bitmask, 31 bits

set "TEST_SCRIPT_FILE_PATH_=%~1"
set "TEST_SCRIPT_HANDLERS_DIR=%~2"

if defined TEST_SCRIPT_FILE_PATH_ if "%TEST_SCRIPT_FILE_PATH_:~1,1%" == ":" goto TEST_SCRIPT_FILE_PATH_OK

(
  echo;%~nx0: error: test script file path is empty or not absolute: "%TEST_SCRIPT_FILE_PATH_%".
  exit /b 255
) >&2

:TEST_SCRIPT_FILE_PATH_OK

rem shortcuts to the user test script file name
call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%* || exit /b

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_def.bat" TEST_SCRIPT_FILE_PATH "%%TEST_SCRIPT_FILE_PATH%%"

if /i "%TEST_SCRIPT_FILE_PATH%" == "%?~f0%" (
  echo;%~nx0: error: test script file path already initialized: "%TEST_SCRIPT_FILE_PATH%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/setshift.bat" 1 TEST_SCRIPT_INIT_CMDLINE %%*

rem make built in canonical user script path variables
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_FILE_PATH "%%?~f0%%"

set "TEST_SCRIPT_FILE_NAME=%?~n0%"
set "TEST_SCRIPT_FILE_EXT=%?~x0%"
set "TEST_SCRIPT_FILE=%?~nx0%"

if defined TESTLIB__TEST_SCRIPT_FILE_STACK (
  set "TESTLIB__TEST_SCRIPT_FILE_STACK=%TESTLIB__TEST_SCRIPT_FILE_STACK%->%TEST_SCRIPT_FILE%"
) else set "TESTLIB__TEST_SCRIPT_FILE_STACK=%TEST_SCRIPT_FILE%"

set "TEST_SCRIPT_NEST_LVL_DIR_NAME=%TESTLIB__INIT%"
set "TEST_SCRIPT_INDEX_DIR_NAME=%TESTLIB__INIT_INDEX%"

if "%TEST_SCRIPT_NEST_LVL_DIR_NAME:~1,1%" == "" set "TEST_SCRIPT_NEST_LVL_DIR_NAME=0%TEST_SCRIPT_NEST_LVL_DIR_NAME%"
if "%TEST_SCRIPT_INDEX_DIR_NAME:~2,1%" == "" set "TEST_SCRIPT_INDEX_DIR_NAME=0%TEST_SCRIPT_INDEX_DIR_NAME%"
if "%TEST_SCRIPT_INDEX_DIR_NAME:~2,1%" == "" set "TEST_SCRIPT_INDEX_DIR_NAME=0%TEST_SCRIPT_INDEX_DIR_NAME%"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_FILE_DIR "%%?~dp0%%"

if defined TEST_SCRIPT_ROOT_INIT_DATE_TIME goto SKIP_TEST_SCRIPT_ROOT_INIT_DATE_TIME

rem Do use last boot up time as log time
if defined USE_LOG_BOOT_UP_TIME set /A USE_LOG_BOOT_UP_TIME+=0

if %USE_LOG_BOOT_UP_TIME%0 NEQ 0 goto USE_LOG_BOOT_UP_TIME

call "%%CONTOOLS_WMI_ROOT%%\get_wmi_local_datetime.vbs.bat"
set "TEST_SCRIPT_ROOT_INIT_DATE_TIME=%RETURN_VALUE:~0,4%'%RETURN_VALUE:~4,2%'%RETURN_VALUE:~6,2%_%RETURN_VALUE:~8,2%'%RETURN_VALUE:~10,2%'%RETURN_VALUE:~12,2%''%RETURN_VALUE:~15,3%"
goto USE_LOG_BOOT_UP_TIME_END

:USE_LOG_BOOT_UP_TIME
call "%%CONTOOLS_WMI_ROOT%%\get_wmi_local_date_and_last_boot_uptime.vbs.bat"
set "TEST_SCRIPT_ROOT_INIT_DATE_TIME=%RETURN_VALUE:~0,4%'%RETURN_VALUE:~4,2%'%RETURN_VALUE:~6,2%"

setlocal

for /F "tokens=1,2,* delims=,."eol^= %%i in ("%RETURN_VALUE%") do set "LAST_BOOT_UPTIME_SEC=%%j" & set "LAST_BOOT_UPTIME_SEC_FRACS=%%k"

set "LAST_BOOT_UPTIME_SEC_FRACS=%LAST_BOOT_UPTIME_SEC_FRACS%000"

endlocal & set "TEST_SCRIPT_ROOT_INIT_DATE_TIME=%TEST_SCRIPT_ROOT_INIT_DATE_TIME%_%LAST_BOOT_UPTIME_SEC%''%LAST_BOOT_UPTIME_SEC_FRACS:~0,3%"

:USE_LOG_BOOT_UP_TIME_END

:SKIP_TEST_SCRIPT_ROOT_INIT_DATE_TIME

rem defined ONCE
if defined TEST_DATA_IN_ROOT call "%%CONTOOLS_ROOT%%/std/canonical_dir_vars.bat"    TEST_DATA_IN_ROOT || exit /b
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" TEST_DATA_OUT_ROOT          "%%TEST_SCRIPT_FILE_DIR%%/_tests/out" || exit /b
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" TEST_DATA_TEMP_ROOT         "%%TEST_SCRIPT_FILE_DIR%%/_tests/temp" || exit /b

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" TEST_SCRIPT_SHARED_DIR      "%%TEST_DATA_TEMP_ROOT%%/shared/%%TEST_SCRIPT_ROOT_INIT_DATE_TIME%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_LOCAL_DIR               "%%TEST_DATA_TEMP_ROOT%%/local/%%TEST_SCRIPT_ROOT_INIT_DATE_TIME%%/%%TEST_SCRIPT_INDEX_DIR_NAME%%--%%TEST_SCRIPT_NEST_LVL_DIR_NAME%%--%%TEST_SCRIPT_FILE_NAME%%"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_SHARED_VARS_FILE_PATH   "%%TEST_SCRIPT_SHARED_DIR%%/current.vars"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_NEST_LVL_VARS_FILE_PATH "%%TEST_SCRIPT_SHARED_DIR%%/%%TEST_SCRIPT_NEST_LVL_DIR_NAME%%.vars"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_SHARED_VARS_FILE_PATH_TMP "%%TEST_SCRIPT_SHARED_DIR%%/test.tmp.vars"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_INIT_VARS_FILE_PATH     "%%TEST_SCRIPT_LOCAL_DIR%%/00-init.vars"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_TEST_VARS_FILE_PATH     "%%TEST_SCRIPT_LOCAL_DIR%%/01-test.vars"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_EXIT_VARS_FILE_PATH     "%%TEST_SCRIPT_LOCAL_DIR%%/02-exit.vars"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_RETURN_VARS_FILE_PATH   "%%TEST_SCRIPT_LOCAL_DIR%%/03-return.vars"

if not defined TEST_SCRIPT_HANDLERS_DIR (
  set "TEST_SCRIPT_HANDLERS_DIR=%TEST_SCRIPT_FILE_DIR%"
) else if not ":" == "%TEST_SCRIPT_HANDLERS_DIR:~1,1%" (
  rem relative to the script directory path
  call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_HANDLERS_DIR "%%TEST_SCRIPT_FILE_DIR%%/%%TEST_SCRIPT_HANDLERS_DIR%%"
)

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%TEST_DATA_OUT_ROOT%%" || exit /b
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%TEST_SCRIPT_LOCAL_DIR%%" || exit /b
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%TEST_SCRIPT_SHARED_DIR%%" || exit /b

type nul > "%TEST_SCRIPT_INIT_VARS_FILE_PATH%"
if exist "%TEST_SCRIPT_TEST_VARS_FILE_PATH%" del /F /Q /A:-D "%TEST_SCRIPT_TEST_VARS_FILE_PATH%" >nul
if exist "%TEST_SCRIPT_EXIT_VARS_FILE_PATH%" del /F /Q /A:-D "%TEST_SCRIPT_EXIT_VARS_FILE_PATH%" >nul

rem case to integer
set /A TESTLIB__OVERALL_PASSED_TESTS+=0
set /A TESTLIB__OVERALL_TESTS+=0

set TESTLIB__CURRENT_PASSED_TESTS=0
set TESTLIB__CURRENT_TESTS=0

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"
set "TESTLIB__BEGIN_TIME=%BEGIN_TIME%"
set "TESTLIB__END_TIME="
set "TESTLIB__TIME="

set "TEST_ENTRY="

call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%" "" "%%TEST_SCRIPT_NEST_LVL_VARS_FILE_PATH%%"
copy /Y /B "%TEST_SCRIPT_SHARED_VARS_FILE_PATH%" "%TEST_SCRIPT_INIT_VARS_FILE_PATH%" >nul

echo Running %?~nx0%...
echo;

setlocal DISABLEDELAYEDEXPANSION & setlocal ENABLEDELAYEDEXPANSION & ^
for /F "tokens=* delims="eol^= %%i in ("!TEST_SCRIPT_FILE!") do ^
for /F "usebackq tokens=* delims="eol^= %%j in ('"!TEST_SCRIPT_INIT_CMDLINE!"') do endlocal & ^
title [%TESTLIB__OVERALL_PASSED_TESTS% of %TESTLIB__OVERALL_TESTS%] %%i %%~j
endlocal

set "TESTLIB__INITING="

:TEST_SETUP
rem call user setup script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/setup%TEST_SCRIPT_FILE_EXT%" (
  set /A "TESTLIB__TEST_SETUP|=1 << TESTLIB__INIT"
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/setup%%TEST_SCRIPT_FILE_EXT%%" || exit /b
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/setup%TEST_SCRIPT_FILE_EXT%" (
    set /A "TESTLIB__TEST_SETUP|=1 << TESTLIB__INIT"
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/setup%%TEST_SCRIPT_FILE_EXT%%" || exit /b
  )
)

exit /b 0
