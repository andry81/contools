@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

"%CALLF_EXE_PATH%" /reopen-stdin "%TEST_CALLF_REF_INPUT_FILE_0%" .

pause
