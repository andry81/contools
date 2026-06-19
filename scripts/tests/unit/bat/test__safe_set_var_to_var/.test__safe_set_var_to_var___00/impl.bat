@echo off

rem to copy

set "LVAR="
rem CAUTION: the last double quote is required to correctly strip in `("!LVAR:""="!)` for-expression
if defined RVAR set "LVAR=%RVAR:"=""%""

rem to restore

rem CAUTION: `setlocal DISABLEDELAYEDEXPANSION` must be set before!
if defined LVAR setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!LVAR:""="!) do endlocal & set "LVAR=%%i"

exit /b 0
