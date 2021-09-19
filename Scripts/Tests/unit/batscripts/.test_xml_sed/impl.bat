@echo off

call :GET_ABSOLUTE_PATH "%%TEST_DATA_BASE_DIR%%\%%TEST_DATA_DIR%%"
set "TEST_DATA_REF_DIR_ROOT=%RETURN_VALUE%"

set "TEST_DATA_IN_FILE=%TEST_DATA_REF_DIR_ROOT%\input.txt"
set "TEST_DATA_REF_FILE=%TEST_DATA_REF_DIR_ROOT%\output.txt"

rem builtin commands
(
  "%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" %TEST_DATA_SED_CMD_LINE% "%TEST_DATA_IN_FILE%"
) > "%TEST_DATA_OUT_FILE%" || ( call set "INTERRORLEVEL=%%ERRORLEVEL%%" & set "LASTERROR=20" & goto EXIT )

if not exist "%TEST_DATA_OUT_FILE%" ( set "LASTERROR=21" & goto EXIT )
if not exist "%TEST_DATA_REF_FILE%" ( set "LASTERROR=22" & goto EXIT )

"%SystemRoot%\System32\fc.exe" "%TEST_DATA_OUT_FILE:/=\%" "%TEST_DATA_REF_FILE%" > nul
if %ERRORLEVEL% NEQ 0 set LASTERROR=23

:EXIT
exit /b %LASTERROR%

:GET_ABSOLUTE_PATH
set "RETURN_VALUE=%~f1"
exit /b 0
