@echo off

rem FILE OUTPUT EXAMPLE:
rem  Delete "$INSTDIR\uninst.exe"
rem  Delete "$INSTDIR\universal_tract\XORBitstreams.dll"
rem  Delete "$INSTDIR\universal_tract\VSatSync.dll"
rem  RMDir "$INSTDIR\universal_tract"

setlocal

call "%%~dp0__init__.bat" || exit /b

set "?~nx0=%~nx0"

rem get code page value from first parameter
set "LAST_CODE_PAGE="
set "CODE_PAGE=%~1"

shift

rem get and set code page
call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%CODE_PAGE%%

set "FILES_PATH_PREFIX=%~1"
set "INSTDIR_SUBDIR=%~2"
set "FILE_FILTER=%~3"

shift
shift
shift

set "INSTDIR_SUBDIR_SUFFIX="
if defined INSTDIR_SUBDIR set "INSTDIR_SUBDIR_SUFFIX=\%INSTDIR_SUBDIR%"
set "FILE_FILTER_SUFFIX="
if defined FILE_FILTER set "FILE_FILTER_SUFFIX=\%FILE_FILTER%"

:PROCESS_DIR_LOOP
call :PROCESS_DIR_PATH "%%~1" || exit /b

shift 

if exist "%~1" goto PROCESS_DIR_LOOP

if defined INSTDIR_SUBDIR (
  echo.RMDir "$INSTDIR%INSTDIR_SUBDIR_SUFFIX%"
)

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b 0

:PROCESS_DIR_PATH
set "BASE_DIR_PATH=%~f1"

call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v BASE_DIR_PATH
set /A BASE_DIR_PATH_LEN=%ERRORLEVEL%

set DIR_INDEX=0
set "DIR_PATH=%BASE_DIR_PATH%"
call :PROCESS_DIR_FILES || ( popd & exit /b )

rem CAUTION:
rem   If a variable is empty, then it would not be expanded in the `cmd.exe` command line or in case of `for /F ...`!
rem   We must expand the command line into a variable.
rem
set ?.=@dir . /A:D /B /O:N /S

set DIR_INDEX=0
pushd "%BASE_DIR_PATH%" && (
  for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do (
    set "DIR_PATH=%%i"
    call :PROCESS_DIR_FILES || ( popd & exit /b )
  )
  popd
)

set NUM_DIRS=%DIR_INDEX%

rem CAUTION:
rem   If a variable is empty, then it would not be expanded in the `cmd.exe` command line or in case of `for /F ...`!
rem   We must expand the command line into a variable.
rem
set ?.=@dir . /A:D /B /O:N /S

set DIR_INDEX=0
pushd "%BASE_DIR_PATH%" && (
  for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do (
    set "DIR_PATH=%%i"
    call :INDEX_DIR_PATH
  )
  popd
)

set /A NUM_DIRS_LAST=NUM_DIRS-1
for /L %%i in (%NUM_DIRS_LAST%,-1,0) do (
  set LINE_INDEX=%%i
  call :PROCESS_LINE_DIR || exit /b
)
if %NUM_DIRS% NEQ 0 (
  echo.
)

exit /b

:INDEX_DIR_PATH
set "LINE_%DIR_INDEX%=%DIR_PATH%"
set /A DIR_INDEX+=1
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
if %FILE_INDEX% NEQ 0 (
  echo.
)

set /A DIR_INDEX+=1

exit /b

:PROCESS_LINE_DIR
call set "DIR_PATH=%%LINE_%LINE_INDEX%%%"
call set "FILE_DIR_PATH=%%DIR_PATH:~%BASE_DIR_PATH_LEN%%%"

if defined FILE_DIR_PATH set "FILE_DIR_PATH=%FILE_DIR_PATH:~1%"

if defined FILE_DIR_PATH ^
if not exist "%DIR_PATH%\*" (
  echo.%?~nx0%: error: found directory does not exist: "%DIR_PATH%"
  exit /b 2
) >&2

if defined FILE_DIR_PATH (
  echo.RMDir "$INSTDIR%INSTDIR_SUBDIR_SUFFIX%\%FILE_DIR_PATH%"
) else (
  echo.RMDir "$INSTDIR%INSTDIR_SUBDIR_SUFFIX%"
)

exit /b 0

:PROCESS_FILE
set "FILE_NAME=%~1"

if defined FILE_DIR_PATH (
  set "FILE_PATH=%FILE_DIR_PATH%\%FILE_NAME%"
) else (
  set "FILE_PATH=%FILE_NAME%"
)

if not exist "%DIR_PATH%\%FILE_NAME%" (
  echo.%?~nx0%: error: found file path does not exist: "%DIR_PATH%\%FILE_NAME%"
  exit /b 1
) >&2

echo.Delete "%FILES_PATH_PREFIX%%INSTDIR_SUBDIR_SUFFIX%\%FILE_PATH%"

set /A FILE_INDEX+=1

exit /b 0
