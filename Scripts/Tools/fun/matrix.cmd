@echo off
setlocal ENABLEDELAYEDEXPANSION
color A
:matrix
set LINE=
set I2=0
:REPEAT2
set I1=0
:REPEAT1
set R=!random!&set V=!R!&(if !R! GEQ 10000 goto CONTINUE)&set V=0!V!&(if !R! GEQ 1000 goto CONTINUE)&set V=0!V!&(if !R! GEQ 100 goto CONTINUE)&set V=0!V!&(if !R! GEQ 10 goto CONTINUE)&set V=0!V!
:CONTINUE
set LINE=!LINE!!V!&set /A I1+=1&(if !I1! LSS 4 goto REPEAT1)&set LINE=!LINE! &set I1=0&set /A I2+=1&(if !I2! LSS 8 goto REPEAT2)&echo.!LINE!&goto matrix
