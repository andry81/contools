@echo off & goto DOC_END

rem Description:
rem   Loads variables from a file using exclusion list with builtin and
rem   specific custom variables.
rem   Additionally filters out internal variables beginning by `?` prefix.
:DOC_END

for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%~1") do call :FILTER "%%i" && set "%%i=%%j"
exit /b 0

:FILTER
setlocal

set "__?VAR__=%~1"

if not defined __?VAR__ exit /b 1

rem safe check, drop all internal variables beginning by `?`
if ^%__?VAR__:~0,1%/ == ^?/ exit /b 1

for /F "usebackq eol=# tokens=* delims=" %%k in ("%~dp0.set_vars_from_file\exclusion.vars") do if /i "%__?VAR__%" == "%%k" exit /b 1
exit /b 0
