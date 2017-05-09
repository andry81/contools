@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script makes SVN URL absolute applying to a base/repo url the SVN
rem   transform path ("./", "../", "^/", "//", "/").

rem Command arguments:
rem %1 - SVN base URL path.
rem      Should be defined and absolute, but can be non canonical.
rem %2 - SVN transform path.
 rem     Can be URL or relative path.
rem      If relative then should be a suffix either to base url or repo url.
rem %3 - SVN repository root path.
rem      Should be absolute, but can be empty or non canonical.
rem      Should be defined if transform path is requested as relative path to
rem      repo url (^/ // /).
rem      Can be empty if transform path is requested as absolute (..://..) or
rem      relative path (./ ../) to base url.

rem Examples:
rem 1. call make_url_absolute.bat file:///./root/./dir1/2/3/4/../../.././dir2/.. ./test
rem    rem RETURN_VALUE=file:///./root/dir1
rem 2. call make_url_absolute.bat file:///./root/./dir1/.././dir2 ./test
rem    rem RETURN_VALUE=file:///./root/dir2/test
rem 3. call make_url_absolute.bat file:///./root/./dir1/.././dir2 ../test
rem    rem RETURN_VALUE=file:///./root/test
rem 4. call make_url_absolute.bat https://root/./dir1/./dir2/.. ^^/test https://root/./dir1
rem    rem RETURN_VALUE=https://root/dir1/test
rem 5. call make_url_absolute.bat https://root/./dir1/./dir2/.. //root2/test https://root/./dir1
rem    rem RETURN_VALUE=https://root2/test
rem 6. call make_url_absolute.bat https://root/./dir1/./dir2/.. /test https://root/./dir1
rem    rem RETURN_VALUE=https://root/test
rem 7. call make_url_absolute.bat https://root/./dir1/./dir2/.. test
rem    rem RETURN_VALUE=https://root/dir1/test
rem 8. call make_url_absolute.bat https://root/./dir1/./dir2/.. https://root/./dir1/./dir2/./dir3
rem    rem RETURN_VALUE=https://root/dir1/dir2/dir3

rem Drop return value
set "RETURN_VALUE="

rem Drop last error level
cd .

setlocal

call "%%~dp0__init__.bat" || goto :EOF

set "?~nx0=%~nx0"

rem script flags
set FLAG_TEST_ABSOLUTE_TRANSFORM_PATH=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
  if "%FLAG%" == "-t" (
    set FLAG_TEST_ABSOLUTE_TRANSFORM_PATH=1
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

set "BASE_URL=%~1"
set "TRANSFORM_PATH=%~2"
set "REPO_URL=%~3"

if "%BASE_URL%" == "" (
  echo.%?~nx0%: error: BASE_URL should be defined.
  exit /b 1
) >&2

if not "%BASE_URL%" == "" ( call :VALIDATE_BASE_URL || goto :EOF )
goto VALIDATE_BASE_URL_END

:VALIDATE_BASE_URL
rem BASE_URL should be absolute
if "%BASE_URL:://=%" == "%BASE_URL%" (
  echo.%?~nx0%: error: BASE_URL should be absolute: BASE_URL="%BASE_URL%".
  exit /b 2
)

exit /b 0

:VALIDATE_BASE_URL_END

call :VALIDATE_TRANSFORM_PATH || goto :EOF
goto VALIDATE_TRANSFORM_PATH_END

:VALIDATE_TRANSFORM_PATH
if "%TRANSFORM_PATH%" == "" (
  echo.%?~nx0%: error: TRANSFORM_PATH should not be empty.
  exit /b 3
) >&2

set TRANSFORM_PATH_IS_ABSOLUTE=0
if not "%TRANSFORM_PATH:://=%" == "%TRANSFORM_PATH%" set TRANSFORM_PATH_IS_ABSOLUTE=1

if "%REPO_URL%" == "" exit /b 0

if %FLAG_TEST_ABSOLUTE_TRANSFORM_PATH% EQU 0 exit /b 0

rem if TRANSFORM_PATH is absolute then test REPO_URL on prefix to TRANSFORM_PATH
if %TRANSFORM_PATH_IS_ABSOLUTE% EQU 0 exit /b 0

call set "TRANSFORM_PATH_TO_REPO_URL_SUFFIX=%%TRANSFORM_PATH:*%REPO_URL%=%%"

if not "%TRANSFORM_PATH_TO_REPO_URL_SUFFIX%" == "%TRANSFORM_PATH%" ^
if "%REPO_URL%%TRANSFORM_PATH_TO_REPO_URL_SUFFIX%" == "%TRANSFORM_PATH%" (
  if "%TRANSFORM_PATH_TO_REPO_URL_SUFFIX%" == "" exit /b 0
  if "%TRANSFORM_PATH_TO_REPO_URL_SUFFIX:~0,1%" == "/" exit /b 0
)

(
  echo.%?~nx0%: error: REPO_URL is not a prefix to the TRANSFORM_PATH: REPO_URL="%REPO_URL%" TRANSFORM_PATH="%TRANSFORM_PATH%".
  exit /b 4
) >&2

:VALIDATE_TRANSFORM_PATH_END

if not "%REPO_URL%" == "" ( call :VALIDATE_REPO_URL || goto :EOF )
goto VALIDATE_REPO_URL_END

:VALIDATE_REPO_URL
rem REPO_URL should be absolute
if "%REPO_URL:://=%" == "%REPO_URL%" (
  echo.%?~nx0%: error: REPO_URL should be absolute: REPO_URL="%REPO_URL%".
  exit /b 5
) >&2

rem REPO_URL should be a prefix to BASE_URL
call set "BASE_URL_TO_REPO_URL_SUFFIX=%%BASE_URL:*%REPO_URL%=%%"

if not "%BASE_URL_TO_REPO_URL_SUFFIX%" == "%BASE_URL%" ^
if "%REPO_URL%%BASE_URL_TO_REPO_URL_SUFFIX%" == "%BASE_URL%" (
  if "%BASE_URL_TO_REPO_URL_SUFFIX%" == "" exit /b 0
  if "%BASE_URL_TO_REPO_URL_SUFFIX:~0,1%" == "/" exit /b 0
)

(
  echo.%?~nx0%: error: REPO_URL is not a prefix to the BASE_URL: REPO_URL="%REPO_URL%" BASE_URL="%BASE_URL%"
  exit /b 6
) >&2

:VALIDATE_REPO_URL_END

if "%TRANSFORM_PATH:~0,1%" == "." (
  rem relative to base url
  if "%BASE_URL%" == "" (
    echo.%?~nx0%: error: BASE_URL should not be empty.
    exit /b 7
  ) >&2
  set "RETURN_VALUE=%BASE_URL%/%TRANSFORM_PATH%"
) else if "%TRANSFORM_PATH:~0,2%" == "^/" (
  rem relative to repo url
  if "%REPO_URL%" == "" (
    echo.%?~nx0%: error: REPO_URL should not be empty.
    exit /b 8
  ) >&2
  set "RETURN_VALUE=%REPO_URL%/%TRANSFORM_PATH:~2%"
) else if "%TRANSFORM_PATH:~0,2%" == "//" (
  rem relative to repo url scheme
  if "%REPO_URL%" == "" (
    echo.%?~nx0%: error: REPO_URL should not be empty.
    exit /b 8
  ) >&2
  call "%%SVNCMD_TOOLS_ROOT%%/extract_url_scheme.bat" "%%REPO_URL%%"
  call set "RETURN_VALUE=%%RETURN_VALUE%%://%%TRANSFORM_PATH:~2%%"
) else if "%TRANSFORM_PATH:~0,1%" == "/" (
  rem relative to repo url root
  if "%REPO_URL%" == "" (
    echo.%?~nx0%: error: REPO_URL should not be empty.
    exit /b 8
  ) >&2
  call "%%SVNCMD_TOOLS_ROOT%%/extract_url_root.bat" "%%REPO_URL%%"
  call set "RETURN_VALUE=%%RETURN_VALUE%%/%%TRANSFORM_PATH:~1%%"
) else (
  rem relative or prefix to base url
  if "%BASE_URL%" == "" (
    echo.%?~nx0%: error: BASE_URL should not be empty.
    exit /b 7
  ) >&2
  
  if %TRANSFORM_PATH_IS_ABSOLUTE% EQU 0 (
    set "RETURN_VALUE=%BASE_URL%/%TRANSFORM_PATH%"
  ) else (
    set "RETURN_VALUE=%TRANSFORM_PATH%"
  )
)

call "%%SVNCMD_TOOLS_ROOT%%/make_url_canonical.bat" "%%RETURN_VALUE%%"

(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE%"
)

exit /b 0
