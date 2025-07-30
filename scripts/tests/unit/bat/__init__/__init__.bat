@echo off

if defined CONTOOLS_PROJECT_TESTS_INIT0_DIR if exist "%CONTOOLS_PROJECT_TESTS_INIT0_DIR%\*" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "CONTOOLS_PROJECT_TESTS_INIT0_DIR=%~dp0"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TESTS_PROJECT_ROOT "%%~dp0.."

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config_dir.bat" "%%TESTS_PROJECT_ROOT%%/_config" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%TEST_DATA_OUT_ROOT%%" || exit /b
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%TEST_DATA_TEMP_ROOT%%" || exit /b

rem initialize testlib "module"
call "%%CONTOOLS_ROOT%%/testlib/__init__.bat" || exit /b

exit /b 0

