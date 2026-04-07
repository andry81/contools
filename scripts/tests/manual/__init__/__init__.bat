@echo off

if defined CONTOOLS_PROJECT_TESTS_INIT0_DIR if exist "%CONTOOLS_PROJECT_TESTS_INIT0_DIR%\*" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

rem retarget externals of an external project

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" USERBIN_PROJECT_EXTERNALS_ROOT    "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%"

rem init external projects

if exist "%CONTOOLS_PROJECT_EXTERNALS_ROOT%/userbin/__init__/__init__.bat" (
  rem disable code page change in nested __init__
  set /A NO_CHCP+=1
  call "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%/userbin/__init__/__init__.bat" %%* || exit /b
  set /A NO_CHCP-=1
)

exit /b 0
