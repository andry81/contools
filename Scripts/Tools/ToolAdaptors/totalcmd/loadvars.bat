@echo off

if not exist "%~1" (
  echo.%~nx0: input file path must exist: "%~1"
  exit /b 1
) >&2

if exist "%~1\" (
  echo.%~nx0: input file path must be a file: "%~1"
  exit /b 2
) >&2

for /F "usebackq eol=# tokens=* delims=" %%i in ("%~1") do (
  set %%i
)

exit /b 0
