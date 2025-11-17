@echo off

setlocal DISABLEDELAYEDEXPANSION

rem update CMDLINE with FLAGS
set "PREFIXED_CMDLINE="
if defined FLAGS (
  setlocal ENABLEDELAYEDEXPANSION ^
  & for /F "usebackq tokens=* delims="eol^= %%i in ('"!CMDLINE!"') do endlocal & set "PREFIXED_CMDLINE=%FLAGS% %%~i"
) else setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!CMDLINE!"') do endlocal & set "PREFIXED_CMDLINE=%%~i"

set TEST_IMPL_ERROR=-1
call "%%CONTOOLS_ROOT%%/std/ifn_and.bat" %%PREFIXED_CMDLINE%% && set "TEST_IMPL_ERROR=1" || set "TEST_IMPL_ERROR=0"

(
  setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!PREFIXED_CMDLINE!"') do endlocal & endlocal & set "PREFIXED_CMDLINE=%%~i"
  set "TEST_IMPL_ERROR=%TEST_IMPL_ERROR%"
  exit /b 0
)
