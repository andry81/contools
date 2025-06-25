@echo off

rem script flags
set __?FLAG_SHIFT=0

:FLAGS_LOOP

rem flags always at first
set "__?FLAG=%~1"

if defined __?FLAG ^
if not "%__?FLAG:~0,1%" == "-" set "__?FLAG="

if defined __?FLAG (
  if "%__?FLAG%" == "-T" (
    set "CMAKE_GENERATOR_TOOLSET=%~2"
    shift
    set /A __?FLAG_SHIFT+=1
  ) else if "%__?FLAG%" == "-A" (
    set "CMAKE_GENERATOR_PLATFORM=%~2"
    shift
    set /A __?FLAG_SHIFT+=1
  ) else if "%__?FLAG%" == "-I" (
    set "CMAKE_GENERATOR_INSTANCE=%~2"
    shift
    set /A __?FLAG_SHIFT+=1
  ) else (
    exit /b 0
  )

  shift
  set /A __?FLAG_SHIFT+=1

  rem read until no flags
  goto FLAGS_LOOP
)
