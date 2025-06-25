@echo off

if %TOOLS_VERBOSE%0 NEQ 0 (
  echo;^>^>%*
  echo;
)

(
  %*
)
