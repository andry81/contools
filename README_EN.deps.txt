* README_EN.deps.txt
* 2023.02.21
* contools

1. DESCRIPTION
2. DEPENDECIES

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------

See in `README_EN.txt` file.

-------------------------------------------------------------------------------
2. DEPENDECIES
-------------------------------------------------------------------------------

Legend:

00 demand:
    the dependency demand/optionality

01 platform:
    the dependency platform

02 version:
    the dependency base/minimal/exact version/revision/hash

03 desc:
    the dependency description

04 forked:
    the dependency forked storage or URL variants

05 original:
    the dependency original storage or URL variants

06 build:
    the dependency build variants

07 linkage:
    the dependency linkage variants

08 variables:
    the dependency configuration variables in a dependentee project

09 patched:
    the dependency has having applied patches

10 extended:
    the dependency has having wrappers, interfaces or extensions in other
    dependencies or in itself

11 included:
    the dependency sources inclusion variants into a dependentee project

12 macroses:
    a dependentee project macroses and definitions associated with the
    dependency

13 used as:
    the dependency usage variants

14 depend on:
    the dependency immediate dependent of variants from


# utility

* tacklelib
  00 demand:    REQUIRED
  01 platform:  WINDOWS, LINUX
  02 version:   N/A
  03 desc:      C++11 generic library with builtin wrappers/extensions to
                p7 logger, fmt, libarchive, gtest and etc
  04 forked:    NO
  05 original:  [01] https://github.com/andry81/tacklelib
                [02] https://sf.net/p/tacklelib/tacklelib
  06 build:     (default)   build from sources in a dependentee project
  07 linkage:   (default)   as a static library
  08 variables: UTILITY_TACKLELIB_ROOT, TACKLELIB_ADDRESS_MODEL,
                TACKLELIB_LINK_TYPE
  09 patched:   NO
  10 extended:  NO
  11 included:  YES:
                [01] as sources, locally in the `_externals` subdirectory
  12 macroses:  search in: `debug.hpp.in`, `optimization.hpp.in`,
                `setup.hpp.in`
  13 used as:   headers, sources, static libraries, scripts
! 14 depend on: YES:
                [01] (required) boost
                [02] (required) fmt
                [03] (optional) gtest
                [04] (optional) pystring
                [05] (optional) p7 logger
                [06] (optional) libarchive
                [07] (optional) 7zip
                [08] (optional) qd

* svncmd
  00 demand:    OPTIONAL
  01 platform:  WINDOWS
  02 version:   N/A
  03 desc:      svn batch scripts to automate svn working copy offline/online
                operations
  04 forked:    NO
  05 original:  [01] https://github.com/andry81/svncmd
                [02] https://sf.net/p/svncmd/scripts
  06 build:     N/A
  07 linkage:   N/A
  08 variables: SVNCMD_TOOLS_ROOT
  09 patched:   NO
  10 extended:  NO
  11 included:  YES:
                [01] as sources, locally in the `_externals` subdirectory
  12 macroses:  N/A
  13 used as:   scripts
! 14 depend on: YES:
                [01] (required) svn
                [02] (required) sqlite

# gui

* wxWidgets
  00 demand:    REQUIRED
  01 platform:  WINDOWS, LINUX
  02 version:   3.1.1.0+
  03 desc:      C++ GUI generic library
  04 forked:    NO
  05 original:  [01] https://github.com/wxWidgets/wxWidgets
  06 build:     (default)   standalone build from sources
  07 linkage:   (default)   prebuilded static libraries
                (optional)  prebuilded shared libraries
  08 variables: WXWIDGETS_ROOT
  09 patched:   NO
  10 extended:  NO
  11 included:  PARTIALLY, must be downloaded separately
  12 macroses:
  13 used as:   headers, static libraries, shared libraries
  14 depend on: NO
