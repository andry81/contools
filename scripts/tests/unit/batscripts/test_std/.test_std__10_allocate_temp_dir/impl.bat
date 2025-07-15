@echo off

set "TEST_DATA_DIR_LIST_FILE=%TEST_DATA_REF_DIR_PATH%\dir.lst"
set "TEST_DATA_OUTPUT_FILE_NAME_PTTN=output{{INDEX}}.txt"
set "TEST_DATA_ALLOC_SCRIPT_FILE=%TEST_DATA_REF_DIR_PATH%\allocate.bat"
set "TEST_DATA_FREE_SCRIPT_FILE=%TEST_DATA_REF_DIR_PATH%\free.bat"

rem call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_TEMP_DATA_OUT_FILE "%%TEST_TEMP_DIR%%\output.txt"

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
call set "TEST_DATA_OUTPUT_FILE_NAME=%%TEST_DATA_OUTPUT_FILE_NAME_PTTN:{{INDEX}}=%DIR_INDEX%%%"

if not exist "%DIR_PATH%\*" exit /b 2
if not exist "%DIR_PATH%\%DIR_NAME_PTTN%" exit /b 3

rem CAUTION:
rem   1. If a variable is empty, then it would not be expanded in the `cmd.exe`
rem      command line or in the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement.
rem   2. The `cmd.exe` command line or the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement does expand twice.
rem
rem   We must expand the command line into a variable to avoid these above.
rem
set ?.=@dir "%DIR_PATH%\%DIR_NAME_PTTN%" /A:D /B /O:N 2^>nul

set "DIR_NAME="
for /F "usebackq tokens=* delims=" %%i in (`%%?.%%`) do set "DIR_NAME=%%i"

if not defined DIR_NAME exit /b 4

call "%%CONTOOLS_ROOT%%/filesys/gen_dir_files_list.bat" "%%CHCP%%" "%DIR_PATH%\%DIR_NAME%" > "%TEST_DATA_OUTPUT_FILE_NAME%"

"%SystemRoot%\System32\fc.exe" "%TEST_DATA_OUTPUT_FILE_NAME%" "%TEST_DATA_REF_DIR_PATH%\%TEST_DATA_OUTPUT_FILE_NAME%" >nul || exit /b 5

set /A DIR_INDEX+=1

exit /b 0
