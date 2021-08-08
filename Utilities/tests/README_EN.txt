* README_EN.txt
* 2021.08.08
* contools--utilities--tests

1. DESCRIPTION
2. USAGE
2.1. manual
2.1.1. manual/contools/callf

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Set of tests for contools utilities.

-------------------------------------------------------------------------------
2. USAGE
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
2.1. manual
-------------------------------------------------------------------------------

Manual tests must be run only by hand. Currently for some reason can not
automated.

-------------------------------------------------------------------------------
2.1.1. manual/contools/callf
-------------------------------------------------------------------------------

You must run each test twice:

1. From GUI application like the `Total Commander`.

   NOTE:
      The parent process must not be a console application, so the Far does
      not fit here.

2. From console application like the `cmd.exe` (`cmd.exe /k`).

CAUTION:
  This is a mandatory because several tests tries reattach to an ancestor
  process console window and may produce different results if run from GUI or
  console application!

NOTE:
  You must run each test several times (3-5 times).
  The `cmd.exe` may "mixing" standard handles addresses layout after each run
  of an executable.

  For example:

  Run #1: stdin=0x03, stdout=0x0b, stderr=0x0f
  Run #2: stdin=0x03, stdout=0x0f, stderr=0x13
  Run #3: stdin=0x03, stdout=0x13, stderr=0x0b
  Run #4: stdin=0x03, stdout=0x0b, stderr=0x0f
  Run #5: stdin=0x03, stdout=0x0f, stderr=0x13
  etc

NOTE:
  You must run each test from both the User and the Administrator privileges
  process. To do that you can run `Total Commander` or `cmd.exe` as
  Administrator.

All these affect test results. All runs must produce the same results.
