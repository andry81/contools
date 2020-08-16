@echo off

rem Drop last error level
type nul>nul

rem Create local variable's stack
setlocal

if 0%__CTRL_SETLOCAL% EQU 1 (
  echo.%~nx0: error: cmd.exe is broken, please restart it!>&2
  exit /b 65535
)
set __CTRL_SETLOCAL=1

call "%%~dp0__init__.bat" || exit /b
call "%%TESTLIB_ROOT%%/init.bat" "%%~dpf0" || exit /b

setlocal
for %%i in (1 2 3 4 5 6 7 8 9 a) do set "REFERENCE_1_VALUE_%%i="
call :TEST test_1_empty.vars TEST_1_VALUE_ REFERENCE_1_VALUE_  1 2 3 4 5 6 7 8 9 a
endlocal

setlocal
for %%i in (21 22 23 41 42 43) do set "REFERENCE_2_VALUE_%%i="
set "REFERENCE_2_VALUE_11=1"
set "REFERENCE_2_VALUE_12=1"
set "REFERENCE_2_VALUE_13=1"
set "REFERENCE_2_VALUE_31=3"
set "REFERENCE_2_VALUE_32=3"
set "REFERENCE_2_VALUE_33=3"
call :TEST test_2_conditional.vars TEST_2_VALUE_ REFERENCE_2_VALUE_  11 12 13  21 22 23  31 32 33  41 42 43
endlocal

setlocal
set "REFERENCE_3_VALUE_11=1"
set "REFERENCE_3_VALUE_12=1"
set "REFERENCE_3_VALUE_13=1"
set "REFERENCE_3_VALUE_21=*:$/{}"
set "REFERENCE_3_VALUE_22=*:$/{}"
set "REFERENCE_3_VALUE_23=*:$/{}"
set "REFERENCE_3_VALUE_31=*:$/{}*:$/{}"
set "REFERENCE_3_VALUE_32=*:$/{}*:$/{}"
set "REFERENCE_3_VALUE_33=*:$/{}*:$/{}"
set "REFERENCE_3_VALUE_41=*:$/{}/*:$/{}"
set "REFERENCE_3_VALUE_42=*:$/{}/*:$/{}"
set "REFERENCE_3_VALUE_43=*:$/{}/*:$/{}"
set "REFERENCE_3_VALUE_51=*:$/{}$"
set "REFERENCE_3_VALUE_52=*:$/{}$"
set "REFERENCE_3_VALUE_53=*:$/{}$"
set "REFERENCE_3_VALUE_61=*:$/{}/"
set "REFERENCE_3_VALUE_62=*:$/{}/"
set "REFERENCE_3_VALUE_63=*:$/{}/"
set "REFERENCE_3_VALUE_71="
set "REFERENCE_3_VALUE_72="
set "REFERENCE_3_VALUE_73="
set "REFERENCE_3_VALUE_81="
set "REFERENCE_3_VALUE_82="
set "REFERENCE_3_VALUE_83="
set "REFERENCE_3_VALUE_91=X$"
set "REFERENCE_3_VALUE_92=X$"
set "REFERENCE_3_VALUE_93=X$"

set "REFERENCE_3_VALUE_a1="
set "REFERENCE_3_VALUE_a2="
set "REFERENCE_3_VALUE_a3="
set "REFERENCE_3_VALUE_b1="
set "REFERENCE_3_VALUE_b2="
set "REFERENCE_3_VALUE_b3="
set "REFERENCE_3_VALUE_c1="
set "REFERENCE_3_VALUE_c2="
set "REFERENCE_3_VALUE_c3="
set "REFERENCE_3_VALUE_d1="
set "REFERENCE_3_VALUE_d2="
set "REFERENCE_3_VALUE_d3="
set "REFERENCE_3_VALUE_e1=/"
set "REFERENCE_3_VALUE_e2=/"
set "REFERENCE_3_VALUE_e3=/"

