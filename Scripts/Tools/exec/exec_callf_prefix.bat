@echo off

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem cast to integer
set /A IMPL_MODE+=0

rem do not continue if already in Impl Mode
if %IMPL_MODE% NEQ 0 (
  echo;%?~%: error: Impl Mode already used.
  exit /b 255
) >&2

rem cast to integer
if defined NEST_LVL set /A NEST_LVL+=0

rem Do not make a file or a directory
if defined NO_GEN set /A NO_GEN+=0

rem Do not make a log directory or a log file
if defined NO_LOG set /A NO_LOG+=0

rem Do not make a log output or stdio duplication into files
if defined NO_LOG_OUTPUT set /A NO_LOG_OUTPUT+=0

rem script flags

rem NOTE:
rem   The `FLAG_SHIFT` now drops unconditionally because must not interfere within a nested call and used ONLY locally.
rem   If you want to pass the shift value into `callf` utility, then you must explicitly use the `-X /shift-N` option.
rem   Otherwise use `callshift.bat` script to explicitly shift the rest of the command line before call to this script.
rem
set FLAG_SHIFT=0

set FLAG_NO_LOG=0
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
  if "%FLAG%" == "-nolog" (
    set FLAG_NO_LOG=1
  ) else if "%FLAG%" == "-elevate" (
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
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift
  set /A FLAG_SHIFT+=1

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

if %NO_GEN%0 NEQ 0 set FLAG_NO_LOG=1
if %NO_LOG%0 NEQ 0 set FLAG_NO_LOG=1
if %NO_LOG_OUTPUT%0 NEQ 0 set FLAG_NO_LOG=1

if %FLAG_NO_LOG% EQU 0 if defined PROJECT_LOG_DIR if not exist "%PROJECT_LOG_DIR%\*" (
  echo;%?~%: error: can not use log while PROJECT_LOG_DIR does not exist: "%PROJECT_LOG_DIR%".
  exit /b 255
) >&2

if defined INIT_VARS_FILE if not exist "%INIT_VARS_FILE%" (
  echo;%?~%: error: can not use initial environment variables file while INIT_VARS_FILE does not exist: "%INIT_VARS_FILE%".
  exit /b 255
) >&2

rem common flags for all terminals

rem CAUTION:
rem   Because `callf.exe` may use flag `/load-parent-proc-init-env-vars`, then we must always pass `IMPL_MODE` and `NEST_LVL` variables into the command line.
rem   Otherwise we can fall into infinite recursion because of the unset of the `IMPL_MODE` variable.
rem
set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /v IMPL_MODE 1

if defined NEST_LVL set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /v NEST_LVL %NEST_LVL%

if %FLAG_ELEVATE% NEQ 0 if defined CONTOOLS_ROOT set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /v CONTOOLS_ROOT "%CONTOOLS_ROOT%"

if %FLAG_ELEVATE% NEQ 0 if defined INIT_VARS_FILE set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /v INIT_VARS_FILE "%INIT_VARS_FILE%"

rem CAUTION:
rem   We must always disable handling of signals to prevent `cmd.exe` double termination request.
rem   For details see `callf` tests.

if %FLAG_ELEVATE% EQU 0 (
  set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /disable-ctrl-signals /print-win-error-string
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
/ra "%%" "%%?25%%" /v "?25" "%%" ^
/shift-%FLAG_SHIFT%

rem drop FLAG_SHIFT because already processed by `/shift-%FLAG_SHIFT%`
set FLAG_SHIFT=0

if not defined COMSPECLNK set "COMSPECLNK=%COMSPEC%"

rem CAUTION:
rem   The `& "%CONTOOLS_ROOT%/std/errlvl.bat"` is required to workaround `cmd.exe` not zero exit code issue.
rem   See the `KNOWN ISSUES` section in the `README_EN.txt`.
rem
endlocal & "%CONTOOLS_UTILS_BIN_ROOT%/contools/callf.exe"%CALLF_BARE_FLAGS% // ^
  "%COMSPECLNK%" "/c \"@\"%?~f0%\" {*} ^& \"%CONTOOLS_ROOT%/std/errlvl.bat\"\"" ^
  %*

rem to drop local variables
setlocal & set LAST_ERROR=%ERRORLEVEL%

if %NEST_LVL%0 EQU 0 (
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_log.bat"
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_init_vars.bat"
)

exit /b %LAST_ERROR%
