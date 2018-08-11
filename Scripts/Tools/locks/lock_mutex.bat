@echo off

setlocal

:WAIT_LOOP
call "%%~dp0try_lock_mutex.bat" %%* && exit /b 0

call "%%CONTOOLS_ROOT%%/std/sleep.bat" 20

goto WAIT_LOOP
