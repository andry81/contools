@echo off

setlocal DISABLEDELAYEDEXPANSION

rem update CMDLINE with FLAGS
set "PREFIXED_CMDLINE="
if defined FLAGS (
  for %%i in (%CMDLINE%) do setlocal ENABLEDELAYEDEXPANSION ^
  & for /F "usebackq tokens=* delims="eol^= %%j in ('"!PREFIXED_CMDLINE!"') do endlocal & set PREFIXED_CMDLINE=%%~j "%FLAGS% %%~i"
) else setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!CMDLINE!"') do endlocal & set "PREFIXED_CMDLINE= %%~i"

set TEST_IMPL_ERROR=-1
call "%%CONTOOLS_ROOT%%/std/if_and.bat"%%PREFIXED_CMDLINE%% && set "TEST_IMPL_ERROR=1" || set "TEST_IMPL_ERROR=0"

if not defined PREFIXED_CMDLINE set "PREFIXED_CMDLINE= "

(
  setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!PREFIXED_CMDLINE:~1!"') do endlocal & endlocal & set "PREFIXED_CMDLINE=%%~i"
  set "TEST_IMPL_ERROR=%TEST_IMPL_ERROR%"
  exit /b 0
)
