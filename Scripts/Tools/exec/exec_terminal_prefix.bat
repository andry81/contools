@echo off

setlocal

rem Do not make a file or a directory
if defined NO_GEN set /A NO_GEN+=0

rem Do not make a log directory or a log file
if defined NO_LOG set /A NO_LOG+=0

rem Do not make a log output or stdio duplication into files
if defined NO_LOG_OUTPUT set /A NO_LOG_OUTPUT+=0

set "?09=/"
if %USE_MINTTY%0 NEQ 0 set "?09=//"

rem script flags
set FLAG_LOG_STDIN=0
set FLAG_SHIFT=0
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

rem common flags for all terminals

set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% %?09%load-parent-proc-init-env-vars %?09%disable-ctrl-signals %?09%print-win-error-string

rem Windows 7 and less check
call "%%CONTOOLS_ROOT%%/std/check_windows_version.bat" 6 2 || (
  rem reattach works on Windows 7 only
  set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% %?09%detach-inherited-console-on-wait %?09%wait-child-first-time-timeout 300 
)

if %FLAG_NO_LOG% EQU 0 if %FLAG_LOG_STDIN% NEQ 0 (
  set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% %?09%tee-stdin "%PROJECT_LOG_FILE%" %?09%pipe-stdin-to-child-stdin
)

if %FLAG_NO_LOG% EQU 0 (
  set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% %?09%tee-stdout "%PROJECT_LOG_FILE%" %?09%tee-stderr-dup 1
)

set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% ^
%?09%no-expand-env %?09%no-subst-pos-vars %?09%no-esc %?09%ret-child-exit ^
%?09%ra "%%" "%%?01%%" %?09%v "?01" "%%" %?09%shift-%FLAG_SHIFT%

rem drop FLAG_SHIFT because already processed by `/shift-%FLAG_SHIFT%`
set FLAG_SHIFT=0

if not defined COMSPECLNK set "COMSPECLNK=%COMSPEC%"

if %USE_MINTTY%0 EQU 0 goto SKIP_USE_MINTTY

rem CAUTION:
rem   The `& call exit /b %%%%ERRORLEVEL%%%%` is required to workaround `cmd.exe` not zero exit code issue.
rem   See the `KNOWN ISSUES` section in the `README_EN.txt`.
rem
(
  endlocal
  set IMPL_MODE=1
  start "" /B /WAIT %MINTTY_TERMINAL_PREFIX% -e "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe"%CALLF_BARE_FLAGS% ^
    "%COMSPECLNK%" "%?09%c \"@\"%?~f0%\" {*} ^& call exit /b %%%%ERRORLEVEL%%%%\"" ^
    %*
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

:SKIP_USE_MINTTY

if %USE_CONEMU%0 EQU 0 goto SKIP_USE_CONEMU

if /i "%CONEMU_INTERACT_MODE%" == "attach" %CONEMU_CMDLINE_ATTACH_PREFIX%

if /i not "%CONEMU_INTERACT_MODE%" == "run" goto SKIP_USE_CONEMU

rem CAUTION:
rem   The `& call exit /b %%%%ERRORLEVEL%%%%` is required to workaround `cmd.exe` not zero exit code issue.
rem   See the `KNOWN ISSUES` section in the `README_EN.txt`.
rem
(
  endlocal
  set IMPL_MODE=1
  %CONEMU_CMDLINE_RUN_PREFIX% "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe"%CALLF_BARE_FLAGS% ^
    "%COMSPECLNK%" "/c \"@\"%?~f0%\" {@} ^& call exit /b %%%%ERRORLEVEL%%%%\"" -cur_console:n ^
    %*
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

:SKIP_USE_CONEMU

rem CAUTION:
rem   The `& call exit /b %%%%ERRORLEVEL%%%%` is required to workaround `cmd.exe` not zero exit code issue.
rem   See the `KNOWN ISSUES` section in the `README_EN.txt`.
rem
(
  endlocal
  set IMPL_MODE=1
  "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe"%CALLF_BARE_FLAGS% ^
    "%COMSPECLNK%" "/c \"@\"%?~f0%\" {*} ^& call exit /b %%%%ERRORLEVEL%%%%\"" ^
    %*
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
