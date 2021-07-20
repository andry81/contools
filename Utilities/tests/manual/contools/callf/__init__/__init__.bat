@echo off

if defined CONTOOLS_PROJECT_ROOT_INIT0_DIR exit /b 0

call "%%~dp0..\..\__init__\__init__.bat"

call :CANONICAL_PATH TESTS_ROOT "%%~dp0.."

if not defined TEST_CALLF_REF_DIR                 call :CANONICAL_PATH TEST_CALLF_REF_DIR                 "%%TESTS_ROOT%%/refs"

if not defined TEST_CALLF_REF_INPUT_FILE_0        call :CANONICAL_PATH TEST_CALLF_REF_INPUT_FILE_0        "%%TEST_CALLF_REF_DIR%%/0.in"

call :CANONICAL_PATH TEST_SRC_BASE_DIR  "%%TESTS_ROOT%%"
call :CANONICAL_PATH TEST_DATA_OUT_DIR  "%%TEST_SRC_BASE_DIR%%/_out"

if not defined CALLF_EXECUTABLE set "CALLF_EXECUTABLE=callf.exe"

if not defined CALLF_EXE_PATH   call :CANONICAL_PATH CALLF_EXE_PATH "%%CONTOOLS_UTILITIES_BIN_ROOT%%/contools/%%CALLF_EXECUTABLE%%"

if not exist "%TEST_DATA_OUT_DIR%\" mkdir "%TEST_DATA_OUT_DIR%"

exit /b 0

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("%~2\.") do set "RETURN_VALUE=%%~fi"
rem set "RETURN_VALUE=%RETURN_VALUE:\=/%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0
