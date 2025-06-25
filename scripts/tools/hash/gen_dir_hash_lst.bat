@echo off & goto DOC_END

rem Description:
rem   Directory file hashes generation script.
rem   Generates a directory file hashes not sorted list.
rem   File hashes per line format: (depends on flag -c)
rem     <size>,<Hash1>,<Hash2>,...,<HashN>,<path>

rem Examples:
rem 1. call gen_dir_hash_lst.bat -c "md5,sha256" -l -r . > dir_hash_list.lst
:DOC_END

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

set "?~nx0=%~nx0"

rem script flags
set "HASHDEEP_CMD_FLAG_ARGS="

rem hashdeep flags
set "HASHDEEP_CMD_ARGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-c" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else if "%FLAG%" == "-p" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else if "%FLAG%" == "-k" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else if "%FLAG%" == "-j" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else if "%FLAG%" == "-o" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else if "%FLAG%" == "-i" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else if "%FLAG%" == "-f" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else (
    set HASHDEEP_CMD_ARGS=%HASHDEEP_CMD_ARGS%%1 
    shift
  )

  rem read until no flags
  goto FLAGS_LOOP
)

:ARGSN_LOOP
if not "%~1" == "" (
  set HASHDEEP_CMD_ARGS=%HASHDEEP_CMD_ARGS%%1 
  shift
  goto ARGSN_LOOP
)

call "%%CONTOOLS_ROOT%%/hash/hashdeep.bat" %%HASHDEEP_CMD_FLAG_ARGS%% %%HASHDEEP_CMD_ARGS%%
