@echo off

setlocal

call :CMD sc create comspec_as_svc binpath= "%%COMSPEC%% /K start" type= own type= interact
call :CMD sc start comspec_as_svc
call :CMD sc delete comspec_as_svc

pause

exit /b

:CMD
echo.^>%*
(
  %*
)
