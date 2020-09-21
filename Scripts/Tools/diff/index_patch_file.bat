@echo off

rem Drop return value
set RETURN_VALUE=0

call "%%~dp0__init__.bat" || exit /b

set "__VAR_NAME_PREFIX__=%~1"
set "__PATCH_FILE__=%~2"

if not defined __VAR_NAME_PREFIX__ (
  echo.%~nx0: error: Variable name prefix is not set.
  exit /b 1
) >&2

if not exist "%__PATCH_FILE__%" (
  echo.%~nx0: error: Patch file does not exists: "%__PATCH_FILE__%".
  exit /b 2
) >&2

rem print diff patch file without file content changes to resolve binary differences
set "__PATCH_FILE_PATH__="
set __PATCH_FILE_INDEX__=1
set __PATCH_FILE_LAST_INDEX__=1
set __PATCH_FILE_INDEX_OFFSET__=0
for /F "usebackq eol= tokens=* delims=" %%i in (`@"%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" -n "/^Index: /,/\(^@@ \|^GIT binary patch$\)/ { /\(^@@ \|^GIT binary patch$\)/b; p }" "%__PATCH_FILE__%" 2^>nul`) do (
  set "__PATCH_FILE_LINE__=%%i"
  call :PROCESS_PATCH_FILE_LINE || exit /b
  set /A __PATCH_FILE_INDEX_OFFSET__+=1
)

(
  rem Drop local variables
  set "__VAR_NAME_PREFIX__="
  set "__PATCH_FILE__="
  set "__PATCH_FILE_LINE__="
  set "__PATCH_FILE_PATH__="
  set "__PATCH_FILE_INDEX__="
  set "__PATCH_FILE_INDEX_FOUND__="
  set "__PATCH_FILE_INDEX_OFFSET__="
  set "__PATCH_FILE_INDEX_VAR__="
  set "__PATCH_FILE_INDEX_VALUE__="
  set "__PATCH_FILE_LAST_INDEX__="

  set /A "RETURN_VALUE=%__PATCH_FILE_LAST_INDEX__%-1"
)

exit /b 0

:PROCESS_PATCH_FILE_LINE
if not defined __PATCH_FILE_LINE__ exit /b 0
if not "%__PATCH_FILE_LINE__:~0,7%" == "Index: " goto INDEX_END

set __PATCH_FILE_INDEX_OFFSET__=0

set "__PATCH_FILE_PATH__=%__PATCH_FILE_LINE__:~7%"
set "__PATCH_FILE_PATH__=%__PATCH_FILE_PATH__:\=/%"

set "__PATCH_FILE_INDEX_VAR__=%__VAR_NAME_PREFIX__%.index#%__PATCH_FILE_PATH__%"
call set "__PATCH_FILE_INDEX_VALUE__=%%%__PATCH_FILE_INDEX_VAR__%%%"

if defined __PATCH_FILE_INDEX_VALUE__ (
  call set "__PATCH_FILE_INDEX__=%__PATCH_FILE_INDEX_VALUE__%"
) else (
  set __PATCH_FILE_INDEX__=%__PATCH_FILE_LAST_INDEX__%
  set "%__PATCH_FILE_INDEX_VAR__%=%__PATCH_FILE_LAST_INDEX__%"
  set "%__VAR_NAME_PREFIX__%.%__PATCH_FILE_LAST_INDEX__%.FILE=%__PATCH_FILE_PATH__%"
  set /A __PATCH_FILE_LAST_INDEX__+=1
)

exit /b 0

:INDEX_END
if %__PATCH_FILE_INDEX_OFFSET__% GEQ 4 exit /b 0

if %__PATCH_FILE_INDEX_OFFSET__% EQU 1 (
  if "%__PATCH_FILE_LINE__:~0,4%" == "====" exit /b 0
)
if %__PATCH_FILE_INDEX_OFFSET__% EQU 2 (
  if "%__PATCH_FILE_LINE__:~0,16%" == "Cannot display: " (
    set "%__VAR_NAME_PREFIX__%.%__PATCH_FILE_INDEX__%.NODIFF=1"
    exit /b 0
  )
  rem register file as version control added
  if "%__PATCH_FILE_LINE__:~0,4%" == "--- " (
    if not "%__PATCH_FILE_LINE__:	(nonexistent)=%" == "%__PATCH_FILE_LINE__%" set "%__VAR_NAME_PREFIX__%.%__PATCH_FILE_INDEX__%.NONEXISTENT_BEFORE=1"
    exit /b 0
  )
)
if %__PATCH_FILE_INDEX_OFFSET__% EQU 3 (
  rem register file as version control removed
  if "%__PATCH_FILE_LINE__:~0,4%" == "+++ " (
    if not "%__PATCH_FILE_LINE__:	(nonexistent)=%" == "%__PATCH_FILE_LINE__%" set "%__VAR_NAME_PREFIX__%.%__PATCH_FILE_INDEX__%.NONEXISTENT_AFTER=1"
    exit /b 0
  )
)

exit /b 0
