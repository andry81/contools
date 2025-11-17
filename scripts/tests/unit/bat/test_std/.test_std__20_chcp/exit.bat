@echo off

if not "%CURRENT_CP_REF%" == "%CURRENT_CP%" exit /b 10
if not "%LAST_CP_REF%" == "%LAST_CP%" exit /b 20
if not "%CP_HISTORY_LIST_REF%" == "%CP_HISTORY_LIST%" exit /b 30

if %RETREF% NEQ %TEST_IMPL_ERROR% exit /b 100

exit /b 0
