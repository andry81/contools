@echo off

if %IMPL_MODE%0 NEQ 0 goto IMPL

set "REDIR_LINE="
if "%~1" == "print" set "REDIR_LINE=>&2"

(
  call "%%~dp0__init__.bat" || exit /b

  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/check_vars.bat" CONTOOLS_PROJECT_ROOT PROJECT_OUTPUT_ROOT PROJECT_LOG_ROOT CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT || exit /b

  call "%%CONTOOLS_ROOT%%/std/callshift.bat" -skip 1 2 call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%* || exit /b

  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/init_project_log.bat" "%%?~n0%%" || exit /b

  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/init_vars_file.bat" || exit /b
) %REDIR_LINE%

call "%%CONTOOLS_ROOT%%/std/callshift.bat" -skip 2 3 call "%%%%CONTOOLS_ROOT%%%%/exec/exec_callf_prefix.bat" -- %%*
set LAST_ERROR=%ERRORLEVEL%

if %NEST_LVL% EQU 0 if %LAST_ERROR% EQU 0 (
  rem copy log into project output directory
  if "%~1" == "backup" (
    call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_dir.bat" "%%PROJECT_LOG_DIR%%" "%%GH_ADAPTOR_BACKUP_DIR%%/%%~2/.log/%%PROJECT_LOG_DIR_NAME%%" /E /Y /D
  ) else if "%~1" == "workflow" (
    call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_dir.bat" "%%PROJECT_LOG_DIR%%" "%%GH_ADAPTOR_WORKFLOW_DIR%%/%%~2/.log/%%PROJECT_LOG_DIR_NAME%%" /E /Y /D
  )
)

if not "%~1" == "print" (
  pause
)

rem The caller must exit after this exit.
exit /b %LAST_ERROR%

:IMPL
rem CAUTION: We must to reinit the builtin variables in case if `IMPL_MODE` was already setup outside.
call "%%CONTOOLS_ROOT%%/std/callshift.bat" -skip 1 2 call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%* || exit /b

set /A NEST_LVL+=1

if %NEST_LVL% EQU 1 (
  rem load initialization environment variables
  if defined INIT_VARS_FILE call "%%CONTOOLS_ROOT%%/std/set_vars_from_file.bat" "%%INIT_VARS_FILE%%"
)

rem call "%%CONTOOLS_ROOT%%/std/get_cmdline.bat" %%*
rem call "%%CONTOOLS_ROOT%%/std/echo_var.bat" RETURN_VALUE ">"
rem echo.

rem The caller can continue after this exit.
exit /b 0
