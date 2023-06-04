@echo off

setlocal

rem script flags
set FLAG_SHIFT=0
set "CALLF_BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-init_vars_file" (
    set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /v INIT_VARS_FILE "%INIT_VARS_FILE%"
  ) else if "%FLAG%" == "-X" (
    set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% %2
    shift
    set /A FLAG_SHIFT+=1
  ) else if "%FLAG%" == "--" (
    shift
    set "FLAG="
    set /A FLAG_SHIFT+=1
    goto FLAGS_LOOP_END
  ) else (
    set "FLAG="
    goto FLAGS_LOOP_END
  )

  shift
  set /A FLAG_SHIFT+=1

  rem read until no flags
  goto FLAGS_LOOP
)

:FLAGS_LOOP_END

if not defined COMSPECLNK set "COMSPECLNK=%COMSPEC%"

rem variables escaping
set "?~f0=%?~f0:{=\{%"
set "COMSPECLNK=%COMSPECLNK:{=\{%"

(
  endlocal
  "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe"%CALLF_BARE_FLAGS% ^
    /ret-child-exit /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1 ^
    /no-expand-env /no-subst-pos-vars ^
    /v IMPL_MODE 1 ^
    /ra "%%" "%%?01%%" /v "?01" "%%" ^
    /shift-%FLAG_SHIFT% ^
    "%COMSPECLNK%" "/c \"@\"%?~f0%\" {*}\"" %*
)

setlocal

set LASTERROR=%ERRORLEVEL%

if %NEST_LVL%0 EQU 0 (
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_log.bat"
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_init_vars.bat"
)

(
  endlocal
  exit /b %LASTERROR%
)
