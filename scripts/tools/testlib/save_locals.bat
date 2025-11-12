@echo off & type nul > "%~1" & if not exist "%~2" goto SKIP_USER_VARS

(
  for /F "usebackq tokens=1,* delims=="eol^= %%i in ("%~2") do (
    set "__?VAR__=%%i"
    if defined __?VAR__ call :FILTER && if not "%%j" == "" (
      echo;%%i=%%j
    ) else setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & echo;%%i=%%~j
  )
) >> "%~1"

goto SKIP_USER_VARS

:FILTER
( if ^%__?VAR__:~0,1%/ == ^?/ exit /b 1 ) ^
  & ( for /F "usebackq eol=# tokens=* delims=" %%k in ("%~dp0.locals\exclusion.vars") do if /i "%__?VAR__%" == "%%k" exit /b 1 ) ^
  & exit /b 0

:SKIP_USER_VARS

set TESTLIB__ 2>nul >> "%~1"

if "%~3" == "" goto SKIP_NEST_LVL_VARS

(
  for /F "usebackq eol=# tokens=* delims=" %%i in ("%~dp0.locals\nest.vars") do setlocal ENABLEDELAYEDEXPANSION ^
  & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & echo;%%i=%%~j
) > "%~3"

:SKIP_NEST_LVL_VARS

set "__?VAR__="

exit /b 0

rem USAGE:
rem   save_locals.bat <local-vars-file> [<user-vars-file> [<nest-lvl-vars-file>]]

rem CAUTION:
rem   We must use a uniform code page to avoid a code page change between
rem   calls and so accidental recode on a file read/write.
rem
