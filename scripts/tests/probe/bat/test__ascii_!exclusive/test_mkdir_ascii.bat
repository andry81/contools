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
set "ASCII_FILE=ascii-nocrlf.txt"

set /P CHARS=<"%TEST_DATA_IN_ROOT%/test__ascii/%ASCII_FILE%" & rem w/o NUL and cleared CR

for /F "tokens=* delims="eol^= %%i in ("%TEST_DATA_IN_ROOT%/test__ascii/%ASCII_FILE%") do set "ASCII_FILE_SIZE=%%~zi"

if not defined CHARS exit /b 1

set "WD=%TEST_DATA_OUT_ROOT%/%~n0"

set ASCII_CODE=1
set PREV_INDEX=0
set /A NEXT_INDEX=PREV_INDEX+1

if exist "%WD%" rmdir /S /Q "%WD%" || exit /b

mkdir "%WD%" || exit /b

cd /d "%WD%" || exit /b

set DIR_COUNT=0

:LOOP
if %ASCII_CODE% GEQ %ASCII_FILE_SIZE% goto EXIT
if %PREV_INDEX% GEQ %ASCII_FILE_SIZE% goto EXIT
if %PREV_INDEX% GEQ 255 goto EXIT & rem just in case

set ASCII_CODE_STR=%ASCII_CODE%

if "%ASCII_CODE_STR:~2,1%" == "" set ASCII_CODE_STR=0%ASCII_CODE_STR%
if "%ASCII_CODE_STR:~2,1%" == "" set ASCII_CODE_STR=0%ASCII_CODE_STR%

if not "!CHARS:~%PREV_INDEX%,1!" == "" setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!CHARS:~%PREV_INDEX%,1!") do endlocal & set "CHAR_%ASCII_CODE%=%%i"

if defined CHAR_%ASCII_CODE% setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!CHAR_%ASCII_CODE%!") do endlocal & (
  echo;[%ASCII_CODE_STR%] ^|%%i^|
  if exist "[%ASCII_CODE_STR%] %%i" rmdir "[%ASCII_CODE_STR%] %%i"
  mkdir "[%ASCII_CODE_STR%] %%i" && set /A DIR_COUNT+=1
) else set CHAR_%ASCII_CODE%

set PREV_INDEX=%NEXT_INDEX%
set /A NEXT_INDEX+=1
set /A ASCII_CODE+=1

goto LOOP

:EXIT
echo Dirs created: %DIR_COUNT%
