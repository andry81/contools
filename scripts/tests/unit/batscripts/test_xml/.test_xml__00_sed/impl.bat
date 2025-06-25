@echo off

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_DATA_REF_DIR_ROOT "%%TEST_DATA_IN_ROOT%%\%%TEST_DATA_DIR%%"

set "TEST_DATA_IN_FILE=%TEST_DATA_REF_DIR_ROOT%\input.txt"
set "TEST_DATA_REF_FILE=%TEST_DATA_REF_DIR_ROOT%\output.txt"

rem builtin commands
(
  "%CONTOOLS_MSYS2_USR_ROOT%/bin/sed.exe" %TEST_DATA_SED_CMD_LINE% "%TEST_DATA_IN_FILE%"
) > "%TEST_DATA_OUT_FILE%" || ( call set "TEST_IMPL_ERROR=%%ERRORLEVEL%%" & set "TEST_LAST_ERROR=20" & goto EXIT )

if not exist "%TEST_DATA_OUT_FILE%" set "TEST_LAST_ERROR=21" & goto EXIT
if not exist "%TEST_DATA_REF_FILE%" set "TEST_LAST_ERROR=22" & goto EXIT

"%SystemRoot%\System32\fc.exe" "%TEST_DATA_OUT_FILE:/=\%" "%TEST_DATA_REF_FILE%" >nul || set "TEST_LAST_ERROR=23"

:EXIT
exit /b %TEST_LAST_ERROR%
