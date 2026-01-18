@echo off & goto DOC_END

rem Description:
rem   Script to print log file names with corrupted part files in them.
:DOC_END

setlocal

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

rem call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

:FREE_TEMP_DIR
rem cleanup temporary files
rem call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LAST_ERROR%

:MAIN
for %%i in ("%EMULE_LOG_DIR%\*.log") do ^
call "%%CONTOOLS_ROOT%%/unix/ugrep/ugrep.bat" -l ^
  -e "Failed to open part\.met file! \([0-9][0-9]*\.part\.met\.bak " ^
  -e "[0-9][0-9]*\.part\.met\.bak \(\) is corrupt" ^
  -e "Invalid part\.met file version! \([0-9][0-9]*\.part\.met\.bak " ^
  -e "[0-9][0-9]*\.part\.met \(\) is corrupt" ^
  -e "Invalid part\.met file version! \([0-9][0-9]*\.part\.met " ^
  "%%i"
