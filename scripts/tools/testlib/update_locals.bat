@echo off & if defined SETUP_CP if defined CHCP if %NO_CHCP%0 EQU 0 call "%%CONTOOLS_TESTLIB_ROOT%%/set_inner_cp.bat"

( call :UPDATE %%* ) >> "%~1" & exit /b

:UPDATE
shift
:LOOP
shift & if "%~1" == "" exit /b 0
for /F "tokens=* delims="eol^= %%i in ("%~1") do setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & echo;%%i=%%~j
shift & if "%~1" == "" exit /b 0
for /F "tokens=* delims="eol^= %%i in ("%~1") do setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & echo;%%i=%%~j
shift & if "%~1" == "" exit /b 0
for /F "tokens=* delims="eol^= %%i in ("%~1") do setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & echo;%%i=%%~j
shift & if "%~1" == "" exit /b 0
for /F "tokens=* delims="eol^= %%i in ("%~1") do setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & echo;%%i=%%~j
shift & if "%~1" == "" exit /b 0
for /F "tokens=* delims="eol^= %%i in ("%~1") do setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & echo;%%i=%%~j
shift & if "%~1" == "" exit /b 0
for /F "tokens=* delims="eol^= %%i in ("%~1") do setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & echo;%%i=%%~j
shift & if "%~1" == "" exit /b 0
for /F "tokens=* delims="eol^= %%i in ("%~1") do setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & echo;%%i=%%~j
shift & if "%~1" == "" exit /b 0
for /F "tokens=* delims="eol^= %%i in ("%~1") do setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & echo;%%i=%%~j
shift & if "%~1" == "" exit /b 0
for /F "tokens=* delims="eol^= %%i in ("%~1") do setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & echo;%%i=%%~j
shift & if "%~1" == "" exit /b 0
for /F "tokens=* delims="eol^= %%i in ("%~1") do setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & echo;%%i=%%~j
goto LOOP

rem USAGE:
rem   update_locals.bat <local-vars-file> <vars>...

rem CAUTION:
rem   We must use a uniform code page to avoid a code page change between
rem   calls and so accidental recode on a file read/write.
rem
