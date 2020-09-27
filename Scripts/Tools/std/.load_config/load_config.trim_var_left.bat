@echo off

:TRIM_VAR_NAME_LEFT_LOOP
if not defined __?VAR exit /b 1
if not ^%__?VAR:~0,1%/ == ^ / if not ^%__?VAR:~0,1%/ == ^	/ exit /b 0
set "__?VAR=%__?VAR:~1%"
if not defined __?VAR exit /b 1
if not ^%__?VAR:~0,1%/ == ^ / if not ^%__?VAR:~0,1%/ == ^	/ exit /b 0
set "__?VAR=%__?VAR:~1%"
if not defined __?VAR exit /b 1
if not ^%__?VAR:~0,1%/ == ^ / if not ^%__?VAR:~0,1%/ == ^	/ exit /b 0
set "__?VAR=%__?VAR:~1%"
if not defined __?VAR exit /b 1
if not ^%__?VAR:~0,1%/ == ^ / if not ^%__?VAR:~0,1%/ == ^	/ exit /b 0
set "__?VAR=%__?VAR:~1%"
if not defined __?VAR exit /b 1
if not ^%__?VAR:~0,1%/ == ^ / if not ^%__?VAR:~0,1%/ == ^	/ exit /b 0
set "__?VAR=%__?VAR:~1%"
if not defined __?VAR exit /b 1
if not ^%__?VAR:~0,1%/ == ^ / if not ^%__?VAR:~0,1%/ == ^	/ exit /b 0
set "__?VAR=%__?VAR:~1%"
if not defined __?VAR exit /b 1
if not ^%__?VAR:~0,1%/ == ^ / if not ^%__?VAR:~0,1%/ == ^	/ exit /b 0
set "__?VAR=%__?VAR:~1%"
if not defined __?VAR exit /b 1
if not ^%__?VAR:~0,1%/ == ^ / if not ^%__?VAR:~0,1%/ == ^	/ exit /b 0
set "__?VAR=%__?VAR:~1%"
goto TRIM_VAR_NAME_LEFT_LOOP
