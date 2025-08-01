@echo off

setlocal

if exist "%PROJECT_LOG_FILE%" pushd "%PROJECT_LOG_DIR%" && (
  call "%%~dp0cleanup_file.bat" "%%PROJECT_LOG_FILE_NAME%%"

  rem delete sed in place backups (just in case, not required for `Msys2`, required for `GnuWin32`)
  del /F /Q /A:-D "sed*" 2>nul

  popd
)
