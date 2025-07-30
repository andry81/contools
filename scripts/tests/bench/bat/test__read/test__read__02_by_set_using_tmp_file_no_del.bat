@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEMP_DIR  "%%TEST_DATA_TEMP_ROOT%%/%%~n0"
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%TEMP_DIR%%" >nul || exit /b

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

setlocal ENABLEDELAYEDEXPANSION

for /L %%i in (1,1,1000) do (
  set "TEMP_FILE=%TEMP_DIR%\tmp-!RANDOM!-!RANDOM!.txt"
  echo !RANDOM!-!RANDOM! > "!TEMP_FILE!"
  set /P VALUE=<"!TEMP_FILE!"
)

endlocal

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

rmdir /S /Q "%TEMP_DIR%"

echo Time spent: %TIME_INTS%.%TIME_FRACS% msecs
echo;

exit /b 0
