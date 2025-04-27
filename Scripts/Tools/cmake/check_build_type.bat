@echo off

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "CMAKE_BUILD_TYPE=%~1"
set "CMAKE_CONFIG_TYPES=%~2"

if not defined CMAKE_BUILD_TYPE (
  echo;%?~%: error: CMAKE_BUILD_TYPE is not defined
  exit /b 1
) >&2

if not defined CMAKE_CONFIG_TYPES (
  echo;%?~%: error: CMAKE_CONFIG_TYPES is not defined
  goto exit /b 2
) >&2

set CMAKE_BUILD_TYPE_FOUND=0
for %%i in (%CMAKE_CONFIG_TYPES%) do ^
if /i "%%i" == "%CMAKE_BUILD_TYPE%" set "CMAKE_BUILD_TYPE_FOUND=1" & goto CMAKE_BUILD_TYPE_END

:CMAKE_BUILD_TYPE_END

if %CMAKE_BUILD_TYPE_FOUND% EQU 0 (
  echo;%?~%: error: CMAKE_BUILD_TYPE is not declared in CMAKE_CONFIG_TYPES: CMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" CMAKE_CONFIG_TYPES="%CMAKE_CONFIG_TYPES%"
  exit /b 3
) >&2

exit /b 0
