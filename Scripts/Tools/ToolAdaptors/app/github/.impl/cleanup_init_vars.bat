@echo off

setlocal

pushd "%PROJECT_LOG_DIR%" && (
  if exist "%INIT_VARS_FILE%" (
    rem remove all GitHub tokens from the log (with the line returns reformat)
    "%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" -E -i "s/ghp_[0-9a-zA-Z]{16,}/ghp_*/g" "%INIT_VARS_FILE%"

    rem delete GnuWin32 sed inplace backups
    del /F /Q "sed*" 2> nul
  )

  popd
)
