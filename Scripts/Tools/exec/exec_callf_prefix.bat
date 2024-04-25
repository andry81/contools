@echo off

setlocal

rem Do not continue if already in Impl Mode
if defined IMPL_MODE set /A IMPL_MODE+=0

if %IMPL_MODE%0 NEQ 0 (
  echo.%~nx0: error: Impl Mode already used.
  exit /b 255
) >&2

rem Do not make a file or a directory
if defined NO_GEN set /A NO_GEN+=0

rem Do not make a log directory or a log file
if defined NO_LOG set /A NO_LOG+=0

rem Do not make a log output or stdio duplication into files
if defined NO_LOG_OUTPUT set /A NO_LOG_OUTPUT+=0

rem script flags
if not defined FLAG_SHIFT set FLAG_SHIFT=0
set FLAG_ELEVATE=0
set "ELEVATE_PREFIX_NAME="
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
    set "ELEVATE_PREFIX_NAME=%~2"
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
  ) else if not "%FLAG%" == "--" (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift
  set /A FLAG_SHIFT+=1

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

set FLAG_NO_LOG=0

if %NO_GEN%0 NEQ 0 set FLAG_NO_LOG=1
if %NO_LOG%0 NEQ 0 set FLAG_NO_LOG=1
if %NO_LOG_OUTPUT%0 NEQ 0 set FLAG_NO_LOG=1

if not exist "%PROJECT_LOG_DIR%\*" if %FLAG_NO_LOG% EQU 0 (
  echo.%~nx0: error: can not use log while PROJECT_LOG_DIR does not exist: "%PROJECT_LOG_DIR%".
  exit /b 255
) >&2

if defined INIT_VARS_FILE if not exist "%INIT_VARS_FILE%" (
  echo.%~nx0: error: can not use initial variables file while INIT_VARS_FILE does not exist: "%INIT_VARS_FILE%".
  exit /b 255
) >&2

rem common flags for all terminals

rem CAUTION:
rem   Because `callf.exe` does use flag `/load-parent-proc-init-env-vars`, then we must always pass `IMPL_MODE` variable in the command line.
rem   Otherwise we can fall into infinite recursion because of the unset of the `IMPL_MODE` variable.
rem
set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /v IMPL_MODE 1

if %FLAG_ELEVATE% NEQ 0 if defined CONTOOLS_ROOT set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /v CONTOOLS_ROOT "%CONTOOLS_ROOT%"

if %FLAG_ELEVATE% NEQ 0 if defined INIT_VARS_FILE set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /v INIT_VARS_FILE "%INIT_VARS_FILE%"

rem CAUTION:
rem   We must always disable handling of signals to prevent `cmd.exe` double termination request.
rem   For details see `callf` tests.

if %FLAG_ELEVATE% EQU 0 (
  set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /load-parent-proc-init-env-vars /disable-ctrl-signals /print-win-error-string
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
/promote{ /load-parent-proc-init-env-vars /disable-ctrl-signals /print-win-error-string /ret-child-exit }%CALLF_PROMOTE_PARENT_FLAGS% ^
/elevate{ /no-window /create-inbound-server-pipe-to-stdout "%ELEVATE_PREFIX_NAME%_stdout_{pid}" /create-inbound-server-pipe-to-stderr "%ELEVATE_PREFIX_NAME%_stderr_{pid}" ^
}{ /attach-parent-console /reopen-stdout-as-client-pipe "%ELEVATE_PREFIX_NAME%_stdout_{ppid}" /reopen-stderr-as-client-pipe "%ELEVATE_PREFIX_NAME%_stderr_{ppid}" }
  )
) else (
  if %FLAG_ELEVATE% NEQ 0 (
    set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% ^
/promote{ /load-parent-proc-init-env-vars /disable-ctrl-signals /print-win-error-string /ret-child-exit }%CALLF_PROMOTE_PARENT_FLAGS% ^
/elevate{ /no-window }{ /attach-parent-console }
  )
)

if %FLAG_ELEVATE% EQU 0 (
  set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /no-expand-env /no-subst-pos-vars /no-esc /ret-child-exit
)

set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% ^
/ra "%%" "%%?01%%" /v "?01" "%%" ^
/shift-%FLAG_SHIFT%

rem drop FLAG_SHIFT because already processed by `/shift-%FLAG_SHIFT%`
set FLAG_SHIFT=0

if not defined COMSPECLNK set "COMSPECLNK=%COMSPEC%"

rem CAUTION:
rem   The `& "%CONTOOLS_ROOT%/std/errlvl.bat"` is required to workaround `cmd.exe` not zero exit code issue.
rem   See the `KNOWN ISSUES` section in the `README_EN.txt`.
rem
(
  endlocal
  "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe"%CALLF_BARE_FLAGS% ^
    "%COMSPECLNK%" "/c \"@\"%?~f0%\" {*} ^& \"%CONTOOLS_ROOT%/std/errlvl.bat\"\"" ^
    %*
)

set LAST_ERROR=%ERRORLEVEL%

if %NEST_LVL%0 EQU 0 (
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_log.bat"
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_init_vars.bat"
)

(
  rem drop local variables
  set "LAST_ERROR="
  exit /b %LAST_ERROR%
)
