@echo off & goto DOC_END

rem Description:
rem   Script can check a directory existence in case of the read permissions
rem   deny on a directory.
rem
rem   Does support long paths.
rem
rem   NOTE:
rem     All input paths must be without `\\?\` prefix because:
rem       1. Can be directly used in commands which does not support long paths
rem          like builtin `dir` command.
rem       2. Can be checked on absence of globbing characters which includes
rem          `?` character.
rem       3. The `%%~f` builtin variables extension and other extensions does
rem          remove the prefix and then a path can be prefixed internally by
rem          the script.

rem Based on:
rem   https://stackoverflow.com/questions/138981/how-to-test-if-a-file-is-a-directory-in-a-batch-script/3728742#3728742
:DOC_END

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

if "%~1" == "" (
  echo;%?~%: error: directory path is not defined.
  exit /b 255
) >&2

for /F "tokens=* delims="eol^= %%i in ("%~1\.") do set "FILE_PATH=%%~fi"

if not exist "\\?\%FILE_PATH%\*" exit /b 1

for /F "tokens=* delims="eol^= %%i in ("\\?\%FILE_PATH%") do set "FILE_PATH_ATTR=%%~ai"
if not defined FILE_PATH_ATTR exit /b 255

if /i "%FILE_PATH_ATTR:d=%" == "%FILE_PATH_ATTR%" exit /b 2

exit /b 0
