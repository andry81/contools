@echo off

set :DO_LOOP=^
for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do ^
for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do ^
for %%# in (%%) do for %%# in (%%##) do

exit /b 0
