@echo off

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/check_vars.bat" CONTOOLS_PROJECT_ROOT PROJECT_OUTPUT_ROOT PROJECT_LOG_ROOT CONTOOLS_ROOT CONTOOLS_UTILS_BIN_ROOT || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%* || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/init_project_log.bat" "%%?~n0%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/init_vars_file.bat" || exit /b

set "EXEC_CALLF_PREFIX_BARE_FLAGS="
set EXEC_CALLF_FLAG_SKIP=1

rem cast to integer
set /A EXEC_CALLF_PREFIX_NO_PAUSE_ON_EXIT+=0

if %EXEC_CALLF_PREFIX_NO_PAUSE_ON_EXIT% EQU 0 (
  set EXEC_CALLF_PREFIX_BARE_FLAGS=%EXEC_CALLF_PREFIX_BARE_FLAGS% -X /pause-on-exit
  set /A EXEC_CALLF_FLAG_SKIP+=2
)

call "%%CONTOOLS_ROOT%%/std/callshift.bat" -skip %%EXEC_CALLF_FLAG_SKIP%% 1 "%%CONTOOLS_ROOT%%/exec/exec_callf_prefix.bat"%%EXEC_CALLF_PREFIX_BARE_FLAGS%% -- %%* || exit /b

rem The caller must exit after this exit.
exit /b 0

:IMPL
rem CAUTION: We must to reinit the builtin variables in case if `IMPL_MODE` was already setup outside.
call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%* || exit /b

rem load initialization environment variables
if defined INIT_VARS_FILE call "%%CONTOOLS_ROOT%%/std/set_vars_from_file.bat" "%%INIT_VARS_FILE%%"

call "%%CONTOOLS_ROOT%%/std/get_cmdline.bat" %%*
call "%%CONTOOLS_ROOT%%/std/echo_var.bat" RETURN_VALUE ">"
echo;

rem The caller can continue after this exit.
exit /b 0