set "REFERENCE_3_VALUE_f1=1"
set "REFERENCE_3_VALUE_f2=1"
set "REFERENCE_3_VALUE_f3=1"
set "REFERENCE_3_VALUE_g1=11"
set "REFERENCE_3_VALUE_g2=11"
set "REFERENCE_3_VALUE_g3=11"
set "REFERENCE_3_VALUE_h1=1/1"
set "REFERENCE_3_VALUE_h2=1/1"
set "REFERENCE_3_VALUE_h3=1/1"
set "REFERENCE_3_VALUE_i1=1$"
set "REFERENCE_3_VALUE_i2=1$"
set "REFERENCE_3_VALUE_i3=1$"
set "REFERENCE_3_VALUE_j1=1/"
set "REFERENCE_3_VALUE_j2=1/"
set "REFERENCE_3_VALUE_j3=1/"
call :TEST test_3_substitution.vars TEST_3_VALUE_ REFERENCE_3_VALUE_  11 12 13  21 22 23  31 32 33  41 42 43  51 52 53  61 62 63  71 72 73  81 82 83  91 92 93 ^
  a1 a2 a3  b1 b2 b3  c1 c2 c3  d1 d2 d3  e1 e2 e3  f1 f2 f3  g1 g2 g3  h1 h2 h3  i1 i2 i3  j1 j2 j3
endlocal

setlocal
set "REFERENCE_4_VALUE_11=$/"
set "REFERENCE_4_VALUE_12=$/"
set "REFERENCE_4_VALUE_13=$/"
set "REFERENCE_4_VALUE_21=$"
set "REFERENCE_4_VALUE_22=$"
set "REFERENCE_4_VALUE_23=$"
set "REFERENCE_4_VALUE_31=$/"
set "REFERENCE_4_VALUE_32=$/"
set "REFERENCE_4_VALUE_33=$/"
set "REFERENCE_4_VALUE_41=$$"
set "REFERENCE_4_VALUE_42=$$"
set "REFERENCE_4_VALUE_43=$$"
set "REFERENCE_4_VALUE_51=$$/"
set "REFERENCE_4_VALUE_52=$$/"
set "REFERENCE_4_VALUE_53=$$/"
set "REFERENCE_4_VALUE_61=$$"
set "REFERENCE_4_VALUE_62=$$"
set "REFERENCE_4_VALUE_63=$$"
set "REFERENCE_4_VALUE_71=$$/"
set "REFERENCE_4_VALUE_72=$$/"
set "REFERENCE_4_VALUE_73=$$/"
set "REFERENCE_4_VALUE_81=$/"
set "REFERENCE_4_VALUE_82=$/"
set "REFERENCE_4_VALUE_83=$/"
set "REFERENCE_4_VALUE_91=$/$"
set "REFERENCE_4_VALUE_92=$/$"
set "REFERENCE_4_VALUE_93=$/$"

set "REFERENCE_4_VALUE_a1=$$"
set "REFERENCE_4_VALUE_a2=$$"
set "REFERENCE_4_VALUE_a3=$$"
set "REFERENCE_4_VALUE_b1=/"
set "REFERENCE_4_VALUE_b2=/"
set "REFERENCE_4_VALUE_b3=/"
set "REFERENCE_4_VALUE_c1=/$"
set "REFERENCE_4_VALUE_c2=/$"
set "REFERENCE_4_VALUE_c3=/$"
set REFERENCE_4_VALUE_d1=/^"
set REFERENCE_4_VALUE_d2=/^"
set REFERENCE_4_VALUE_d3=/^"
set REFERENCE_4_VALUE_e1=//^"
set REFERENCE_4_VALUE_e2=//^"
set REFERENCE_4_VALUE_e3=//^"

