@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

"%CALLF_EXE_PATH%" /reopen-stdin "%TEST_CALLF_REF_INPUT_FILE_0%" /tee-stdout "%TEST_DATA_OUT_DIR%/out.log" /tee-stderr-dup 1 "" "cmd.exe /k"

pause
