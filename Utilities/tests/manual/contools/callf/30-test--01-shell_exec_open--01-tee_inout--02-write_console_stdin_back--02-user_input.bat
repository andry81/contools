@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

set "LOG_FILE_NAME=%~n0.log"

set "LOG_FILE_PATH=%TEST_DATA_OUT_DIR%/%LOG_FILE_NAME%"

type nul > "%LOG_FILE_PATH%"

"%CALLF_EXE_PATH%" /shell-exec open /tee-stdin "%LOG_FILE_PATH%" /tee-conout-dup /write-console-stdin-back "${COMSPEC}" "/k"

pause
