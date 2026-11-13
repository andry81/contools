@echo off

rem with save of previous error level
setlocal & set LAST_ERROR=%ERRORLEVEL%

if %NEST_LVL%0 EQU 0 (
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_log.bat"
  call "%%CONTOOLS_ROOT%%/cleanup/cleanup_init_vars.bat"
)

exit /b %LAST_ERROR%
