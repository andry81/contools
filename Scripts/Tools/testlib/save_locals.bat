@echo off & goto DOC_END

rem CAUTION:
rem   We must use an uniform code page to avoid a code page change between calls
rem   and so accidental recode on a file read/write.
rem
:DOC_END

set "TEST_SCRIPT_LOCAL_VARS_FILE_PATH=%~1"
set "TEST_SCRIPT_USER_VARS_FILE_PATH=%~2"

type nul > "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%"

if exist "%TEST_SCRIPT_USER_VARS_FILE_PATH%" if exist "%~1" for /F "usebackq tokens=1,* delims=="eol^= %%i in ("%TEST_SCRIPT_USER_VARS_FILE_PATH%") do call :FILTER "%%i" && (
  if not "%%j" == "" (
    (echo;%%i=%%j) >> "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%"
  ) else setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & (echo;%%i=%%~j) >> "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%"
)

rem save testlib internal variables at the last
for /F "usebackq tokens=1,* delims=="eol^= %%i in (`@set TESTLIB__ 2^>nul`) do (echo;%%i=%%j) >> "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%"

exit /b 0

:FILTER
setlocal

set "__?VAR__=%~1"

if not defined __?VAR__ exit /b 1

rem safe check, drop all internal variables beginning by `?`
if ^%__?VAR__:~0,1%/ == ^?/ exit /b 1

for /F "usebackq eol=# tokens=* delims=" %%k in ("%~dp0.locals\exclusion.vars") do if /i "%__?VAR__%" == "%%k" exit /b 1
exit /b 0
