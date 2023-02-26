@echo off

rem Description:
rem   Script to unmirror all local refs in all remotes.

rem Usage:
rem   git_unmirror_refs.bat
rem

setlocal

rem print all remotes
call :CMD git remote || exit /b 255
echo.---

rem Pull to update local references and test on unmerged heads in the local.
for /F "usebackq eol= tokens=* delims=" %%i in (`git remote 2^>nul`) do (
  set "REMOTE=%%i"
  call :CMD git pull "%%REMOTE%%" "*:*"
  echo.---
  echo.
)

rem print all refs
call :CMD git show-ref || exit /b 255
echo.---

rem Remove all refs in all remotes to reset the mirror tracking:
rem   refs/remotes/REMOTE/BRANCH -> refs/remotes/REMOTE/BRANCH
for /F "usebackq eol= tokens=* delims=" %%i in (`git remote 2^>nul`) do (
  set "REMOTE=%%i"
  set "GIT_PUSH_CMDLINE="
  for /F "usebackq eol= tokens=1,* delims= " %%j in (`git show-ref 2^>nul`) do (
    set "REF_REMOTE=%%k"
    call :GIT_PUSH
  )
  if defined GIT_PUSH_CMDLINE (
    call :GIT_PUSH_EXEC
    echo.---
    echo.
  )
)

goto GIT_PUSH_END

:GIT_PUSH
if not defined REMOTE exit /b 255
if not defined REF_REMOTE exit /b 255
if not "%REF_REMOTE:~0,13%" == "refs/remotes/" exit /b 255
set "REF_REMOTE=%REF_REMOTE:~13%"
if "%REF_REMOTE%" == "" exit /b 255

set GIT_PUSH_CMDLINE=%GIT_PUSH_CMDLINE% ":refs/remotes/%REF_REMOTE%"

exit /b 0

:GIT_PUSH_END

goto GIT_PUSH_EXEC_END

:GIT_PUSH_EXEC
call :CMD git push "%%REMOTE%%"%%GIT_PUSH_CMDLINE%% || exit /b 255

exit /b 0

:GIT_PUSH_EXEC_END

rem Remove all local refs to recreate them in the last pull.
for /F "usebackq eol= tokens=1,* delims= " %%i in (`git show-ref 2^>nul`) do (
  set "REF=%%j"
  call :GIT_DELETE_REF
)
echo.---
echo.

goto GIT_DELETE_REF_END

:GIT_DELETE_REF
if not defined REF exit /b 255
if not "%REF:~0,13%" == "refs/remotes/" exit /b 255
set "REF_REMOTE=%REF:~13%"
if "%REF_REMOTE%" == "" exit /b 255

call :CMD git update-ref -d "%%REF%%"

exit /b 0

:GIT_DELETE_REF_END

rem Pull to update local references and test on unmerged heads in the local.
for /F "usebackq eol= tokens=* delims=" %%i in (`git remote 2^>nul`) do (
  set "REMOTE=%%i"
  call :CMD git pull "%%REMOTE%%" "*:*"
  echo.---
  echo.
)

exit /b 0

:CMD
echo.^>%*
(
  %*
)
