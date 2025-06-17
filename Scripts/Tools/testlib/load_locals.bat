@echo off & goto DOC_END

rem CAUTION:
rem   We must use an uniform code page to avoid a code page change between calls
rem   and so accidental recode on a file read/write.
rem
:DOC_END

set "TEST_SCRIPT_LOCAL_VARS_FILE_PATH=%~1"

if not exist "%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%" exit /b 0

for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%TEST_SCRIPT_LOCAL_VARS_FILE_PATH%") do call :FILTER "%%i" && set "%%i=%%j"
exit /b 0

:FILTER
setlocal

set "__?VAR__=%~1"

if not defined __?VAR__ exit /b 1

rem safe check, drop all internal variables beginning by `?`
if ^%__?VAR__:~0,1%/ == ^?/ exit /b 1

for /F "usebackq eol=# tokens=* delims=" %%k in ("%~dp0.locals\exclusion.vars") do if /i "%__?VAR__%" == "%%k" exit /b 1
exit /b 0
