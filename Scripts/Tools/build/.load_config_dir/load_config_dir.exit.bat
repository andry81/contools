
set "__?DROP_LOCALS_TEMP_FILE=%TEMP%\%~n0.%RANDOM%-%RANDOM%.lst"

set __? 2>nul > "%__?DROP_LOCALS_TEMP_FILE%"

(
  rem drop all locals
  for /F "usebackq eol= tokens=1,* delims==" %%i in ("%__?DROP_LOCALS_TEMP_FILE%") do set "%%i="

  del /F /Q /A:-D "%__?DROP_LOCALS_TEMP_FILE%" >nul 2>&1

  exit /b %__?LASTERROR%
)
