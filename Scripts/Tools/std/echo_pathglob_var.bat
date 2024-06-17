@echo off

rem USAGE:
rem   echo_pathglob_var.bat <VAR> [<PREFIX> [<SUFFIX>]]

rem <VAR>: VALUE1;VALUE2;...;VALUEN

setlocal DISABLEDELAYEDEXPANSION

set "__?VAR__=%~1"
if not defined __?PREFIX__ set "__?PREFIX__=%~2"
if not defined __?SUFFIX__ set "__?SUFFIX__=%~3"

if not defined __?VAR__ exit /b 255
if not defined %__?VAR__% exit /b 1

if /i not "%__?VAR__%" == "__STRING__" (
  set "__STRING__="
  setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!%__?VAR__%!") do endlocal & set "__STRING__=%%i"
)

call "%%~dp0%%encode\encode_pathlist_chars_glob.bat"

setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__STRING__!") do endlocal & for %%j in (%%i) do set "__STRING__=%%j" & ^
call "%%~dp0%%encode\decode_pathlist_chars_glob.bat" & ^
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%k in ("!__?PREFIX__!!__STRING__!!__?SUFFIX__!") do endlocal & echo.%%k

exit /b 0
