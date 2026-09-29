@echo off

if defined IN (
  call "%%CONTOOLS_ROOT%%/std/set_var.bat" TEST_CMDLINE IN
) else set TEST_CMDLINE=%*

exit /b 0
