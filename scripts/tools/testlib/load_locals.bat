@echo off & goto DOC_END

rem CAUTION:
rem   We must use a uniform code page to avoid a code page change between
rem   calls and so accidental recode on a file read/write.
rem
:DOC_END

set "TEST_SCRIPT_LOCAL_VARS_FILE_PATH=%~1"
set "TEST_SCRIPT_NEST_LVL_VARS_FILE_PATH=%~2"

if exist "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%" ^
for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%") do call :FILTER "%%i" && set "%%i=%%j"

rem load testlib nested variables
if exist "%TEST_SCRIPT_NEST_LVL_VARS_FILE_PATH%" ^
for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%TEST_SCRIPT_NEST_LVL_VARS_FILE_PATH%") do set "%%i=%%j"

exit /b 0

:FILTER
setlocal

set "__?VAR__=%~1"

if not defined __?VAR__ exit /b 1

rem safe check, drop all internal variables beginning by `?`
if ^%__?VAR__:~0,1%/ == ^?/ exit /b 1

for /F "usebackq eol=# tokens=* delims=" %%k in ("%~dp0.locals\exclusion.vars") do if /i "%__?VAR__%" == "%%k" exit /b 1
exit /b 0
