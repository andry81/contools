@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b 255

rem "%VS_LAYOUT_CACHE_ROOT%\%VS_BOOTSTRAPPER_EXE%" %VS_COMMON_CMDLINE% --path cache="%VS_PACKAGES_CACHE_ROOT%" --path shared="%VS_DOWNLOAD_SHARED_ROOT%" %*
"%VS_LAYOUT_CACHE_ROOT%\%VS_BOOTSTRAPPER_EXE%" %VS_COMMON_CMDLINE% --path cache="%VS_PACKAGES_CACHE_ROOT%" %*
