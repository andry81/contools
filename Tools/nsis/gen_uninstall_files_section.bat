@echo off

rem FILE OUTPUT EXAMPLE:
rem  Delete "$INSTDIR\uninst.exe"
rem  Delete "$INSTDIR\universal_tract\XORBitstreams.dll"
rem  Delete "$INSTDIR\universal_tract\VSatSync.dll"
rem  RMDir "$INSTDIR\universal_tract"

setlocal

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0.."
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

set "?~nx0=%~nx0"

rem drop last error level
cd .

rem get code page value from first parameter
set "LAST_CODE_PAGE="
set "CODE_PAGE=%~1"

shift

if "%CODE_PAGE%" == "" goto NOCODEPAGE

for /F "usebackq eol= tokens=1,* delims=:" %%i in (`chcp 2^>nul`) do set LAST_CODE_PAGE=%%j
set LAST_CODE_PAGE=%LAST_CODE_PAGE: =%

if not "%LAST_CODE_PAGE%" == "%CODE_PAGE%" chcp %CODE_PAGE% >nul

:NOCODEPAGE
set "FILES_PATH_PREFIX=%~1"
set "INSTDIR_SUBDIR=%~2"
set "FILE_FILTER=%~3"

shift
shift
shift

set "INSTDIR_SUBDIR_SUFFIX="
if not "%INSTDIR_SUBDIR%" == "" set "INSTDIR_SUBDIR_SUFFIX=\%INSTDIR_SUBDIR%"
set "FILE_FILTER_SUFFIX="
if not "%FILE_FILTER%" == "" set "FILE_FILTER_SUFFIX=\%FILE_FILTER%"

:PROCESS_DIR_LOOP
call :PROCESS_DIR_PATH "%%~1" || goto :EOF

shift 

if exist "%~1" goto PROCESS_DIR_LOOP

if not "%INSTDIR_SUBDIR%" == "" (
  echo.RMDir "$INSTDIR%INSTDIR_SUBDIR_SUFFIX%"
)

if not "%LAST_CODE_PAGE%" == "%CODE_PAGE%" chcp %LAST_CODE_PAGE% >nul

exit /b 0

:PROCESS_DIR_PATH
set "BASE_DIR_PATH=%~dpf1"

call "%%TOOLS_PATH%%\strlen.bat" /v BASE_DIR_PATH
set /A BASE_DIR_PATH_LEN=%ERRORLEVEL%

set DIR_INDEX=0
set "DIR_PATH=%BASE_DIR_PATH%"
call :PROCESS_DIR_FILES || ( popd & goto :EOF )

set DIR_INDEX=0
pushd "%BASE_DIR_PATH%" && (
  for /F "usebackq eol= tokens=* delims=" %%i in (`dir . /S /B /A:D 2^>nul`) do (
    set "DIR_PATH=%%i"
    call :PROCESS_DIR_FILES || ( popd & goto :EOF )
  )
  popd
)

set NUM_DIRS=%DIR_INDEX%

set DIR_INDEX=0
pushd "%BASE_DIR_PATH%" && (
  for /F "usebackq eol= tokens=* delims=" %%i in (`dir . /S /B /A:D 2^>nul`) do (
    set "DIR_PATH=%%i"
    call :INDEX_DIR_PATH
  )
  popd
)

set /A NUM_DIRS_LAST=NUM_DIRS-1
for /L %%i in (%NUM_DIRS_LAST%,-1,0) do (
  set LINE_INDEX=%%i
  call :PROCESS_LINE_DIR || goto :EOF
)
if %NUM_DIRS% NEQ 0 (
  echo.
)

goto :EOF

:INDEX_DIR_PATH
set "LINE_%DIR_INDEX%=%DIR_PATH%"
set /A DIR_INDEX+=1
goto :EOF

:PROCESS_DIR_FILES
call set "FILE_DIR_PATH=%%DIR_PATH:~%BASE_DIR_PATH_LEN%%%"

if not "%FILE_DIR_PATH%" == "" set "FILE_DIR_PATH=%FILE_DIR_PATH:~1%"

set FILE_INDEX=0
for /F "usebackq eol= tokens=* delims=" %%i in (`dir "%DIR_PATH%%FILE_FILTER_SUFFIX%" /B /A:-D 2^>nul`) do (
  if not "%%i" == "" ( call :PROCESS_FILE "%%i" || goto :EOF )
)
if %FILE_INDEX% NEQ 0 (
  echo.
)

set /A DIR_INDEX+=1

goto :EOF

:PROCESS_LINE_DIR
call set "DIR_PATH=%%LINE_%LINE_INDEX%%%"
call set "FILE_DIR_PATH=%%DIR_PATH:~%BASE_DIR_PATH_LEN%%%"

if not "%FILE_DIR_PATH%" == "" set "FILE_DIR_PATH=%FILE_DIR_PATH:~1%"

if not "%FILE_DIR_PATH%" == "" ^
if not exist "%DIR_PATH%\" (
  echo.%?~nx0%: error: found directory does not exist: "%DIR_PATH%"
  exit /b 2
) >&2

if not "%FILE_DIR_PATH%" == "" (
  echo.RMDir "$INSTDIR%INSTDIR_SUBDIR_SUFFIX%\%FILE_DIR_PATH%"
) else (
  echo.RMDir "$INSTDIR%INSTDIR_SUBDIR_SUFFIX%"
)

exit /b 0

:PROCESS_FILE
set "FILE_NAME=%~1"

if not "%FILE_DIR_PATH%" == "" (
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
