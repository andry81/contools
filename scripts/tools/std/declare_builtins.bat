@echo off

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx1" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx1" ) else set "?~=%~nx1"

set ?0=%1
set "?~0=%~1"
set "?~f0=%~f1"
set "?~d0=%~d1"
set "?~dp0=%~dp1"
set "?~n0=%~n1"
set "?~nx0=%~nx1"
set "?~x0=%~x1"

rem minimal set of sensitive control characters
set ?22=^"
set "?26=&" & set "?5E=^" & set "?7C=|"

exit /b 0
