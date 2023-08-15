@echo off

setlocal

rem script flags
if not defined FLAG_SHIFT set FLAG_SHIFT=0
set FLAG_NO_LOG=0
set FLAG_ELEVATED=0
set "CALLF_BARE_FLAGS="
set "CALLF_PROMOTE_PARENT_FLAGS="

if defined INIT_VARS_FILE set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /v INIT_VARS_FILE "%INIT_VARS_FILE%"

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-no-log" (
    set FLAG_NO_LOG=1
  ) else if "%FLAG%" == "-elevate" (
    set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% ^
/v CONTOOLS_ROOT "%CONTOOLS_ROOT%" ^
/promote{ /load-parent-proc-init-env-vars /ret-child-exit /print-win-error-string } /promote-parent{%CALLF_PROMOTE_PARENT_FLAGS% /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1 } ^
/elevate{ /no-window /create-inbound-server-pipe-to-stdout "%~2_stdout_{pid}" /create-inbound-server-pipe-to-stderr "%~2_stderr_{pid}" ^
}{ /attach-parent-console /reopen-stdout-as-client-pipe "%~2_stdout_{ppid}" /reopen-stderr-as-client-pipe "%~2_stderr_{ppid}" }
    set FLAG_ELEVATED=1
    shift
    set /A FLAG_SHIFT+=1
  ) else if "%FLAG%" == "-X" (
    set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% %2
    shift
    set /A FLAG_SHIFT+=1
  ) else if "%FLAG%" == "-Y" (
    set CALLF_PROMOTE_PARENT_FLAGS=%CALLF_PROMOTE_PARENT_FLAGS% %2
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

if %FLAG_ELEVATED% NEQ 0 goto SKIP_REGULAR_SETUP

set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /ret-child-exit /print-win-error-string

:SKIP_REGULAR_SETUP

if %FLAG_NO_LOG% NEQ 0 goto SKIP_LOG_SETUP

set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1

:SKIP_LOG_SETUP

if not defined COMSPECLNK set "COMSPECLNK=%COMSPEC%"

(
  endlocal
  "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe"%CALLF_BARE_FLAGS% ^
    /no-expand-env /no-subst-pos-vars /no-esc ^
    /v IMPL_MODE 1 ^
    /ra "%%" "%%?01%%" /v "?01" "%%" ^
    /shift-%FLAG_SHIFT% ^
    "%COMSPECLNK%" "/c \"@\"%?~f0%\" {*}\"" %*
)

set LASTERROR=%ERRORLEVEL%

if %NEST_LVL%0 EQU 0 (
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_log.bat"
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_init_vars.bat"
)

(
  rem drop local variables
  set "LASTERROR="
  exit /b %LASTERROR%
)
