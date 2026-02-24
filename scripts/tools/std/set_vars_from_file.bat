@echo off & goto DOC_END

rem USAGE:
rem   set_vars_from_file.bat <vars-file>

rem Description:
rem   Script sets variables by reading them from a file using exclusion list
rem   with builtin and specific custom variables.
rem   Additionally filters out internal variables beginning by `?` prefix.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.
:DOC_END

for /F "usebackq eol=# tokens=* delims=" %%i in ("%~1") do for /F "tokens=1,* delims=="eol^= %%j in ("%%i") do call :FILTER && if "%%i" == "%%j=%%k" set "%%j=%%k"
exit /b 0

:FILTER
setlocal DISABLEDELAYEDEXPANSION
for %%a in (:) do set "__?VAR__=%%j"
rem safe check, drop all internal variables beginning by `?`
if ^%__?VAR__:~0,1%/ == ^?/ exit /b 1
for /F "usebackq eol=# tokens=* delims=" %%i in ("%~dp0.set_vars_from_file\exclusion.vars") do if /i "%__?VAR__%" == "%%i" exit /b 1
exit /b 0
