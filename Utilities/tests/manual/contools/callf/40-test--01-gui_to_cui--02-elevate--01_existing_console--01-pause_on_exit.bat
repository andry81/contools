@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

start "" /WAIT "%CALLFG_EXE_PATH%" "" "\"%CALLF_EXE_PATH%\" /elevate{ /no-window }{ /attach-parent-console } /promote-parent{ /pause-on-exit-if-error } /promote{ /disable-wow64-fs-redir /ret-child-exit } // \"${COMSPEC}\" \"/c echo 111 ^& echo 222 ^>^&2 ^& exit 123\""

pause
