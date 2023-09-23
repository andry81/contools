@(
  @echo off

  setlocal

  if %NEST_LVL%0 EQU 0 (
    call "%%CONTOOLS_ROOT%%/cleanup/cleanup_log.bat"
    call "%%CONTOOLS_ROOT%%/cleanup/cleanup_init_vars.bat"
  )

  rem exit with previous error level
  exit /b %ERRORLEVEL%
)
