@echo off

setlocal

set "?09=/"
if %USE_MINTTY%0 NEQ 0 set "?09=//"

rem script flags
if not defined FLAG_SHIFT set FLAG_SHIFT=0
set "CALLF_BARE_FLAGS="

if defined INIT_VARS_FILE set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% %?09%v INIT_VARS_FILE "%INIT_VARS_FILE%"

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-log-stdin" (
    set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% %?09%tee-stdin "%PROJECT_LOG_FILE%" %?09%pipe-stdin-to-child-stdin
  ) else if "%FLAG%" == "-log-conout" (
    set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% %?09%tee-stdout "%PROJECT_LOG_FILE%" %?09%tee-stderr-dup 1
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

rem Windows 7 and less check
call "%%CONTOOLS_ROOT%%/std/check_windows_version.bat" 6 2 || (
  rem reattach works on Windows 7 only
  set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% %?09%detach-inherited-console-on-wait %?09%wait-child-first-time-timeout 300 
)

if %FLAG_USE_X64%0 NEQ 0 set CALLF_BARE_FLAGS=%CALLF_BARE_FLAGS% %?09%disable-wow64-fs-redir

if not defined COMSPECLNK set "COMSPECLNK=%COMSPEC%"

if %USE_MINTTY%0 EQU 0 goto SKIP_USE_MINTTY

(
  endlocal
  start "" /I /B /WAIT %MINTTY_TERMINAL_PREFIX% -e "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe"%CALLF_BARE_FLAGS% ^
    %?09%disable-ctrl-signals %?09%ret-child-exit %?09%print-win-error-string %?09%no-expand-env %?09%no-subst-pos-vars %?09%no-esc ^
    %?09%v IMPL_MODE 1 ^
    %?09%ra "%%" "%%?01%%" %?09%v "?01" "%%" ^
    %?09%shift-%FLAG_SHIFT% ^
    "%COMSPECLNK%" "%?09%c \"@\"%?~f0%\" {*}\"" %*
)

setlocal

set LASTERROR=%ERRORLEVEL%

if %NEST_LVL% EQU 0 (
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_log.bat"
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_init_vars.bat"
)

exit /b %LASTERROR%

:SKIP_USE_MINTTY

if %USE_CONEMU%0 EQU 0 goto SKIP_USE_CONEMU

if /i "%CONEMU_INTERACT_MODE%" == "attach" %CONEMU_CMDLINE_ATTACH_PREFIX%

if /i not "%CONEMU_INTERACT_MODE%" == "run" goto SKIP_USE_CONEMU

(
  endlocal
  %CONEMU_CMDLINE_RUN_PREFIX% "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe"%CALLF_BARE_FLAGS% ^
    /load-parent-proc-init-env-vars ^
    /disable-ctrl-signals /attach-parent-console /ret-child-exit /print-win-error-string /no-expand-env /no-subst-pos-vars /no-esc ^
    /v IMPL_MODE 1 ^
    /ra "%%" "%%?01%%" /v "?01" "%%" ^
    /shift-%FLAG_SHIFT% ^
    "%COMSPECLNK%" "/c \"@\"%?~f0%\" {@}\"" -cur_console:n %*
)

setlocal

set LASTERROR=%ERRORLEVEL%

if %NEST_LVL% EQU 0 (
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_log.bat"
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_init_vars.bat"
)

exit /b %LASTERROR%

:SKIP_USE_CONEMU

(
  endlocal
  "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe"%CALLF_BARE_FLAGS% ^
    /load-parent-proc-init-env-vars ^
    /disable-ctrl-signals /attach-parent-console /ret-child-exit /print-win-error-string /no-expand-env /no-subst-pos-vars /no-esc ^
    /v IMPL_MODE 1 ^
    /ra "%%" "%%?01%%" /v "?01" "%%" ^
    /shift-%FLAG_SHIFT% ^
    "%COMSPECLNK%" "/c \"@\"%?~f0%\" {*}\"" %*
)

setlocal

set LASTERROR=%ERRORLEVEL%

if %NEST_LVL% EQU 0 (
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_log.bat"
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_init_vars.bat"
)

(
  endlocal
  exit /b %LASTERROR%
)
