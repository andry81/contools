@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b 255

"%VS_BOOTSTRAPPERS_CACHE_DIR%\%VS_BOOTSTRAPPER_EXE%" --layout "%VS_LAYOUT_CACHE_ROOT%" %VS_COMMON_CMDLINE% --lang en-US
