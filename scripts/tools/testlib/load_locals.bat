@echo off
if exist "%~1" for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%~1") do set "__?VAR__=%%i" & if defined __?VAR__ call :FILTER && set "%%i=%%j"
if exist "%~2" for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%~2") do set "%%i=%%j"
set "__?VAR__="
exit /b 0

:FILTER
( if ^%__?VAR__:~0,1%/ == ^?/ exit /b 1 ) ^
  & ( for /F "usebackq eol=# tokens=* delims=" %%k in ("%~dp0.locals\exclusion.vars") do if /i "%__?VAR__%" == "%%k" exit /b 1 ) ^
  & exit /b 0

rem USAGE:
rem   load_locals.bat [<local-vars-file> [<nest-lvl-vars-file>]]

rem CAUTION:
rem   We must use a uniform code page to avoid a code page change between
rem   calls and so accidental recode on a file read/write.
rem
