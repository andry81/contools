
:TRIM_VAR_VALUE_RIGHT_LOOP
if not ^%__?VALUE:~-1%/ == ^ / if not ^%__?VALUE:~-1%/ == ^	/ exit /b 0
set "__?VALUE=%__?VALUE:~0,-1%"
if not defined __?VALUE exit /b 0
if not ^%__?VALUE:~-1%/ == ^ / if not ^%__?VALUE:~-1%/ == ^	/ exit /b 0
set "__?VALUE=%__?VALUE:~0,-1%"
if not defined __?VALUE exit /b 0
if not ^%__?VALUE:~-1%/ == ^ / if not ^%__?VALUE:~-1%/ == ^	/ exit /b 0
set "__?VALUE=%__?VALUE:~0,-1%"
if not defined __?VALUE exit /b 0
if not ^%__?VALUE:~-1%/ == ^ / if not ^%__?VALUE:~-1%/ == ^	/ exit /b 0
set "__?VALUE=%__?VALUE:~0,-1%"
if not defined __?VALUE exit /b 0
if not ^%__?VALUE:~-1%/ == ^ / if not ^%__?VALUE:~-1%/ == ^	/ exit /b 0
set "__?VALUE=%__?VALUE:~0,-1%"
if not defined __?VALUE exit /b 0
if not ^%__?VALUE:~-1%/ == ^ / if not ^%__?VALUE:~-1%/ == ^	/ exit /b 0
set "__?VALUE=%__?VALUE:~0,-1%"
if not defined __?VALUE exit /b 0
if not ^%__?VALUE:~-1%/ == ^ / if not ^%__?VALUE:~-1%/ == ^	/ exit /b 0
set "__?VALUE=%__?VALUE:~0,-1%"
if not defined __?VALUE exit /b 0
if not ^%__?VALUE:~-1%/ == ^ / if not ^%__?VALUE:~-1%/ == ^	/ exit /b 0
set "__?VALUE=%__?VALUE:~0,-1%"
if not defined __?VALUE exit /b 0
goto TRIM_VAR_VALUE_RIGHT_LOOP
