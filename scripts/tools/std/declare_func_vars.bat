@echo off

set @DO_LOOP_16x8@=^
for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do ^
for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do ^
for %%# in (%%) do for %%# in (%%##) do

rem `Terminate Batch Job` skip code
set @CMD_SKIP_TERMINATE_BATCH_JOB@="%%SystemRoot%%\System32\cmd.exe" /S /c "@if %%ERRORLEVEL%% EQU -1073741510 (exit 9009) else exit %%ERRORLEVEL%%"

exit /b 0

rem Description:
rem   Built-in variable to use as macro generics.

rem @DO_LOOP_x16x8@:
rem   The `for` statement for `2^32` iterations.
rem   To exit use `goto` or `exit`.

rem @CMD_SKIP_TERMINATE_BATCH_JOB@:
rem   The statement to skip a batch job termination-in-process.
