@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

"%CALLF_EXE_PATH%" /r2 "{LR}" "\n" "" "printf /e \"Hello{0}World!{0}{1}\"" "{LR}" "{LR}"

pause
