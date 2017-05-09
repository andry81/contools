@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script makes SVN URL canonical, removing all . and .. component
rem   occurrences.

rem Examples:
rem 1. call make_url_canonical.bat file:///./root/./dir1/2/3/4/../../.././dir2/..
rem    rem RETURN_VALUE=file:///./root/dir1
rem 2. call make_url_canonical.bat file:///./root/./dir1/.././dir2
rem    rem RETURN_VALUE=file:///./root/dir2
rem 3. call make_url_canonical.bat https://root/./dir1/.././dir2/..
rem    rem RETURN_VALUE=https://root
rem 4. call make_url_canonical.bat https://./root/./dir1/.././dir2/.
rem    rem RETURN_VALUE=https://./root/dir2
rem 5. call make_url_canonical.bat https//root/dir1/..
rem    rem RETURN_VALUE=https//root
rem 6. call make_url_canonical.bat https:/root/dir1/..
rem    rem RETURN_VALUE=https:/root
rem 7. call make_url_canonical.bat https:/
rem    rem RETURN_VALUE=https:/
rem 8. call make_url_canonical.bat https:
rem    rem RETURN_VALUE=https:

set "RETURN_VALUE="

rem Drop last error level
cd .

setlocal

call "%%~dp0__init__.bat" || goto :EOF

rem for script self debugging
rem set DEBUG=1
set ?1=^^^>

set "URL=%~1"

if "%URL%" == "" exit /b 1

if "%URL:/=%" == "%URL%" (
  endlocal
  set "RETURN_VALUE=%URL%"
  exit /b 0
)

for /F "eol= tokens=1,* delims=:" %%i in ("%URL%") do (
  set "URL_SCHEME=%%i"
  set "URL_PATH=%%j"
)

if "%URL_PATH%" == "" (
  set "URL_PATH=%URL_SCHEME%"
  set "URL_SCHEME="
)

set "URL_PATH_PREFIX=%URL_PATH%"

set COMPONENT_INDEX=0
set NUM_REDUCTIONS=0

rem save :/// :// // character sequence from trimming to :/ and /
set "URL_PATH_PREFIX=%URL_PATH_PREFIX:///=|||%"
set "URL_PATH_PREFIX=%URL_PATH_PREFIX://=||%"
if "%URL_PATH_PREFIX:~0,1%" == "/" set "URL_PATH_PREFIX=|%URL_PATH_PREFIX:~1%"

call :IMPL
rem restore // character sequence
if not "%RETURN_VALUE%" == "" set "RETURN_VALUE=%RETURN_VALUE:|||=///%"
if not "%RETURN_VALUE%" == "" set "RETURN_VALUE=%RETURN_VALUE:||=//%"
if not "%RETURN_VALUE%" == "" set "RETURN_VALUE=%RETURN_VALUE::|=:/%"
(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE%"
)
exit /b

:IMPL
:MAKE_URL_CANONICAL_LOOP
set "URL_PATH_SUFFIX="
for /F "eol= tokens=1,* delims=/" %%i in ("%URL_PATH_PREFIX%") do (
  set "URL_PATH_PREFIX=%%i"
  set "URL_PATH_SUFFIX=%%j"
)


if %DEBUG%0 NEQ 0 echo "URL_PATH_PREFIX=%URL_PATH_PREFIX%"
if %DEBUG%0 NEQ 0 echo "URL_PATH_SUFFIX=%URL_PATH_SUFFIX%" "%URL_PATH_SUFFIX:~0,2%" "%URL_PATH_SUFFIX:~0,1%" "%URL_PATH_SUFFIX:~1,1%"

