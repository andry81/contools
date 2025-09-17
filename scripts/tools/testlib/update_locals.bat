@echo off & goto DOC_END

rem CAUTION:
rem   We must use a uniform code page to avoid a code page change between
rem   calls and so accidental recode on a file read/write.
rem
:DOC_END

set "TEST_SCRIPT_LOCAL_VARS_FILE_PATH=%~1"

shift

rem assigns the inner code page (`CHCP`, must be not 65000) if is different with a current code page (`TESTLIB__TEST_CP`)
if defined SETUP_CP if defined CHCP if %NO_CHCP%0 EQU 0 call "%%CONTOOLS_TESTLIB_ROOT%%/set_inner_cp.bat"

if not exist "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%" type nul > "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%"

:LOOP
if "%~1" == "" exit /b 0

rem update a variable
for /F "tokens=* delims="eol^= %%i in ("%~1") do if defined %%i (
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!%%i!") do endlocal & (echo;%%i=%%j) >> "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%"
) else (echo;%%i=) >> "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%"

shift

goto LOOP
