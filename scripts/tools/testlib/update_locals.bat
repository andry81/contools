@echo off & goto DOC_END

rem CAUTION:
rem   We must use an uniform code page to avoid a code page change between calls
rem   and so accidental recode on a file read/write.
rem
:DOC_END

set "TEST_SCRIPT_LOCAL_VARS_FILE_PATH=%~1"

shift

rem must be assigned not to 65000 code page!
call "%%CONTOOLS_TESTLIB_ROOT%%/set_inner_cp.bat"

if not exist "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%" type nul > "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%"

:LOOP
if "%~1" == "" exit /b 0

rem update a variable
for /F "tokens=* delims="eol^= %%i in ("%~1") do if defined %%i (
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!%%i!") do endlocal & (echo;%%i=%%j) >> "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%"
) else (echo;%%i=) >> "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%"

shift

goto LOOP
