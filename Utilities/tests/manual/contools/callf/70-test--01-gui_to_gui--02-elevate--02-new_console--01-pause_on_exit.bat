@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

start "" /WAIT "%CALLFG_EXE_PATH%" "" "\"%CALLFG_EXE_PATH%\" /elevate /create-console /promote{ /disable-wow64-fs-redir } /pause-on-exit-if-error /ret-child-exit // \"${COMSPEC}\" \"/c echo 111 ^& echo 222 ^>^&2 ^& exit 123\""

pause
