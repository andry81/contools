@echo off

if "%~1" == "" exit /b 255
if "%~2" == "" exit /b 255

set "__?NUM_SKIP_ARGS=%~1"
set "__?VAR=%~2"

set "%__?VAR%="

shift
shift

set __?INDEX=0

:SKIP_ARGS_LOOP

if %__?INDEX% GEQ %__?NUM_SKIP_ARGS% goto SKIP_ARGS_LOOP_END

shift

set /A __?INDEX+=1

goto SKIP_ARGS_LOOP

:SKIP_ARGS_LOOP_END

:ARG_LOOP

set "__?ARG=%~1"

if defined __?ARG (
  if defined %__?VAR% (
    call set %%__?VAR%%=%%%__?VAR%%% "%%__?ARG%%"
  ) else set %__?VAR%="%__?ARG%"

  shift

  rem read until no args
  goto ARG_LOOP
)

(
  set "__?NUM_SKIP_ARGS="
  set "__?INDEX="
  set "__?VAR="
  set "__?ARG="
  exit /b 0
)