set REFERENCE_4_VALUE_f1=$^"
set REFERENCE_4_VALUE_f2=$^"
set REFERENCE_4_VALUE_f3=$^"
set REFERENCE_4_VALUE_g1=^"
set REFERENCE_4_VALUE_g2=^"
set REFERENCE_4_VALUE_g3=^"
set REFERENCE_4_VALUE_h1=^"$
set REFERENCE_4_VALUE_h2=^"$
set REFERENCE_4_VALUE_h3=^"$
set REFERENCE_4_VALUE_i1=^"$/
set REFERENCE_4_VALUE_i2=^"$/
set REFERENCE_4_VALUE_i3=^"$/
set REFERENCE_4_VALUE_j1=^"^"
set REFERENCE_4_VALUE_j2=^"^"
set REFERENCE_4_VALUE_j3=^"^"

set "REFERENCE_4_VALUE_k1=^"
set "REFERENCE_4_VALUE_k2=^"
set "REFERENCE_4_VALUE_k3=^"
set "REFERENCE_4_VALUE_l1=^^"
set "REFERENCE_4_VALUE_l2=^^"
set "REFERENCE_4_VALUE_l3=^^"
set "REFERENCE_4_VALUE_m1=\"
set "REFERENCE_4_VALUE_m2=\"
set "REFERENCE_4_VALUE_m3=\"
set "REFERENCE_4_VALUE_n1=\\"
set "REFERENCE_4_VALUE_n2=\\"
set "REFERENCE_4_VALUE_n3=\\"
set "REFERENCE_4_VALUE_o1=%%"
set "REFERENCE_4_VALUE_o2=%%"
set "REFERENCE_4_VALUE_o3=%%"
set "REFERENCE_4_VALUE_p1=%%%%"
set "REFERENCE_4_VALUE_p2=%%%%"
set "REFERENCE_4_VALUE_p3=%%%%"
set REFERENCE_4_VALUE_q1=^"
set REFERENCE_4_VALUE_q2=^"
set REFERENCE_4_VALUE_q3=^"

set REFERENCE_4_VALUE_r1=$/{TEST_4_VALUE_01
set REFERENCE_4_VALUE_r2=$/{TEST_4_VALUE_02
set REFERENCE_4_VALUE_r3=$/{TEST_4_VALUE_03

call :TEST test_4_escape.vars TEST_4_VALUE_ REFERENCE_4_VALUE_  11 12 13  21 22 23  31 32 33  41 42 43  51 52 53  61 62 63  71 72 73  81 82 83  91 92 93 ^
  a1 a2 a3  b1 b2 b3  c1 c2 c3  d1 d2 d3  e1 e2 e3  f1 f2 f3  g1 g2 g3  h1 h2 h3  i1 i2 i3  j1 j2 j3  k1 k2 k3  l1 l2 l3  m1 m2 m3  n1 n2 n3 ^
  o1 o2 o3  p1 p2 p3  q1 q2 q3  r1 r2 r3
endlocal

setlocal
for %%i in (0 1 2 3 4 5 7) do set "REFERENCE_5_VALUE_%%i="
set REFERENCE_5_VALUE_6="" #
set REFERENCE_5_VALUE_8="" #
set REFERENCE_5_VALUE_9=^"#^"
call :TEST test_5_commentary.vars TEST_5_VALUE_ REFERENCE_5_VALUE_  0 1 2 3 4 5 6 7 8 9
endlocal

setlocal
set "REFERENCE_6_VALUE_1=1"
set "REFERENCE_6_VALUE_2==1	 1"
set "REFERENCE_6_VALUE_3=1	 1"
set "REFERENCE_6_VALUE_4=1	 =="
set "REFERENCE_6_VALUE_5=="
set "REFERENCE_6_VALUE_6=	 "
set REFERENCE_6_VALUE_7='	 ^"
set REFERENCE_6_VALUE_8=^"	 '
set "REFERENCE_6_VALUE_9='	 '"
call :TEST test_6_specific.vars TEST_6_VALUE_ REFERENCE_6_VALUE_  1 2 3 4 5 6 7 8 9
endlocal

echo.

rem WARNING: must be called without the call prefix!
"%TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
echo.%~1...
call "%%TESTLIB_ROOT%%/test.bat" %%*
exit /b
