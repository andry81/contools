@echo off

if %CONTOOLS_VERBOSE%0 NEQ 0 (
  echo;^>^>%*
  echo;
)

(
  %*
)
