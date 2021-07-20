@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

"%CALLF_EXE_PATH%" /ra "{LR}" "\n" "" "printf /e \"Hello{LR}World!{0}\"" "{LR}"

pause
