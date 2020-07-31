@echo off

call :GET_ABSOLUTE_PATH "%%TEST_DATA_BASE_DIR%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_REF_DIR%%"
set "TEST_DATA_REF_DIR_ROOT=%RETURN_VALUE%"

set "TEST_DATA_DIR_LIST_FILE=%TEST_DATA_REF_DIR_ROOT%\dir.lst"
set "TEST_DATA_OUTPUT_FILE_NAME_PTTN=output{{INDEX}}.txt"
set "TEST_DATA_ALLOC_SCRIPT_FILE=%TEST_DATA_REF_DIR_ROOT%\allocate.bat"
set "TEST_DATA_FREE_SCRIPT_FILE=%TEST_DATA_REF_DIR_ROOT%\free.bat"

call :GET_ABSOLUTE_PATH "%%TEST_TEMP_DIR%%\output.txt"
set "TEST_DATA_OUT_FILE=%RETURN_VALUE%"

rem make an allocation
call "%%TEST_DATA_ALLOC_SCRIPT_FILE%%"

rem switch to the temporary directory
pushd "%TEST_TEMP_DIR%" || exit /b 1

rem read the temporary directories structure
set DIR_INDEX=0
for /F "usebackq tokens=1,* delims=|" %%i in ("%TEST_DATA_DIR_LIST_FILE%") do (
  set "DIR_PATH=%%i"
  set "DIR_NAME_PTTN=%%j"
  call :PROCESS_DIR || ( popd & exit /b )
)

popd

rem make free
call "%%TEST_DATA_FREE_SCRIPT_FILE%%"

exit /b 0

:PROCESS_DIR
if not exist "%DIR_PATH%\" exit /b 2
if not exist "%DIR_PATH%\%DIR_NAME_PTTN%" exit /b 3

set "DIR_NAME="
for /F "usebackq tokens=* delims=" %%i in (`dir /A:D /B "%DIR_PATH%\%DIR_NAME_PTTN%"`) do set "DIR_NAME=%%i"

if not defined DIR_NAME exit /b 4

call set "TEST_DATA_OUTPUT_FILE_NAME=%%TEST_DATA_OUTPUT_FILE_NAME_PTTN:{{INDEX}}=%DIR_INDEX%%%"

call "%%CONTOOLS_ROOT%%/gen_dir_files_list.bat" 65001 "%DIR_PATH%\%DIR_NAME%" > "%TEST_DATA_OUTPUT_FILE_NAME%"

fc "%TEST_DATA_OUTPUT_FILE_NAME%" "%TEST_DATA_REF_DIR_ROOT%\%TEST_DATA_OUTPUT_FILE_NAME%" > nul
if %ERRORLEVEL% NEQ 0 exit /b 5

set /A DIR_INDEX+=1

exit /b 0

:GET_ABSOLUTE_PATH
set "RETURN_VALUE=%~dpf1"
exit /b 0
