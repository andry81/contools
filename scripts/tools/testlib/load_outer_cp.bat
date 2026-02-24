@echo off
if exist "%~1" for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%~1") do if "%%i" == "TESTLIB__OUTER_CP" set "%%i=%%j" & exit /b 0
exit /b 0

rem USAGE:
rem   load_outer_cp.bat <vars-file>

rem CAUTION:
rem   We must use a uniform code page to avoid a code page change between
rem   calls and so accidental recode on a file read/write.
