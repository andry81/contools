@echo off

set "LVAR=%~1"
set "RVAR=%~2"

if defined LVAR set "%LVAR%="

exit /b 0
