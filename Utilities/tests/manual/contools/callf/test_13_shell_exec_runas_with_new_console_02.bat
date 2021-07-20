@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

"%CALLF_EXE_PATH%" /shell-exec runas /no-sys-dialog-ui /no-window "%CALLF_EXE_PATH%" "/attach-parent-console \"\" \"\\\"${COMSPEC}\\\" /k"

pause
