@echo off

rem with save of previous error level
setlocal DISABLEDELAYEDEXPANSION & set LAST_ERROR=%ERRORLEVEL%

set "__?VAR__=%~1"

if not defined __?VAR__ exit /b 255
if not defined %__?VAR__% exit /b 1

if not defined __?PREFIX__ set "__?PREFIX__=%~2"
if not defined __?SUFFIX__ set "__?SUFFIX__=%~3"

if /i not "%__?VAR__%" == "__STRING__" (
  set "__STRING__="
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!%__?VAR__%!") do endlocal & set "__STRING__=%%i"
)

call "%%~dp0%%encode\encode_pathlist_chars_glob.bat"

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & for %%j in (%%i) do set "__STRING__=%%j" & ^
call "%%~dp0%%encode\decode_pathlist_chars_glob.bat" & ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%k in ("!__?PREFIX__!!__STRING__!!__?SUFFIX__!") do endlocal & echo;%%k

endlocal & exit /b %LAST_ERROR%

rem USAGE:
rem   echo_pathglob_var.bat <var> [<prefix> [<suffix>]]

rem Description:
rem   Script prints PATH like variable with globbing characters expansion,
rem   and with prefix and suffix text.
rem   Does not change the error level.

rem <var> format:
rem   VALUE1;VALUE2;...;VALUEN
