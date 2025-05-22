@echo off & goto DOC_END

rem Description:
rem   Directory file hashes difference generation script.
rem   Generates directories file hash difference list.
rem   File hashes per line format:
rem     <size>|<md5>|<sha256>|<path>
rem   Difference list format:
rem     <path>

rem Examples:
rem 1. call gen_dir_hash_lst.bat . > dir_hash_list.lst
rem    call gen_diff_dir_hash_lst.bat . dir_hash_list.lst > dir_hash_list_diff.lst
rem    type dir_hash_list_diff.lst
:DOC_END

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "DIR_PATH_FROM=%~f1"
set "HASH_LIST_FILE=%~f2"

if not exist "%DIR_PATH_FROM%\*" (
  echo;%?~%: error: hashing directory does not exist: "%DIR_PATH_FROM%"
  exit /b 1
) >&2

if not exist "%HASH_LIST_FILE%" (
  echo;%?~%: error: hash list files does not exist: "%HASH_LIST_FILE%"
  exit /b 2
) >&2

call "%%~dp0__init__\__init__.bat" || exit /b

rem use 64-bit application in 64-bit OS
if not "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto NOTX64
rem in case of wrong PROCESSOR_ARCHITECTURE value
if defined PROCESSOR_ARCHITEW6432 goto NOTX64
goto X64

:NOTX64
"%CONTOOLS_HASHDEEP_ROOT%/hashdeep.exe" -x -k "%HASH_LIST_FILE%" -r "%DIR_PATH_FROM%"
exit /b

:X64
"%CONTOOLS_HASHDEEP_ROOT%/hashdeep64.exe" -x -k "%HASH_LIST_FILE%" -r "%DIR_PATH_FROM%"
exit /b
