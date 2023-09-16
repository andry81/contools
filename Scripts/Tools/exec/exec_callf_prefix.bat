@echo off

setlocal

rem Do not make a file or a directory
if defined NO_GEN set /A NO_GEN+=0

rem Do not make a log directory or a log file
if defined NO_LOG set /A NO_LOG+=0

rem Do not make a log output or stdio duplication into files
if defined NO_LOG_OUTPUT set /A NO_LOG_OUTPUT+=0

rem script flags
if not defined FLAG_SHIFT set FLAG_SHIFT=0
set FLAG_ELEVATE=0
set "CALLF_BARE_FLAGS="
set "CALLF_PROMOTE_PARENT_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-elevate" (
    set FLAG_ELEVATE=1
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

set FLAG_NO_LOG=0

if %NO_GEN%0 NEQ 0 set FLAG_NO_LOG=1
if %NO_LOG%0 NEQ 0 set FLAG_NO_LOG=1
if %NO_LOG_OUTPUT%0 NEQ 0 set FLAG_NO_LOG=1

if not exist "%PROJECT_LOG_DIR%\" if %FLAG_NO_LOG% EQU 0 (
  echo.%~nx0%: error: can not use log while PROJECT_LOG_DIR does not exist: "%PROJECT_LOG_DIR%".
  exit /b 255
) >&2

if defined INIT_VARS_FILE if not exist "%INIT_VARS_FILE%" (
  echo.%~nx0%: error: can not use initial variables file while INIT_VARS_FILE does not exist: "%INIT_VARS_FILE%".
  exit /b 255
) >&2

if defined INIT_VARS_FILE set CALLF_BARE_FLAGS= /v INIT_VARS_FILE "%INIT_VARS_FILE%"%CALLF_BARE_FLAGS%

if %FLAG_ELEVATE% EQU 0 (
  set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /load-parent-proc-init-env-vars /print-win-error-string /ret-child-exit
) else (
  if defined CONTOOLS_ROOT set CALLF_BARE_FLAGS= /v CONTOOLS_ROOT "%CONTOOLS_ROOT%"%CALLF_BARE_FLAGS%
)

if %FLAG_NO_LOG% EQU 0 (
  if %FLAG_ELEVATE% EQU 0 (
    set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1
  ) else (
    set CALLF_PROMOTE_PARENT_FLAGS=%CALLF_PROMOTE_PARENT_FLAGS% /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1
  )
)

if defined CALLF_PROMOTE_PARENT_FLAGS set CALLF_PROMOTE_PARENT_FLAGS= /promote-parent{%CALLF_PROMOTE_PARENT_FLAGS% }

if %FLAG_NO_LOG% EQU 0 (
  if %FLAG_ELEVATE% NEQ 0 (
    set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% ^
/promote{ /load-parent-proc-init-env-vars /print-win-error-string /ret-child-exit }%CALLF_PROMOTE_PARENT_FLAGS% ^
/elevate{ /no-window /create-inbound-server-pipe-to-stdout "%~2_stdout_{pid}" /create-inbound-server-pipe-to-stderr "%~2_stderr_{pid}" ^
}{ /attach-parent-console /reopen-stdout-as-client-pipe "%~2_stdout_{ppid}" /reopen-stderr-as-client-pipe "%~2_stderr_{ppid}" }
  )
) else (
  if %FLAG_ELEVATE% NEQ 0 (
    set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% ^
/promote{ /load-parent-proc-init-env-vars /print-win-error-string /ret-child-exit }%CALLF_PROMOTE_PARENT_FLAGS% ^
/elevate{ /no-window }{ /attach-parent-console }
  )
)

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
