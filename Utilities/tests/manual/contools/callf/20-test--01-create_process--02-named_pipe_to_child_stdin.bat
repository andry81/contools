@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

"%CALLF_EXE_PATH%" /reopen-stdin "%TEST_CALLF_REF_INPUT_FILE_0%" /reopen-stdout-as-server-pipe test123_{pid} /pipe-stdin-to-stdout "" "\"%CALLF_EXE_PATH%\" /reopen-stdin-as-client-pipe test123_{ppid} \"\" \"cmd.exe /k\""

pause
