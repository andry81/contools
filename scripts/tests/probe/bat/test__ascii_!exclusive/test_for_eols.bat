@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

chcp 437

set /A NEXT_INDEX=1

rem not read characters:
rem 00 - NUL
for /F "usebackq tokens=* delims="eol^= %%i in ("%TEST_DATA_IN_ROOT%/%TEST_SCRIPT_FILE_NAME%/eols.txt") do (
  set "LINE=%%i"

  setlocal ENABLEDELAYEDEXPANSION
  if not "!LINE!" == "" if "!LINE:~0,1!" == "[" (
    set NEXT_INDEX_STR=!NEXT_INDEX!
    if "!NEXT_INDEX_STR:~2,1!" == "" set NEXT_INDEX_STR=0!NEXT_INDEX_STR!
    if "!NEXT_INDEX_STR:~2,1!" == "" set NEXT_INDEX_STR=0!NEXT_INDEX_STR!
    <nul set /P =^<!NEXT_INDEX_STR!^>
  )
  endlocal

  echo;%%i

  if defined LINE setlocal ENABLEDELAYEDEXPANSION & if "!LINE:~0,1!" == "[" ( endlocal & set /A "NEXT_INDEX+=1" ) else endlocal
)