if "%URL_PATH_PREFIX%" == "" (
  if %NUM_REDUCTIONS% NEQ 0 (
    rem Make reduction again until will nothing to reduce
    set COMPONENT_INDEX=0
    set NUM_REDUCTIONS=0
    set "URL_PATH_PREFIX=%RETURN_VALUE%"
    set "RETURN_VALUE="
    if %DEBUG%0 NEQ 0 call echo   -%%?1%% 0 -%%?1%% URL_PATH_PREFIX="%%URL_PATH_PREFIX%%"
    goto MAKE_URL_CANONICAL_LOOP
  )

  if "%URL_SCHEME%" == "file" (
    if not "%RETURN_VALUE%" == "" (
      set "RETURN_VALUE=%URL_SCHEME%:%RETURN_VALUE%"
      if %DEBUG%0 NEQ 0 call echo   -%%?1%% 1 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
    ) else (
      set "RETURN_VALUE=%URL_SCHEME%:"
      if %DEBUG%0 NEQ 0 call echo   -%%?1%% 2 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
    )
  ) else if not "%URL_SCHEME%" == "" (
    if not "%RETURN_VALUE%" == "" (
      set "RETURN_VALUE=%URL_SCHEME%:%RETURN_VALUE%"
      if %DEBUG%0 NEQ 0 call echo   -%%?1%% 3 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
    ) else (
      set "RETURN_VALUE=%URL_SCHEME%:"
      if %DEBUG%0 NEQ 0 call echo   -%%?1%% 4 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
    )
  ) else (
    set "RETURN_VALUE=%RETURN_VALUE%"
    if %DEBUG%0 NEQ 0 call echo   -%%?1%% 5 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
  )
  exit /b 0
)

