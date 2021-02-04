@Echo OFF
SetLocal ENABLEEXTENSIONS
REM Console Utilities Demonstration Program
REM Written by Frank P. Westlake, 2000.12.25

:BeginScript
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Console commands test
Set /A missing=0
For %%a in (
	ConCursorSize.exe 
	ConSetCursor.exe 
	ConShowCursor.exe 
	ConSetAttr.exe
	ConClear.exe
	ConFillAttr.exe
	ConSetBuffer.exe
	ConSetWindow.exe
	ConGetTitle.exe
	ConGetEvent.exe

) Do Call :Find %%a
If %missing% GTR 0 (
	Echo Please place the missing files in your path and try again.
	Goto :EOF
)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Setup
CLS
Color 07
For /F "tokens=1 delims=- " %%a in ('ConGetTitle') Do Set title=%%a
Title Console Utilities Demonstration Program
FOR /F "tokens=2,4 delims== " %%A in ('ConSetBuffer') Do (
	Set Columns=%%A
	Set Lines=%%B)
FOR /F "tokens=2,4,6,8 delims== " %%A in ('ConSetWindow') Do (
	Set Left=%%A
	Set Top=%%B
	Set Right=%%C
	Set Bottom=%%D)
Set FC=7
Set BC=0
Set /A StatusLine=Bottom-1
Set Hit=NOT
Set paint=OFF
Set Button=0&Set X=0&Set Y=0
Set Error=0
FOR /F %%A in ('ConSetAttr') Do Set OC=%%A
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Build Screen
ConShowCursor/h
If %Right% GTR 46 (Set /A n=Right/2-20) ^
Else Set n=0
ConSetAttr 37 & ConFillAttr
ConSetCursor %n% 0 & Echo.Console Utilities Demonstration Program
Set /A Close=Right-2
ConSetCursor %Close% 0 & Echo [x]
ConSetCursor 0 1 & ConFillAttr & Echo.^|PAINT^|HELP^|
ConSetCursor 0 2 & For /L %%a in (1,1,15) Do Call :DrawPalette %%a
ConSetAttr 07 & ConSetCursor 32 2 & Echo ^<-Choose color=
ConSetAttr 70
ConSetCursor 47 2 & ConFillAttr 2 
ConSetCursor 0 %StatusLine%
ConFillAttr
Call :Help
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MouseIn
ConSetCursor 0 %StatusLine%
ConSetAttr 70
:MouseIn2
For /F "tokens=1-4" %%0 in ('ConGetEvent/m') Do Call:%%0 %%1 %%2 %%3 %%4
::If %Button%==0 Goto :Exit
If %paint%==ON Goto Paint
ConClear&Echo Button=%Button% X=%X% Y=%Y%&ConSetCursor 20 %StatusLine%
If %Button%==0 Goto :MouseIn
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Menu
If %Button%==1 (
	If %Y% EQU 0 (
		If %X% GEQ %Close% Goto :Exit
	) ^
	Else If %Y% EQU 1 (
		If %X% LEQ 5 (
			Set paint=ON
			ConSetCursor 1 1
			ConSetAttr 3F
			ConFillAttr 5
		) ^
		Else If %X% LEQ 10 Call :Help
	)
) ^
Else If %Button%==2 Call :Help
Goto MouseIn
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Exit
::popup /yn /q /m "Ok to Quit %0?" /t "%0"
::If ERRORLEVEL 7 Goto MouseIn
ConSetAttr 37
ConSetCursor 0 0 & ConClear & ConFillAttr
ConSetCursor 0 1 & ConClear & ConFillAttr
ConSetCursor 0 2 & ConClear & ConFillAttr
ConSetCursor 0 %StatusLine% & ConClear & ConFillAttr
ConShowCursor/s
ConSetAttr %OC%
Title %title%
Goto :EOF
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Help
ConSetCursor 7 1 & ConSetAttr 3F & ConFillAttr 4
ConSetCursor 0 3 & ConSetAttr 07
FindStr/lb "\c" %~f0|ConOut|ConBuffer
ConSetCursor 7 1 & ConSetAttr 37 & ConFillAttr 4
Goto :EOF
:HelpText
\cConsole Utilities Demonstration Program\n\cHELP\n\c(Press ESCAPE to exit)\n\nPress a mouse button anywhere in the window to display button information.\nPress and drag for a continuous reading.\nPress a mouse button in the [x] to quit.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Find
Set File=%~dp$PATH:1
If "%File%"=="" (
	Echo %1 MISSING
	Set /A missing+=1
)
Goto :EOF
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Paint
ConSetAttr 70&ConSetCursor 0 %StatusLine%&ConClear&Echo Button=%Button% X=%X% Y=%Y%
If %Button%==1 (
	ConSetAttr %FC%0
	If %Y% EQU 0 (
		If %X% GEQ %Close% Goto :Exit
		Goto :MouseIn
	) ^
	Else If %Y% EQU 1 (
		If %X% LEQ 5 (
			Set paint=OFF
			ConSetCursor 1 1
			ConSetAttr 37
			ConFillAttr 5
		)
		Goto :MouseIn
	) ^
	Else If %Y% EQU 2 (
		If %X% LEQ 31 (
			Set /A n=X/2
			ConSetCursor 47 2
			Call :GetPalette %n%
		)
		Goto MouseIn2
	)
)
If %Button%==2 (ConSetAttr 07) Else (ConSetAttr %FC%0)
If NOT %Button%==0 (
	ConSetCursor %X% %Y%
	ConFillAttr 1
	ConSetAttr 70
)
Goto MouseIn2
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DrawPalette
Set /A n=%1*2
ConSetCursor %n% 2
Call :GetPalette %1
Goto :EOF
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GetPalette
For /F "tokens=%1" %%b in ("1 2 3 4 5 6 7 8 9 a b c d e f") Do Set FC=%%b
ConSetAttr %FC%0
ConFillAttr 2
Goto :EOF
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MOUSE
Set Button=%1
Set X=%2
Set Y=%3
Goto :EOF
