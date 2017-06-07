@echo off

setlocal

call "%%~dp0__init__.bat" || goto :EOF

set "?~n0=%~n0"
set "?~nx0=%~nx0"

rem builtin defaults
if "%TORTOISEPROC_MAX_CALLS%" == "" set TORTOISEPROC_MAX_CALLS=10

rem script flags
set FLAG_WAIT_EXIT=0

rem single window for all changes
if "%COMMAND%" == "/command:repostatus" (
  rem all-in-one by default in case of repostatus command
  set FLAG_ALL_IN_ONE=1
) else set FLAG_ALL_IN_ONE=0

rem window per WC root
if "%COMMAND%" == "/command:commit" (
  rem window-per-wcroot by default in case of commit command
  set FLAG_WINDOW_PER_WCROOT=1
) else set FLAG_WINDOW_PER_WCROOT=0

rem window-per-wcroot by default in case of other commands
if %FLAG_ALL_IN_ONE%%FLAG_WINDOW_PER_WCROOT% EQU 0 set FLAG_WINDOW_PER_WCROOT=1

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
  if "%FLAG%" == "-wait" (
    set FLAG_WAIT_EXIT=1
    shift
  ) else if "%FLAG%" == "-all-in-one" (
    set FLAG_ALL_IN_ONE=1
  ) else if "%FLAG%" == "-window-per-wcroot" (
    set FLAG_WINDOW_PER_WCROOT=1
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  )

  rem read until no flags
  goto FLAGS_LOOP
)

set "COMMAND=%~1"
set "PWD=%~2"
shift
shift

if "%PWD%" == "" goto NOPWD
( %PWD:~0,2% && cd "%PWD%" ) || exit /b 1

:NOPWD

call "%%CONTOOLS_ROOT%%/get_datetime.bat"
set "TEMP_DATE=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%"
set "TEMP_TIME=%RETURN_VALUE:~8,2%_%RETURN_VALUE:~10,2%_%RETURN_VALUE:~12,2%_%RETURN_VALUE:~15,3%"

set "TEMP_FILE_DIR=%TEMP%\%?~n0%.%TEMP_DATE%.%TEMP_TIME%"
set "TORTOISEPROC_PATHFILE_ANSI_TMP=%TEMP_FILE_DIR%\pathfile-ansi.lst"
if %FLAG_WAIT_EXIT% NEQ 0 (
  rem use temporary file inside script temporary directory
  set "TORTOISEPROC_PATHFILE_UCS16BE_TMP=%TEMP_FILE_DIR%\pathfile-ucs-16BE.lst"
) else (
  rem use temporary file outside script temporary directory, delegate to TortoiseProc.exe it's deletion
  set "TORTOISEPROC_PATHFILE_UCS16BE_TMP=%TEMP%\%?~n0%.%TEMP_DATE%.%TEMP_TIME%.pathfile-ucs-16BE.lst"
)

rem create temporary files to store local context output
if exist "%TEMP_FILE_DIR%\" (
  echo.%?~nx0%: error: temporary generated directory TEMP_FILE_DIR is already exist: "%TEMP_FILE_DIR%"
  exit /b 1
) >&2

mkdir "%TEMP_FILE_DIR%"

rem create empty files
type nul > "%TORTOISEPROC_PATHFILE_ANSI_TMP%"

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

if %FLAG_ALL_IN_ONE% NEQ 0 (
  rem convert to UCS-16BE w/o bom
  call "%%CONTOOLS_ROOT%%/encoding/ansi2any.bat" "" UCS-2BE "%%TORTOISEPROC_PATHFILE_ANSI_TMP%%" > "%TORTOISEPROC_PATHFILE_UCS16BE_TMP%" || goto EXIT
  pause
  rem execute path file
  if %FLAG_WAIT_EXIT% NEQ 0 (
    call :CMD start /B /WAIT "" TortoiseProc.exe %%COMMAND%% /pathfile:"%TORTOISEPROC_PATHFILE_UCS16BE_TMP%"
  ) else (
    call :CMD start /B "" TortoiseProc.exe %%COMMAND%% /pathfile:"%TORTOISEPROC_PATHFILE_UCS16BE_TMP%" /deletepathfile
  )
  set LASTERROR=%ERRORLEVEL%
)

