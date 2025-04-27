@echo off

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "CMAKE_BUILD_TYPE=%~1"
set "GENERATOR_IS_MULTI_CONFIG=%~2"

if exist "%CMAKE_BUILD_ROOT%/singleconfig.tag" (
  if not defined CMAKE_BUILD_TYPE (
    echo;%?~%: error: CMAKE_BUILD_TYPE must be set for single config cmake cache.
    exit /b 1
  ) >&2
  call "%%~dp0canonical_path.bat" CMAKE_BUILD_DIR  "%%CMAKE_BUILD_ROOT%%\%%CMAKE_BUILD_TYPE%%"
  call "%%~dp0canonical_path.bat" CMAKE_BIN_DIR    "%%CMAKE_BIN_ROOT%%\%%CMAKE_BUILD_TYPE%%"
  call "%%~dp0canonical_path.bat" CMAKE_LIB_DIR    "%%CMAKE_LIB_ROOT%%\%%CMAKE_BUILD_TYPE%%"
  call "%%~dp0canonical_path.bat" CMAKE_PACK_DIR   "%%CMAKE_PACK_ROOT%%\%%CMAKE_BUILD_TYPE%%"
) else if exist "%CMAKE_BUILD_ROOT%/multiconfig.tag" (
  if %GENERATOR_IS_MULTI_CONFIG%0 EQU 0 (
    echo;%?~%: error: GENERATOR_IS_MULTI_CONFIG must be already set for multi config cmake cache.
    exit /b 2
  ) >&2
  call "%%~dp0canonical_path.bat" CMAKE_BUILD_DIR  "%%CMAKE_BUILD_ROOT%%"
  call "%%~dp0canonical_path.bat" CMAKE_BIN_DIR    "%%CMAKE_BIN_ROOT%%"
  call "%%~dp0canonical_path.bat" CMAKE_LIB_DIR    "%%CMAKE_LIB_ROOT%%"
  call "%%~dp0canonical_path.bat" CMAKE_PACK_DIR   "%%CMAKE_PACK_ROOT%%"
) else (
  echo;%?~%: error: cmake cache is not created as single config nor multi config.
  exit /b 3
) >&2

call :PARENT_DIR "%%CMAKE_OUTPUT_ROOT%%"
if not defined PARENT_DIR (
  echo;%?~%: error: parent directory of the CMAKE_OUTPUT_ROOT does not exist "%CMAKE_OUTPUT_ROOT%".
  exit /b 4
) >&2

if not exist "%CMAKE_OUTPUT_ROOT%" mkdir "%CMAKE_OUTPUT_ROOT%" || exit /b

if defined CMAKE_OUTPUT_GENERATOR_DIR (
  call :PARENT_DIR "%%CMAKE_OUTPUT_GENERATOR_DIR%%"
  if not defined PARENT_DIR (
    echo;%?~%: error: parent directory of the CMAKE_OUTPUT_GENERATOR_DIR does not exist "%CMAKE_OUTPUT_GENERATOR_DIR%".
    exit /b 5
  ) >&2

  if not exist "%CMAKE_OUTPUT_DIR%" mkdir "%CMAKE_OUTPUT_DIR%" || exit /b
)

call :PARENT_DIR "%%CMAKE_OUTPUT_DIR%%"
if not defined PARENT_DIR (
  echo;%?~%: error: parent directory of the CMAKE_OUTPUT_DIR does not exist "%CMAKE_OUTPUT_DIR%".
  exit /b 6
) >&2

if not exist "%CMAKE_OUTPUT_DIR%" mkdir "%CMAKE_OUTPUT_DIR%" || exit /b

if not exist "%CMAKE_BUILD_ROOT%" mkdir "%CMAKE_BUILD_DIR%" || exit /b
if not exist "%CMAKE_BIN_ROOT%" mkdir "%CMAKE_BIN_DIR%" || exit /b
if not exist "%CMAKE_LIB_ROOT%" mkdir "%CMAKE_LIB_DIR%" || exit /b
if not exist "%CMAKE_INSTALL_ROOT%" mkdir "%CMAKE_INSTALL_ROOT%" || exit /b
if not exist "%CMAKE_PACK_ROOT%" mkdir "%CMAKE_PACK_ROOT%" || exit /b

call :PARENT_DIR "%%CMAKE_BUILD_DIR%%"
if not defined PARENT_DIR (
  echo;%?~%: error: parent directory of the CMAKE_BUILD_DIR does not exist "%CMAKE_BUILD_DIR%".
  exit /b 10
) >&2

call :PARENT_DIR "%%CMAKE_BIN_DIR%%"
if not defined PARENT_DIR (
  echo;%?~%: error: parent directory of the CMAKE_BIN_DIR does not exist "%CMAKE_BIN_DIR%".
  exit /b 11
) >&2

call :PARENT_DIR "%%CMAKE_LIB_DIR%%"
if not defined PARENT_DIR (
  echo;%?~%: error: parent directory of the CMAKE_LIB_DIR does not exist "%CMAKE_LIB_DIR%".
  exit /b 12
) >&2

call :PARENT_DIR "%%CMAKE_INSTALL_ROOT%%"
if not defined PARENT_DIR (
  echo;%?~%: error: parent directory of the CMAKE_INSTALL_ROOT does not exist "%CMAKE_INSTALL_ROOT%".
  exit /b 13
) >&2

call :PARENT_DIR "%%CMAKE_PACK_DIR%%"
if not defined PARENT_DIR (
  echo;%?~%: error: parent directory of the CMAKE_PACK_DIR does not exist "%CMAKE_PACK_DIR%".
  exit /b 14
) >&2

rem return variables
(
  endlocal
  set "CMAKE_BUILD_DIR=%CMAKE_BUILD_DIR%"
  set "CMAKE_BIN_DIR=%CMAKE_BIN_DIR%"
  set "CMAKE_LIB_DIR=%CMAKE_LIB_DIR%"
  set "CMAKE_PACK_DIR=%CMAKE_PACK_DIR%"
)

if not exist "%CMAKE_BUILD_DIR%" mkdir "%CMAKE_BUILD_DIR%" || exit /b
if not exist "%CMAKE_BIN_DIR%" mkdir "%CMAKE_BIN_DIR%" || exit /b
if not exist "%CMAKE_LIB_DIR%" mkdir "%CMAKE_LIB_DIR%" || exit /b
if not exist "%CMAKE_PACK_DIR%" mkdir "%CMAKE_PACK_DIR%" || exit /b

exit /b 0

:PARENT_DIR
set "PARENT_DIR="
if "%~1" == "" exit /b 255
set "DIR=%~f1"
set "PARENT_DIR=%~dp1"
if not exist "%PARENT_DIR%" (
  set "PARENT_DIR="
  exit /b 128
)
rem check on drive root
if /i "%DIR%" == "%PARENT_DIR%" (
  set "PARENT_DIR="
  exit /b 128
)
exit /b 0

