@echo off

setlocal

rem Do not continue if already in Impl Mode
if defined IMPL_MODE set /A IMPL_MODE+=0

if %IMPL_MODE%0 NEQ 0 (
  echo.%~nx0: error: Impl Mode already used.
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

set "?~nx0=%~nx0"

rem script flags

rem NOTE:
rem   The `FLAG_SHIFT` now drops unconditionally because must not interfere within a nested call and used ONLY locally.
rem   If you want to pass the shift value into `callf` utility, then you must explicitly use the `-X /shift-N` option.
rem   Otherwise use `callshift.bat` script to explicitly shift the rest of the commad line before call to this script.
rem
set FLAG_SHIFT=0

set FLAG_LOG_STDIN=0
set "CALLF_BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-log-stdin" (
    set FLAG_LOG_STDIN=1
  ) else if "%FLAG%" == "-X" (
    set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% %2
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
  echo.%?~nx0%: error: can not use log while PROJECT_LOG_DIR does not exist: "%PROJECT_LOG_DIR%".
  exit /b 255
) >&2

if defined INIT_VARS_FILE if not exist "%INIT_VARS_FILE%" (
  echo.%?~nx0%: error: can not use initial variables file while INIT_VARS_FILE does not exist: "%INIT_VARS_FILE%".
  exit /b 255
) >&2

rem common flags for all terminals

rem CAUTION:
rem   Because `callf.exe` does use flag `/load-parent-proc-init-env-vars`, then we must always pass `IMPL_MODE` and `NEST_LVL` variables into the command line.
rem   Otherwise we can fall into infinite recursion because of the unset of the `IMPL_MODE` variable.
rem
set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /v IMPL_MODE 1

if defined NEST_LVL set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /v NEST_LVL %NEST_LVL%

if defined CONTOOLS_ROOT set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /v CONTOOLS_ROOT "%CONTOOLS_ROOT%"

if defined INIT_VARS_FILE set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /v INIT_VARS_FILE "%INIT_VARS_FILE%"

rem CAUTION:
rem   We must always disable handling of signals to prevent `cmd.exe` double termination request.
rem   For details see `callf` tests.

set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /load-parent-proc-init-env-vars /disable-ctrl-signals /print-win-error-string

rem Windows 7 and less check
call "%%CONTOOLS_ROOT%%/std/check_windows_version.bat" 6 2 || (
  rem reattach works on Windows 7 only
  set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /detach-inherited-console-on-wait /wait-child-first-time-timeout 300 
)

if %FLAG_NO_LOG% EQU 0 if %FLAG_LOG_STDIN% NEQ 0 (
  set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /tee-stdin "%PROJECT_LOG_FILE%" /pipe-stdin-to-child-stdin
)

if %FLAG_NO_LOG% EQU 0 (
  set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1
)

set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% ^
/no-expand-env /no-subst-pos-vars /no-esc /ret-child-exit ^
/ra "%%" "%%?01%%" /v "?01" "%%" /shift-%FLAG_SHIFT%

rem drop FLAG_SHIFT because already processed by `/shift-%FLAG_SHIFT%`
set FLAG_SHIFT=0

if not defined COMSPECLNK set "COMSPECLNK=%COMSPEC%"

if %USE_MINTTY%0 EQU 0 goto SKIP_USE_MINTTY

set MINTTY_CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS%

rem CAUTION:
rem   The `& "%CONTOOLS_ROOT%/std/errlvl.bat"` is required to workaround `cmd.exe` not zero exit code issue.
rem   See the `KNOWN ISSUES` section in the `README_EN.txt`.
rem
rem CAUTION:
rem   The MinTTY must call to `cmd.exe` script at first, not to `callf.exe`, to bypass weird MinTTY escape rules over backslash - `\`.
(
  rem The `start` exists here just in case the MinTTY would not close immediately after the start.
  start "" /B /WAIT %MINTTY_TERMINAL_PREFIX% -e ^
    "%CONTOOLS_ROOT:/=\%/exec/exec_mintty_prefix.bat" %* & "%CONTOOLS_ROOT:/=\%/std/errlvl.bat"
)

set LAST_ERROR=%ERRORLEVEL%

rem CAUTION:
rem   DO NOT CLEANUP because mintty restarts itself and mintty parent process does exit immediately!
rem   Instead do cleap in a child process.
rem
rem call "%%CONTOOLS_ROOT%%/exec/exec_terminal_cleanup.bat"

(
  rem drop local variables
  set "LAST_ERROR="
  exit /b %LAST_ERROR%
)

:SKIP_USE_MINTTY

if %USE_CONEMU%0 EQU 0 goto SKIP_USE_CONEMU

if /i "%CONEMU_INTERACT_MODE%" == "attach" %CONEMU_CMDLINE_ATTACH_PREFIX%

if /i not "%CONEMU_INTERACT_MODE%" == "run" goto SKIP_USE_CONEMU

rem CAUTION:
rem   The `& "%CONTOOLS_ROOT%/std/errlvl.bat"` is required to workaround `cmd.exe` not zero exit code issue.
rem   See the `KNOWN ISSUES` section in the `README_EN.txt`.
rem
(
  endlocal
  %CONEMU_CMDLINE_RUN_PREFIX% "%CONTOOLS_UTILS_BIN_ROOT%/contools/callf.exe"%CALLF_BARE_FLAGS% ^
    "%COMSPECLNK%" "/c \"@\"%?~f0%\" {@} ^& \"%CONTOOLS_ROOT%/std/errlvl.bat\"\"" -cur_console:n ^
    %*
)

set LAST_ERROR=%ERRORLEVEL%

call "%%CONTOOLS_ROOT%%/exec/exec_terminal_cleanup.bat"

(
  rem drop local variables
  set "LAST_ERROR="
  exit /b %LAST_ERROR%
)

:SKIP_USE_CONEMU

rem CAUTION:
rem   The `& "%CONTOOLS_ROOT%/std/errlvl.bat"` is required to workaround `cmd.exe` not zero exit code issue.
rem   See the `KNOWN ISSUES` section in the `README_EN.txt`.
rem
(
  endlocal
  "%CONTOOLS_UTILS_BIN_ROOT%/contools/callf.exe"%CALLF_BARE_FLAGS% ^
    "%COMSPECLNK%" "/c \"@\"%?~f0%\" {*} ^& \"%CONTOOLS_ROOT%/std/errlvl.bat\"\"" ^
    %*
)

set LAST_ERROR=%ERRORLEVEL%

call "%%CONTOOLS_ROOT%%/exec/exec_terminal_cleanup.bat"

(
  rem drop local variables
  set "LAST_ERROR="
  exit /b %LAST_ERROR%
)