:EXIT
rem cleanup temporary files
rmdir /S /Q "%TEMP_FILE_DIR%"

rem if %FLAG_WAIT_EXIT% EQU 0 (
rem   rem delete the external file in case if left behind
rem   del /F /Q /A:-D "%TORTOISEPROC_PATHFILE_UCS16BE_TMP%"
rem )

exit /b %LASTERROR%

:MAIN
setlocal

rem run only first TORTOISEPROC_MAX_CALLS
set CURDIR_INDEX=0
set CALL_INDEX=0

rem run COMMAND over selected files/directories in the PWD directory
:CURDIR_LOOP
if %CALL_INDEX% GEQ %TORTOISEPROC_MAX_CALLS% exit /b 0

rem ignore first 2 parameters
if %CURDIR_INDEX% GEQ 2 goto CURDIR_CONTINUE

rem ignore flags
set FLAG=%1
if ^%FLAG:~0,1% == - goto NEXT_CURDIR

set /A CURDIR_INDEX+=1
goto NEXT_CURDIR

:CURDIR_CONTINUE
set "FILENAME=%~1"
if "%FILENAME%" == "" exit /b 0

rem ignore files selection
if not exist "%FILENAME%\" == "" goto NEXT_CURDIR

if %FLAG_WINDOW_PER_WCROOT% NEQ 0 (
  rem recreate empty files
  type nul > "%TORTOISEPROC_PATHFILE_ANSI_TMP%"
)

for /F "usebackq eol=	 tokens=* delims=" %%i in (`dir /S /B /A:D "%FILENAME%\*.svn" 2^>nul`) do (
  set DIR_PATH=%%i
  call :PROCESS_DIR_PATH
)

set /A CALL_INDEX+=1

if %FLAG_WINDOW_PER_WCROOT% NEQ 0 (
  rem convert to UCS-16BE w/o bom
  call "%%CONTOOLS_ROOT%%/encoding/ansi2any.bat" "" UCS-2BE "%%TORTOISEPROC_PATHFILE_ANSI_TMP%%" > "%TORTOISEPROC_PATHFILE_UCS16BE_TMP%" || goto NEXT_CURDIR
  rem execute path file
  if %FLAG_WAIT_EXIT% NEQ 0 (
    call :CMD start /B /WAIT "" TortoiseProc.exe %%COMMAND%% /pathfile:"%TORTOISEPROC_PATHFILE_UCS16BE_TMP%"
  ) else (
    call :CMD start /B "" TortoiseProc.exe %%COMMAND%% /pathfile:"%TORTOISEPROC_PATHFILE_UCS16BE_TMP%" /deletepathfile
  )
)

:NEXT_CURDIR
shift

goto CURDIR_LOOP

:CMD
echo.^>%*
(%*)
exit /b

:PROCESS_DIR_PATH
call :GET_DIR_PARENT "%%DIR_PATH%%"
set "WCROOT_PATH=%DIR_PARENT_PATH%"

if "%COMMAND%" == "/command:commit" ( call "%%SVNCMD_TOOLS_ROOT%%/svn_has_changes.bat" -stat-exclude-? "%%WCROOT_PATH%%" )
if "%COMMAND%" == "/command:commit" (
  rem call anyway if error happened
  if %ERRORLEVEL% EQU 0 (
    if %RETURN_VALUE% EQU 0 exit /b 0
  )
)

rem write to path file (special form of the echo command to ignore special characters in the WCROOT_PATH value)
rem set "WCROOT_PATH=%WCROOT_PATH:\=/%"
for /F "tokens=* delims=" %%i in ("%WCROOT_PATH%") do (echo.%%i) >> "%TORTOISEPROC_PATHFILE_ANSI_TMP%"

exit /b

:GET_DIR_PARENT
set "DIR_PARENT_PATH=%~dp1"
rem remove last back slash in case if not the root directory of a drive
if not "%DIR_PARENT_PATH:~-2,1%" == ":" set "DIR_PARENT_PATH=%DIR_PARENT_PATH:~0,-1%"
