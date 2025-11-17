* README_EN.txt
* 2025.11.16
* contools--testlib

1. DESCRIPTION
2. EXTERNALS
3. CATALOG CONTENT DESCRIPTION
4. LIBRARY SCRIPTS DESCRIPTION
5. TESTS CATALOG EXAMPLE
6. TEST FILES CONTENT EXAMPLE

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Test library scripts for Windows Batch interpreter (cmd.exe).

-------------------------------------------------------------------------------
2. EXTERNALS
-------------------------------------------------------------------------------
See details in `README_EN.txt` in `externals` project:

https://github.com/andry81/externals

-------------------------------------------------------------------------------
3. CATALOG CONTENT DESCRIPTION
-------------------------------------------------------------------------------
<root>
 |
 +- /`test.bat`
 |    #
 |    # Main entry point script to a user test script.
 |
 +- /`test_entry.bat`
 |    #
 |    # Optional entry point script to a user test script.
 |
 +- /`init.bat`
 |    #
 |    # A test or a tests group initialization script.
 |
 +- /`exit.bat`
      #
      # A test or a tests group exit script.

All other scripts in the root are internal.

-------------------------------------------------------------------------------
4. LIBRARY SCRIPTS DESCRIPTION
-------------------------------------------------------------------------------

test.bat:

  Main entry point script to a user test script.

  A user script must contain the handlers in separate scripts in this file
  structure format (in a call order):

    /<user_test_script>.bat

      /.<user_test_script>/setup.bat

        /.<user_test_script>/init.bat
        /.<user_test_script>/impl.bat
        /.<user_test_script>/exit.bat
        /.<user_test_script>/report.bat

      /.<user_test_script>/teardown.bat

  , where:

    /<user_test_script>.bat
      A test user script.
      Calls once to `testlib/init.bat`, multiple times to
      `testlib/test.bat` and once to `testlib/exit.bat` scripts.

    /.<user_test_script>/setup.bat
      [OPTIONAL]
      A test first time setup handler, calls from `testlib/init.bat`
      script.

    /.<user_test_script>/teardown.bat
      [OPTIONAL]
      A test last time tear down handler, calls from `testlib/exit.bat`
      script.

    /.<user_test_script>/init.bat
      [OPTIONAL]
      A test initialization handler, required to process a test command
      line arguments, calls from `testlib/test.bat` script.

    /.<user_test_script>/impl.bat
      [REQUIRED]
      A test implementation handler, does not have a command line
      arguments, checks a user test variables and returns exit code to trigger
      a success or a fail, sets `TEST_IMPL_ERROR` variable to store a test exit
      code, calls from `testlib/test.bat` script.
      Does not call if `/.<user_test_script>/init.bat` has returned a not zero
      exit code.

    /.<user_test_script>/exit.bat
      [OPTIONAL]
      A test exit handler, checks a user test variables and returns exit code
      to trigger a success or a fail, useful if required to copy test data out
      of a test script temporary output directory, calls from
      `testlib/test.bat` script.
      Always calls after the `/.<user_test_script>/impl.bat` script.
      Can use `TEST_LAST_ERROR` variable to use the exit code either of
      `/.<user_test_script>/init.bat` or `/.<user_test_script>/impl.bat`, and
      can reset it to 0.

    /.<user_test_script>/report.bat
      [OPTIONAL]
      A test report handler to print a test result.

    NOTE:
      The `test.bat` script does rely only on `TEST_LAST_ERROR` variable to
      count the succeeded tests, when the `exit.bat` does rely on multiple
      custom conditions which basically includes `TEST_IMPL_ERROR` together
      with a test internal variables from the `init.bat` script or an external
      scope. The `TEST_LAST_ERROR` variable inside the `report.bat` script is
      just a return code from `init.bat`, `impl.bat` or `exit.bat` script,
      which one has called the last and so may not be checked at all.
      If you want a consistent result, then you must use in the `report.bat`
      script `TEST_LAST_ERROR` variable only.

