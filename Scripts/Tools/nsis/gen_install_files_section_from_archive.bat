@echo off

rem FILE OUTPUT EXAMPLE #1:
rem   ${BeginInstallFromArchive}
rem   SetOutPath "$INSTDIR"
rem   ${InstallFromArchive} "$EXEDIR\app_archive1.7z"
rem   SetOutPath "$INSTDIR\appsubdir"
rem   ${InstallFromArchive} "$EXEDIR\subdir\app_archive2.7z"
rem   ${EndInstallFromArchive}
rem FILE OUTPUT EXAMPLE #2:
rem   ${BeginInstallFromArchive}
rem   SetOutPath "$INSTDIR"
rem   ${InstallFromArchive} "$EXEDIR\<subpath>\app_archive1.7z"
rem   SetOutPath "$INSTDIR\appsubdir"
rem   ${InstallFromArchive} "$EXEDIR\<subpath>\subdir\app_archive2.7z"
rem   ${EndInstallFromArchive}

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
set "EXEDIR_SUBDIR=%~3"
set "FILE_FILTER=%~4"
set "INCLUDE_FILE_DIR_PATH=%~5"
set "INSTALL_FLAGS=%~6"

shift
shift
shift
shift
shift
shift

set "FILES_PATH_PREFIX="
if defined PREFIX_PATH_VAR set "FILES_PATH_PREFIX=%PREFIX_PATH_VAR%\"
set "INSTDIR_SUBDIR_SUFFIX="
if defined INSTDIR_SUBDIR set "INSTDIR_SUBDIR_SUFFIX=\%INSTDIR_SUBDIR%"
set "EXEDIR_SUBDIR_SUFFIX="
if defined EXEDIR_SUBDIR set "EXEDIR_SUBDIR_SUFFIX=%EXEDIR_SUBDIR%\"
set "FILE_FILTER_SUFFIX="
if defined FILE_FILTER set "FILE_FILTER_SUFFIX=\%FILE_FILTER%"

echo.!define INCLUDE_FILE_DIR "%INCLUDE_FILE_DIR_PATH%"
echo.
echo.${BeginInstallFromArchive}

:PROCESS_DIR_LOOP
call :PROCESS_DIR_PATH "%~1" || exit /b

shift 

if exist "%~1" goto PROCESS_DIR_LOOP

echo.${EndInstallFromArchive}
echo.
echo.!undef INCLUDE_FILE_DIR
echo.

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b 0

:PROCESS_DIR_PATH
set "BASE_DIR_PATH=%~f1"

call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v BASE_DIR_PATH
set /A BASE_DIR_PATH_LEN=%ERRORLEVEL%

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

exit /b

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

echo.${InstallFromArchive} "%INSTALL_FLAGS%" "%FILES_PATH_PREFIX%%EXEDIR_SUBDIR_SUFFIX%%FILE_PATH%"

set /A FILE_INDEX+=1

exit /b 0
