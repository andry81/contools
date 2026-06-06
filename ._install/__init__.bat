@echo off

if defined CONTOOLS_PROJECT_ROOT_INIT0_DIR if exist "%CONTOOLS_PROJECT_ROOT_INIT0_DIR%\*" exit /b 0

set INIT_EXTERNALS=1

call "%%~dp0..\__init__\__init__.bat" || exit /b

rem retarget externals of an external project

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" CONTOOLS_ADMIN_PROJECT_EXTERNALS_ROOT "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" USERBIN_PROJECT_EXTERNALS_ROOT        "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%"

rem init external projects

call "%%CONTOOLS_ROOT%%/std/call_if_exist.bat" "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%/contools--admin/__init__/__init__.bat" %%* || exit /b
call "%%CONTOOLS_ROOT%%/std/call_if_exist.bat" "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%/userbin/__init__/__init__.bat" %%* || exit /b

exit /b 0
