@echo off

setlocal

set MAX_UNROLL_SIZE=256
set "GEN_FILE=%~dp0unroll_copy_switch.hpp"

type nul>"%GEN_FILE%"

(
  echo.STATIC_ASSERT_EQ(TACKLE_PP_MAX_UNROLLED_COPY_SIZE, %MAX_UNROLL_SIZE%, "generated file is inconsistent to the limit declared by TACKLE_PP_MAX_UNROLLED_COPY_SIZE"^);
  echo.
) >> "%GEN_FILE%"

for /L %%i in (1,1,%MAX_UNROLL_SIZE%) do (
  echo.%%i
  (
    echo.case %%i: *reinterpret_cast^<StaticArray^<T, %%i^> *^>(to^) = *reinterpret_cast^<const StaticArray^<T, %%i^> *^>(from^); break;
  ) >> "%GEN_FILE%"
)
