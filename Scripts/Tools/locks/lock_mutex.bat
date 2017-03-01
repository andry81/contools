@echo off

setlocal

:WAIT_LOOP
call "%%~dp0try_lock_mutex.bat" %%* && exit /b 0

pathping localhost -n -q 1 -p 20 >nul 2>&1

goto WAIT_LOOP
