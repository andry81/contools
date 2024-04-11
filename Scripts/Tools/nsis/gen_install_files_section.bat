@echo off

rem FILE OUTPUT EXAMPLE #1:
rem  SetOutPath "$INSTDIR\app\exec"
rem  File "${%PREFIX_PATH_VAR%}\app\exec\MyProject.xml"
rem  File "${%PREFIX_PATH_VAR%}\app\exec\default.xml"
rem FILE OUTPUT EXAMPLE #2:
rem  SetOutPath "$INSTDIR\app\exec"
rem  File "${%PREFIX_PATH_VAR%}\<subpath>\app\exec\MyProject.xml"
rem  File "${%PREFIX_PATH_VAR%}\<subpath>\app\exec\default.xml"

setlocal

call "%%~dp0__init__.bat" || exit /b

set "?~nx0=%~nx0"

rem get code page value from first parameter
set "LAST_CODE_PAGE="
set "CODE_PAGE=%~1"

shift

rem get and set code page
call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%CODE_PAGE%%

set "PREFIX_PATH_VAR=%~1"
set "INSTDIR_SUBDIR=%~2"
set "FILE_FILTER=%~3"

shift
shift
shift

set "FILES_PATH_PREFIX="
if defined PREFIX_PATH_VAR set "FILES_PATH_PREFIX=${%PREFIX_PATH_VAR%}\"
set "INSTDIR_SUBDIR_SUFFIX="
if defined INSTDIR_SUBDIR set "INSTDIR_SUBDIR_SUFFIX=\%INSTDIR_SUBDIR%"
set "FILE_FILTER_SUFFIX="
if defined FILE_FILTER set "FILE_FILTER_SUFFIX=\%FILE_FILTER%"

if defined INSTDIR_SUBDIR (
  echo.CreateDirectory "$INSTDIR%INSTDIR_SUBDIR_SUFFIX%"
  echo.
)

:PROCESS_DIR_LOOP
call :PROCESS_DIR_PATH "%~1" || exit /b

shift 

if exist "%~1" goto PROCESS_DIR_LOOP

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b 0

:PROCESS_DIR_PATH
set "BASE_DIR_PATH=%~f1"

rem <BASE_DIR_SUFFIX> = <BASE_DIR_PATH> - <PREFIX_PATH>

call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v BASE_DIR_PATH
set /A BASE_DIR_PATH_LEN=%ERRORLEVEL%

call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v %%PREFIX_PATH_VAR%%
set /A PREFIX_PATH_LEN=%ERRORLEVEL%

set "BASE_DIR_SUFFIX="

if %BASE_DIR_PATH_LEN% GTR %PREFIX_PATH_LEN% (
  call set "BASE_DIR_SUFFIX=%%BASE_DIR_PATH:~%PREFIX_PATH_LEN%%%"
)

if %PREFIX_PATH_LEN% GTR 0 (
  if defined BASE_DIR_SUFFIX set "BASE_DIR_SUFFIX=%BASE_DIR_SUFFIX:~1%"
)

set "DIR_PATH=%BASE_DIR_PATH%"
call :PROCESS_DIR_FILES || ( popd & exit /b )

rem CAUTION:
rem   If a variable is empty, then it would not be expanded in the `cmd.exe` command line or in case of `for /F ...`!
rem   We must expand the command line into a variable.
rem
set ?.=@dir . /A:D /B /O:N /S

pushd "%BASE_DIR_PATH%" && (
  for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do (
    set "DIR_PATH=%%i"
    call :PROCESS_DIR_FILES || ( popd & exit /b )
  )
  popd
)

exit /b

:PROCESS_DIR_FILES
call set "FILE_DIR_PATH=%%DIR_PATH:~%BASE_DIR_PATH_LEN%%%"

if defined FILE_DIR_PATH set "FILE_DIR_PATH=%FILE_DIR_PATH:~1%"

rem CAUTION:
rem   If a variable is empty, then it would not be expanded in the `cmd.exe` command line or in case of `for /F ...`!
rem   We must expand the command line into a variable.
rem
set ?.=@dir "%DIR_PATH%%FILE_FILTER_SUFFIX%" /A:-D /B /O:N

set FILE_INDEX=0
for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do (
  if not "%%i" == "" ( call :PROCESS_FILE "%%i" || exit /b )
)
if %FILE_INDEX% EQU 0 (
  call :CREATE_FILES_DIR || exit /b
)
echo.

exit /b

:CREATE_FILES_DIR
if defined FILE_DIR_PATH ^
if not exist "%DIR_PATH%\*" (
  echo.%?~nx0%: error: found directory does not exist: "%DIR_PATH%"
  exit /b 2
) >&2

if defined FILE_DIR_PATH (
  echo.CreateDirectory "$INSTDIR%INSTDIR_SUBDIR_SUFFIX%\%FILE_DIR_PATH%"
) else (
  echo.CreateDirectory "$INSTDIR%INSTDIR_SUBDIR_SUFFIX%"
)

exit /b 0

:PROCESS_FILE
set "FILE_NAME=%~1"

if %FILE_INDEX% EQU 0 (
  if defined FILE_DIR_PATH (
    echo.SetOutPath "$INSTDIR%INSTDIR_SUBDIR_SUFFIX%\%FILE_DIR_PATH%"
  ) else (
    echo.SetOutPath "$INSTDIR%INSTDIR_SUBDIR_SUFFIX%"
  )
)

if defined FILE_DIR_PATH (
  set "FILE_PATH=%FILE_DIR_PATH%\%FILE_NAME%"
) else (
  set "FILE_PATH=%FILE_NAME%"
)

if not exist "%DIR_PATH%\%FILE_NAME%" (
  echo.%?~nx0%: error: found file path does not exist: "%DIR_PATH%\%FILE_NAME%"
  exit /b 1
) >&2

if defined BASE_DIR_SUFFIX (
  echo.File "%FILES_PATH_PREFIX%%BASE_DIR_SUFFIX%\%FILE_PATH%"
) else (
  echo.File "%FILES_PATH_PREFIX%%FILE_PATH%"
)

set /A FILE_INDEX+=1

exit /b 0
