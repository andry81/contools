@echo off & goto DOC_END

rem USAGE:
rem   set_vars_from_file_as_cmdline.bat <out-var> <vars-file>

rem Description:
rem   Script sets `... & set "VAR=VALUE"` string into `<out-var>` variable to
rem   be able to execute it later to set variables after a nested `setlocal`
rem   context. The variables reads from a file using exclusion list with
rem   builtin and specific custom variables.
rem   Additionally filters out internal variables beginning by `?` prefix.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.
:DOC_END

if "%~1" == "" exit /b 255

for /F "tokens=* delims="eol^= %%i in ("%~1") do ^
for /F "usebackq eol=# tokens=1,* delims==" %%j in ("%~2") do call :FILTER && (
  setlocal DISABLEDELAYEDEXPANSION & set "__?VALUE__=%%k" & setlocal ENABLEDELAYEDEXPANSION & if defined __?VALUE__ set "__?VALUE__=!__?VALUE__:"=!"
  if defined %~1 (
    for /F "usebackq tokens=* delims="eol^= %%l in ('"!%~1!"') do for /F "usebackq tokens=* delims="eol^= %%v in ('"!__?VALUE__!"') do endlocal & endlocal ^
    & set %~1=%%~l^& set "%%j=%%~v"
  ) else for /F "usebackq tokens=* delims="eol^= %%v in ('"!__?VALUE__!"') do endlocal & endlocal & set %~1=set "%%j=%%~v"
)
exit /b 0

:FILTER
setlocal DISABLEDELAYEDEXPANSION
for %%a in (:) do set "__?VAR__=%%j"
rem safe check, drop all internal variables beginning by `?`
if ^%__?VAR__:~0,1%/ == ^?/ exit /b 1
for /F "usebackq eol=# tokens=* delims=" %%l in ("%~dp0.set_vars_from_file\exclusion.vars") do if /i "%__?VAR__%" == "%%l" exit /b 1
exit /b 0