NOTE:
  The `.<user_test_script>` parent directory can be changed by using
  `TEST_SCRIPT_HANDLERS_DIR` variable.

-------------------------------------------------------------------------------
5. TESTS CARALOG EXAMPLE
-------------------------------------------------------------------------------
<root>
 |
 +- /__init__
 |  |
 |  +- __init__.bat
 |  +- script_init.bat
 |
 +- /_config
 |  |
 |  +- config.system.vars.in
 |
 +- /.test_me
 |  |
 |  +- setup.bat
 |  +- init.bat
 |  +- impl.bat
 |  +- exit.bat
 |  +- report.bat
 |  +- teardown.bat
 |
 +- test_me.bat
 |
 +- test_their_!exclusive.bat
 |
 +- test__their2_another_exclusive.bat
 |
 +- test_all.bat

-------------------------------------------------------------------------------
6. TEST FILES CONTENT EXAMPLES
-------------------------------------------------------------------------------

Here is variant of test files for a unit test cases.


config.system.vars.in:

  TEST_DATA_IN_ROOT             ="%TESTS_PROJECT_ROOT%/_testdata"
  TEST_DATA_OUT_ROOT            ="%PROJECT_OUTPUT_ROOT%/_tests/unit/out"
  TEST_DATA_TEMP_ROOT           ="%PROJECT_OUTPUT_ROOT%/_tests/unit/temp"

---

__init__.bat:

  @echo off

  if defined MY_PROJECT_TESTS_INIT0_DIR if exist "%MY_PROJECT_TESTS_INIT0_DIR%\*" exit /b 0

  call "%%~dp0..\..\__init__\__init__.bat" || exit /b

  set "MY_PROJECT_TESTS_INIT0_DIR=%~dp0"

  call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TESTS_PROJECT_ROOT "%%~dp0.."

  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config_dir.bat" "%%TESTS_PROJECT_ROOT%%/_config" || exit /b

  rem initialize testlib "module"
  call "%%CONTOOLS_ROOT%%/testlib/__init__.bat" || exit /b

  exit /b 0

---

script_init.bat:

  @echo off

  if %IMPL_MODE%0 NEQ 0 goto IMPL

  call "%%~dp0__init__.bat" || exit /b

  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/check_vars.bat" CONTOOLS_PROJECT_ROOT PROJECT_OUTPUT_ROOT PROJECT_LOG_ROOT CONTOOLS_ROOT CONTOOLS_UTILS_BIN_ROOT || exit /b

  call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%* || exit /b

  set USE_LOG_BOOT_UP_TIME=1

  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/init_project_log.bat" "%%?~n0%%" || exit /b

  rem call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/init_vars_file.bat" || exit /b

  call "%%CONTOOLS_ROOT%%/std/callshift.bat" -skip 3 1 "%%CONTOOLS_ROOT%%/exec/exec_callf_prefix.bat" -X /pause-on-exit -- %%* || exit /b

  rem The caller must exit after this exit.
  exit /b 0

  :IMPL
  rem CAUTION: We must to reinit the builtin variables in case if `IMPL_MODE` was already setup outside.
  call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%* || exit /b

  rem rem load initialization environment variables
  rem if defined INIT_VARS_FILE call "%%CONTOOLS_ROOT%%/std/set_vars_from_file.bat" "%%INIT_VARS_FILE%%"

  rem call "%%CONTOOLS_ROOT%%/std/get_cmdline.bat" %%*
  rem call "%%CONTOOLS_ROOT%%/std/echo_var.bat" RETURN_VALUE ">"
  rem echo;

  rem if 0%TESTLIB__INIT% EQU 0 (
  rem   rem CPU name to compare bench tests
  rem   call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%SystemRoot%%\System32\wbem\wmic.exe" cpu get Caption,Name
  rem )

  rem The caller can continue after this exit.
  exit /b 0

