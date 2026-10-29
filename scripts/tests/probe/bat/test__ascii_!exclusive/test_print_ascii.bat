@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem to make not printable characters visible
chcp 437

rem CAUTION:
rem   The `LF` affects `!` character expansion in
rem   `setlocal DISABLEDELAYEDEXPANSION` context.
rem
set "ASCII_FILE_NOCR=ascii-nocr.txt"
set "ASCII_FILE_NOCRLF=ascii-nocrlf.txt"

rem CAUTION: being loaded text line must not contain NUL or CR character
set /P CHARS_NOCR_=<"%TEST_DATA_IN_ROOT%/test__ascii/%ASCII_FILE_NOCR%"

set CHARS_NOCR_

echo;---

setlocal ENABLEDELAYEDEXPANSION
echo;CHARS_NOCR_=!CHARS_NOCR_!
endlocal

echo;---

rem CAUTION: being loaded text line must not contain NUL, CR or LF character
for /F "usebackq tokens=* delims="eol^= %%i in ("%TEST_DATA_IN_ROOT%/test__ascii/%ASCII_FILE_NOCRLF%") do set "CHARS_NOCRLF=%%i"

set CHARS_NOCRLF

echo;---

setlocal ENABLEDELAYEDEXPANSION
echo;CHARS_NOCRLF=!CHARS_NOCRLF!
endlocal