if "%URL_PATH_SUFFIX%" == "" (
  if %COMPONENT_INDEX% NEQ 0 (
    if not "%URL_PATH_PREFIX%" == "." (
      if not "%RETURN_VALUE%" == "" (
        set "RETURN_VALUE=%RETURN_VALUE%/%URL_PATH_PREFIX%"
        if %DEBUG%0 NEQ 0 call echo   -%%?1%% 10 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
      ) else (
        set "RETURN_VALUE=%URL_PATH_PREFIX%"
        if %DEBUG%0 NEQ 0 call echo   -%%?1%% 11 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
      )
    )
  ) else if not "%RETURN_VALUE%" == "" (
    set "RETURN_VALUE=%RETURN_VALUE%/%URL_PATH_PREFIX%"
    if %DEBUG%0 NEQ 0 call echo   -%%?1%% 12 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
  ) else (
    set "RETURN_VALUE=%URL_PATH_PREFIX%"
    if %DEBUG%0 NEQ 0 call echo   -%%?1%% 13 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
  )
) else if not "%URL_PATH_SUFFIX:~0,2%" == ".." (
  if not "%URL_PATH_SUFFIX:~0,1%" == "." (
    if not "%URL_PATH_PREFIX%" == "." (
      if not "%RETURN_VALUE%" == "" (
        set "RETURN_VALUE=%RETURN_VALUE%/%URL_PATH_PREFIX%"
        if %DEBUG%0 NEQ 0 call echo   -%%?1%% 30 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
      ) else (
        set "RETURN_VALUE=%URL_PATH_PREFIX%"
        if %DEBUG%0 NEQ 0 call echo   -%%?1%% 31 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
      )
    ) else if %COMPONENT_INDEX% NEQ 0 (
      set /A NUM_REDUCTIONS+=1
      if %DEBUG%0 NEQ 0 call echo   -%%?1%% 32 -%%?1%% NUM_REDUCTIONS="%%NUM_REDUCTIONS%%"
    ) else if not "%RETURN_VALUE%" == "" (
      set "RETURN_VALUE=%RETURN_VALUE%/%URL_PATH_PREFIX%"
      if %DEBUG%0 NEQ 0 call echo   -%%?1%% 33 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
    ) else (
      set "RETURN_VALUE=%URL_PATH_PREFIX%"
      if %DEBUG%0 NEQ 0 call echo   -%%?1%% 34 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
    )
  ) else if not "%URL_PATH_SUFFIX:~1,1%" == "/" (
    if not "%URL_PATH_PREFIX%" == "." (
      if not "%RETURN_VALUE%" == "" (
        set "RETURN_VALUE=%RETURN_VALUE%/%URL_PATH_PREFIX%"
        if %DEBUG%0 NEQ 0 call echo   -%%?1%% 35 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
      ) else (
        set "RETURN_VALUE=%URL_PATH_PREFIX%"
        if %DEBUG%0 NEQ 0 call echo   -%%?1%% 36 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
      )
    ) else if %COMPONENT_INDEX% NEQ 0 (
      set /A NUM_REDUCTIONS+=1
      if %DEBUG%0 NEQ 0 call echo   -%%?1%% 37 -%%?1%% NUM_REDUCTIONS="%%NUM_REDUCTIONS%%"
    ) else if not "%RETURN_VALUE%" == "" (
      set "RETURN_VALUE=%RETURN_VALUE%/%URL_PATH_PREFIX%"
      if %DEBUG%0 NEQ 0 call echo   -%%?1%% 38 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
    ) else (
      set "RETURN_VALUE=%URL_PATH_PREFIX%"
      if %DEBUG%0 NEQ 0 call echo   -%%?1%% 39 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
    )
  ) else (
    if not "%URL_PATH_PREFIX%" == "." (
      if not "%RETURN_VALUE%" == "" (
        set "RETURN_VALUE=%RETURN_VALUE%/%URL_PATH_PREFIX%"
        if %DEBUG%0 NEQ 0 call echo   -%%?1%% 40 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
      ) else (
        set "RETURN_VALUE=%URL_PATH_PREFIX%"
        if %DEBUG%0 NEQ 0 call echo   -%%?1%% 41 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
      )
    ) else if %COMPONENT_INDEX% NEQ 0 (
      set /A NUM_REDUCTIONS+=1
      if %DEBUG%0 NEQ 0 call echo   -%%?1%% 42 -%%?1%% NUM_REDUCTIONS="%%NUM_REDUCTIONS%%"
    ) else if not "%RETURN_VALUE%" == "" (
      set "RETURN_VALUE=%RETURN_VALUE%/%URL_PATH_PREFIX%"
      if %DEBUG%0 NEQ 0 call echo   -%%?1%% 43 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
    ) else (
      set "RETURN_VALUE=%URL_PATH_PREFIX%"
      if %DEBUG%0 NEQ 0 call echo   -%%?1%% 44 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
    )
    set "URL_PATH_SUFFIX=%URL_PATH_SUFFIX:~2%"
    set /A NUM_REDUCTIONS+=1
  )
) else if not "%URL_PATH_PREFIX%" == ".." (
  set "URL_PATH_SUFFIX=%URL_PATH_SUFFIX:~2%"
  set /A NUM_REDUCTIONS+=1
  if %DEBUG%0 NEQ 0 call echo   -%%?1%% 45 -%%?1%% URL_PATH_SUFFIX="%%URL_PATH_SUFFIX%%" NUM_REDUCTIONS="%%NUM_REDUCTIONS%%"
) else (
  rem special case: ../..
  if not "%RETURN_VALUE%" == "" (
    set "RETURN_VALUE=%RETURN_VALUE%/%URL_PATH_PREFIX%"
    if %DEBUG%0 NEQ 0 call echo   -%%?1%% 46 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
  ) else (
    set "RETURN_VALUE=%URL_PATH_PREFIX%"
    if %DEBUG%0 NEQ 0 call echo   -%%?1%% 47 -%%?1%% RETURN_VALUE="%%RETURN_VALUE%%"
  )
)

if %DEBUG%0 NEQ 0 call echo   -%%?1%% 50 -%%?1%% URL_PATH_PREFIX="%%URL_PATH_PREFIX%%" NUM_REDUCTIONS="%%NUM_REDUCTIONS%%"

rem echo RETURN_VALUE=%RETURN_VALUE%
set "URL_PATH_PREFIX=%URL_PATH_SUFFIX%"

set /A COMPONENT_INDEX+=1

goto MAKE_URL_CANONICAL_LOOP
