@echo off

setlocal

:WAIT_LOOP
call "%%~dp0try_lock_mutex.bat" %%* && exit /b 0

rem busy wait for 20 msec
call "%%~dp0busy_wait.bat" 20

goto WAIT_LOOP
