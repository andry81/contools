@echo off

rem Create local variable's stack
setlocal

rem call "%%~dp0__init__/__init__.bat" || exit /b

call "%%~dp0test_std.bat"
call "%%~dp0test_std_encode.bat"
call "%%~dp0test_build.bat"
