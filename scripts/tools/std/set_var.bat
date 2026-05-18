@echo off & setlocal DISABLEDELAYEDEXPANSION & if not "%~2" == "" (
  for /F "tokens=1 delims=:"eol^= %%i in ("%~2") do if defined %%i (
    setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%~2!"') do endlocal & endlocal & set "%~1=%%~j" & exit /b %ERRORLEVEL%
  ) else endlocal & set "%~1=" & exit /b %ERRORLEVEL%
  setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!%~2!"') do endlocal & endlocal & set "%~1=%%~i" & exit /b %ERRORLEVEL%
) else endlocal & set "%~1=" & exit /b %ERRORLEVEL%

rem USAGE:
rem   set_var.bat <out-var> <var>

rem Description:
rem   Sets `<var>` variable into `<out-var>` variable.
rem   Does not change the error level.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.

rem Examples:
rem   >
rem   set a=123
rem   set_var.bat b a
rem   set_var.bat c a:~1
rem   set_var.bat empty1 a:~100
rem   set_var.bat empty2 unexisted
rem   set_var.bat empty3 unexisted:~1
