@echo off

setlocal DISABLEDELAYEDEXPANSION

type nul > "%TEST_SCRIPT_RETURN_VARS_FILE_PATH%"
type nul > "%TEST_SCRIPT_RETURN_VALUES_FILE_PATH%"

for %%i in (TESTLIB__NEST_LVL TESTLIB__OVERALL_PASSED_TESTS TESTLIB__OVERALL_TESTS) do (
  (echo.%%i) >> "%TEST_SCRIPT_RETURN_VARS_FILE_PATH%"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in (""!%%i!"") do endlocal & (echo.%%~j) >> "%TEST_SCRIPT_RETURN_VALUES_FILE_PATH%"
)

if exist "%~1" for /F "usebackq tokens=* delims="eol^= %%i in ("%~1") do (
  (echo.%%i) >> "%TEST_SCRIPT_RETURN_VARS_FILE_PATH%"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in (""!%%i!"") do endlocal & (echo.%%~j) >> "%TEST_SCRIPT_RETURN_VALUES_FILE_PATH%"
)
