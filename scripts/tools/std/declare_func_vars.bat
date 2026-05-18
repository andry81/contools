@echo off

set @DO_LOOP@=^
for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do ^
for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do ^
for %%# in (%%) do for %%# in (%%##) do

rem `Terminate Batch Job` skip code
set @CMD_SKIP_TERMINATE_BATCH_JOB@="%%SystemRoot%%\System32\cmd.exe" /S /c "@if %%ERRORLEVEL%% EQU -1073741510 (exit 9009) else exit %%ERRORLEVEL%%"

exit /b 0