---

test_all.bat:

  @echo off

  setlocal DISABLEDELAYEDEXPANSION

  call "%%~dp0__init__/__init__.bat" || exit /b
  call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

  for %%i in ("%TESTS_PROJECT_ROOT%\test_*.bat") do (
    set "SCRIPT_NAME=%%~ni"
    set "SCRIPT_FILE=%%i"
    call "%%CONTOOLS_ROOT%%/std/if_.bat" ^
      "%%SCRIPT_NAME:!=%%" == "%%SCRIPT_NAME%%" ^
      if not "%%SCRIPT_FILE:*\%~nx0=%%" == "" ^
      if "%%SCRIPT_FILE:*\test__=%%" == "%%SCRIPT_FILE%%" ^
        && call "%%CONTOOLS_ROOT%%/std/call.bat" "%%SCRIPT_FILE%%"
  )

  rem WARNING: must be called without the call prefix!
  "%CONTOOLS_TESTLIB_ROOT%/exit.bat"

  rem no code can be executed here, just in case
  exit /b

---

Example of a test for `strlen.bat` script from the `contools` project.

test_01_strlen.bat:

  @echo off

  setlocal

  call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
  if %IMPL_MODE%0 EQU 0 exit /b

  call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
  call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

  set "__STRING__="
  call :TEST 0

  set __STRING__=123
  call :TEST 3

  set __STRING__=123 456
  call :TEST 7

  echo;

  rem WARNING: must be called without the call prefix!
  "%CONTOOLS_TESTLIB_ROOT%/exit.bat"

  rem no code can be executed here, just in case
  exit /b

  :TEST
  call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
  exit /b

---

.test_01_strlen.bat/init.bat:

  @echo off

  set "STRING_LEN=%~1"

  exit /b 0

---

.test_01_strlen.bat/impl.bat:

  @echo off

  call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v
  set TEST_IMPL_ERROR=%ERRORLEVEL%

  exit /b 0

---

.test_01_strlen.bat/exit.bat:

  @echo off

  call "%%CONTOOLS_ROOT%%/std/cmp_nvar.bat" STRING_LEN EQU TEST_IMPL_ERROR || exit /b 10

  exit /b 0

---

.test_01_strlen.bat/report.bat:

@echo off

  setlocal ENABLEDELAYEDEXPANSION

  if !TEST_LAST_ERROR! NEQ 0 (
    echo;FAILED: !TESTLIB__TEST_ORDER_NUMBER!: (!TEST_IMPL_ERROR! == !STRING_LEN!^) STRING=`!__STRING__!`
    echo;
    exit /b 0
  )

  echo;PASSED: !TESTLIB__TEST_ORDER_NUMBER!: LEN=`!STRING_LEN!` STRING=`!__STRING__!`

  exit /b 0

---

Example of `test_01_strlen.bat` execution:

  Running test_01_strlen.bat...

  PASSED: 1: LEN=`0` STRING=``
  PASSED: 2: LEN=`3` STRING=`123`
  PASSED: 3: LEN=`7` STRING=`123 456`

  Time spent: 0.050 secs (test_01_strlen.bat)

     3 of 3 current tests is passed.

     3 of 3 overall tests is passed.

  Press any key to continue . . .

---

Example of `test_all.bat` execution:

  Running test_all.bat...

  Running test_01_strlen.bat...

  PASSED: 1: LEN=`0` STRING=``
  PASSED: 2: LEN=`3` STRING=`123`
  PASSED: 3: LEN=`7` STRING=`123 456`

  Time spent: 0.050 secs (test_all.bat->test_01_strlen.bat)

     3 of 3 current tests is passed.

  Time spent: 0.060 secs (test_all.bat)

     3 of 3 current tests is passed.

     3 of 3 overall tests is passed.

  Press any key to continue . . .

---
