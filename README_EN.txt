* README_EN.txt
* 2021.07.09
* contools

** README UNDER CONSTRUCTION **

1. DESCRIPTION
2. LICENSE
3. REPOSITORIES
4. PREREQUISITES
5. DEPENDENCIES
6. CATALOG CONTENT DESCRIPTION
7. PROJECT CONFIGURATION VARIABLES
8. PRECONFIGURE
9. CONFIGURE
9.1. Generation step(s)
9.2. Configuration step
10. BUILD
10.1. From scripts
10.2. From `Visual Studio`
10.3. From `Qt Creator`
11. INSTALL
12. POSTINSTALL
13. KNOWN ISSUES
13.1. The `CMAKE_BUILD_TYPE variable must not be set in case of a multiconfig
      generator presence and must be set if not: ...` cmake configuration
      error message
14. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
A wide range of scripts for Windows interpreter (cmd.exe) and other
interpreters such as bash shell (.sh), visual basic (.vbs), jscript (.js),
python (.py), perl (.pl) and so on. Plus some set of standalone console
utilities aside other utilities from cygwin, msys and mingw.

WARNING:
  Use the SVN access to find out latest functionality and bug fixes.
  See the REPOSITORIES section.

-------------------------------------------------------------------------------
2. LICENSE
-------------------------------------------------------------------------------
The MIT license (see included text file "license.txt" or
https://en.wikipedia.org/wiki/MIT_License)

-------------------------------------------------------------------------------
3. REPOSITORIES
-------------------------------------------------------------------------------
Primary:
  * https://sf.net/p/contools/contools/HEAD/tree/trunk/
    https://svn.code.sf.net/p/contools/contools/trunk
First mirror:
  * https://github.com/andry81/contools/tree/trunk
    https://github.com/andry81/contools.git
Second mirror:
  * https://bitbucket.org/andry81/contools/src/trunk
    https://bitbucket.org/andry81/contools.git

The `tacklelib` library repositories:

Primary:
  * https://sf.net/p/tacklelib/tacklelib/HEAD/tree/trunk
  * https://svn.code.sf.net/p/tacklelib/tacklelib/trunk
First mirror:
  * https://github.com/andry81/tacklelib/tree/trunk
  * https://github.com/andry81/tacklelib.git
Second mirror:
  * https://bitbucket.org/andry81/tacklelib/src/trunk
  * https://bitbucket.org/andry81/tacklelib.git

-------------------------------------------------------------------------------
4. PREREQUISITES
-------------------------------------------------------------------------------

Currently used these set of OS platforms, compilers, interpreters, modules,
IDE's, applications and patches to run with or from:

1. OS platforms:

* Windows 7 (`.bat` only, minimal version for the cmake 3.14)
* Cygwin 1.5+ or 3.0+ (`.sh` only):
  https://cygwin.com
  - to run scripts under cygwin
* Msys2 20190524+ (`.sh` only):
  https://www.msys2.org
  - to run scripts under msys2
* Linux Mint 18.3 x64 (`.sh` only)

2. C++11 compilers:

* (primary) Microsoft Visual C++ 2015 Update 3 or Microsoft Visual C++ 2017
* (secondary) GCC 5.4+
* (experimental) Clang 3.8+

3. Interpreters:

* bash shell 3.2.48+
  - to run unix shell scripts
* cmake 3.14+ :
  https://cmake.org/download/
  - to run cmake scripts and modules
* python 3.7.3 or 3.7.5 (3.4+ or 3.5+)
  https://python.org
  - standard implementation to run python scripts
  - 3.7.4 has a bug in the `pytest` module execution (see `KNOWN ISSUES`
    section).
  - 3.6.2+ is required due to multiple bugs in the python implementation prior
    this version (see `KNOWN ISSUES` section).
  - 3.5+ is required for the direct import by a file path (with any extension)
    as noted in the documentation:
    https://docs.python.org/3/library/importlib.html#importing-a-source-file-directly
* cmake 3.15.1 (3.14+):
  https://cmake.org/download/
  - to run cmake scripts and modules
  - 3.14+ does allow use generator expressions at install phase:
    https://cmake.org/cmake/help/v3.14/policy/CMP0087.html
* Windows Script Host 5.8+
  - standard implementation to run vbs scripts

4. Applications:

* subversion 1.8+
  https://tortoisesvn.net
  - to run svn client
* git 2.24+
  https://git-scm.com
  - to run git client
* cygwin cygpath 1.42+
  - to run `bash_entry` script under cygwin
* msys cygpath 3.0+
  - to run `bash_entry` script under msys2
* cygwin readlink 6.10+
  - to run specific bash script functions with `readlink` calls

5. IDE's.

* Microsoft Visual Studio 2015 Update 3
* Microsoft Visual Studio 2017
* QtCreator 4.6+

Noticeable cmake changes from the version 3.14:

https://cmake.org/cmake/help/v3.14/release/3.14.html#deprecated-and-removed-features

* The FindQt module is no longer used by the find_package() command as a find
  module. This allows the Qt Project upstream to optionally provide its own
  QtConfig.cmake package configuration file and have applications use it via
  find_package(Qt) rather than find_package(Qt CONFIG). See policy CMP0084.

* Support for running CMake on Windows XP and Windows Vista has been dropped.
  The precompiled Windows binaries provided on cmake.org now require Windows 7
  or higher.

https://cmake.org/cmake/help/v3.14/release/3.14.html#id13

* The install(CODE) and install(SCRIPT) commands learned to support generator
  expressions. See policy CMP0087
  (https://cmake.org/cmake/help/v3.14/policy/CMP0087.html):

  In CMake 3.13 and earlier, install(CODE) and install(SCRIPT) did not evaluate
  generator expressions. CMake 3.14 and later will evaluate generator
  expressions for install(CODE) and install(SCRIPT).

-------------------------------------------------------------------------------
5. DEPENDENCIES
-------------------------------------------------------------------------------
Read the `README_EN.deps.txt` file for the common dependencies for the Windows
and the Linux platforms.

NOTE:
  To run bash shell scripts (`.sh` file extension) you should copy from the
  `tacklelib` library the `/bash/tacklelib/bash_entry` module into the `/bin`
  directory of your platform.

To prepare local third party library sources you can:

  1. Download the local third party project: `contools--3dparty`
     (see the `REPOSITORIES` section).
  2. Read the instructions in the project readme to checkout and build
     third party libraries.
  3. Link the checkouted library sources as a directory using the `mklink`
     command:
     `mklink /D _3dparty <path-to-project-root>/_src`
     or
     Run the `01_preconfigure.*` script to make all links together
     (see the `PRECONFIGURE` section).

-------------------------------------------------------------------------------
6. CATALOG CONTENT DESCRIPTION
-------------------------------------------------------------------------------

<root>
 |
 +- /`_3dparty`
 |  #
 |  # Local 3dparty dependencies catalog. Must be created by the user.
 |
 +- /`_out`
 |  #
 |  # Temporary directory with build output.
 |
 +- /`_config`
 |  | #
 |  | # Directory with build configuration files.
 |  |
 |  +- /`_scripts`
 |  |    #
 |  |    # Directory with text files containing command lines for scripts from
 |  |    # `/_scripts` directory
 |  |
 |  +- `environment_system.vars.in`
 |  |   #
 |  |   # Template file with system set of environment variables
 |  |   # designed to be stored in a version control system.
 |  |
 |  +- `environment_system.vars`
 |  |   #
 |  |   # Generated temporary file from `*.in` file with set of system
 |  |   # customized environment variables to set them locally.
 |  |   # Loads after the global/3dparty environment configuration file(s) but
 |  |   # before the user customized environment variables file.
 |  |
 |  +- `environment_user.vars.in`
 |  |   #
 |  |   # Template file with user set of environment variables
 |  |   # designed to be stored in a version control system.
 |  |
 |  +- `environment_user.vars`
 |      #
 |      # Generated temporary file with set of user customized environment
 |      # variables to set them locally.
 |      # Loads after the system customized environment variables file.
 |
 +- /`_scripts`
 |  | #
 |  | # Scripts to generate, configure, build, install and pack the entire
 |  | # solution.
 |  | # Contains special `__init*__` script to allocate basic environment
 |  | # variables and make common preparations.
 |  |
 |  +-/`01_generate_src.*`
 |  |   #
 |  |   # Script to generate source files in the root project and local 3dparty
 |  |   # subprojects and libraries which are should not be included in a
 |  |   # version control system.
 |  |
 |  +-/`02_generate_config.*`
 |  |   #
 |  |   # Script to generate configuration files in the `_config` subdirectory
 |  |   # which are should not be included in a version control system.
 |  |
 |  +-/`03_configure.*`
 |  |   #
 |  |   # Script to call cmake configure step versus default or custom target.
 |  |
 |  +-/`04_build.*`
 |  |   #
 |  |   # Script to call cmake build step versus default or custom target.
 |  |
 |  +-/`05_install.*`
 |  |   #
 |  |   # Script to call cmake install step versus default or custom target.
 |  |
 |  +-/`06_post_install.*`
 |  |   #
 |  |   # Script to call not cmake post install step.
 |  |
 |  +-/`06_pack.*`
 |      #
 |      # Script to call cmake pack step on the bundle target.
 |
 +- /`cmake`
 |    #
 |    # Directory with external cmake modules.
 |
 +- /`deploy`
 |    #
 |    # Directory to deploy files in postinstall phase.
 |
 +- /`doc`
 |    #
 |    # Directory with documentation files.
 |
 +- /`include`
 |    #
 |    # Directory with public includes.
 |
 +- /`src`
 |    #
 |    # Directory with sources to build.
 |
 +- /`Scripts`
 |    #
 |    # The root for all scripts and tools including external or standalone.
 |
 +- /`Utilities`
 |    #
 |    # Utilities built by the project.
 |
 +- `01_preconfigure.*`
 |   #
 |   # Scrtip to make a local preconfigure.
 |
 +- `02_configure.*`
 |   #
 |   # Scrtip to make a local configure.
 |
 +- `CMakeLists.txt`
     #
     # The cmake catalog root description file.

-------------------------------------------------------------------------------
7. PROJECT CONFIGURATION VARIABLES
-------------------------------------------------------------------------------

1. `_config/environment_system.vars`
   `_config/environment_user.vars`

These files must be designed per a particular project and platform, but several
values are immutable to a project and a platform, and must always exist.

Here is the list of a most required of them (system variables):

* CMAKE_OUTPUT_ROOT, CMAKE_OUTPUT_DIR, CMAKE_OUTPUT_GENERATOR_DIR,
  CMAKE_BUILD_ROOT, CMAKE_BIN_ROOT, CMAKE_LIB_ROOT, CMAKE_INSTALL_ROOT,
  CMAKE_PACK_ROOT, CMAKE_INSTALL_PREFIX, CPACK_OUTPUT_FILE_PREFIX

Predefined set of basic roots and directories to point out the base
construction of a project directories involved in a build.

* CMAKE_BUILD_DIR, CMAKE_BIN_DIR, CMAKE_LIB_DIR, CMAKE_INSTALL_ROOT,
  CMAKE_PACK_DIR

Auto generated directory paths which does exist only after the configure step
have has to run. Can not be predefined because dependent on the generator
`multiconfig` functionality and an existence of (not) empty CMAKE_BUILD_TYPE
dynamic variable.

* PROJECT_NAME

Name of the project. Must contain the same value as respective `project(...)`
command in the `CMakeLists.txt` file, otherwise an error will be thrown.

* PROJECT_TOP_ROOT, PROJECT_ROOT

Optional variables to pinpoint the most top parent project root and the current
project root. Has used as base variables to point project local 3dparty
directories. Must be initialized from respective builtin
CMAKE_TOP_PACKAGE_SOURCE_DIR, CMAKE_CURRENT_PACKAGE_SOURCE_DIR
variables which does initialize after the `tkl_configure_environment`
(`/cmake/tacklelib/Project.cmake`) macro call.

* _3DPARTY_GLOBAL_ROOTS_LIST, _3DPARTY_GLOBAL_ROOTS_FILE_LIST

Optional variables which does define directories and files as a Cartesian
product and has used from the `find_global_3dparty_environments` function
(`/cmake/tacklelib/_3dparty/Global3dparty.cmake`).
Is required in case of a global or an external 3dparty project or library
which is not a local part of the project.
Loads at first before the `/_config/environment_system.vars` and
the `/_config/environment_user.vars` configuration files.

* _3DPARTY_LOCAL_ROOT

Optional variable which defines a directory with local 3dparty projects or
libraries.

* CMAKE_CONFIG_TYPES=(<space_separated_list>)

Required variable which defines predefined list of configuration names has used
from the `/_scripts/*_configure.*` script.

Example:
  CMAKE_CONFIG_TYPES=(Release Debug RelWithDebInfo MinSizeRel)

* CMAKE_CONFIG_ABBR_TYPES=(<semicolon_separated_list>)

An optional variable which defines a list of associated with the
CMAKE_CONFIG_TYPES variable values of abbreviated configuration names has used
from the `/_scripts/*_configure.*` script.
Useful to define short names for respective complete configuration names to
issue them in respective scripts from the `/_scripts` directory.

Example:
  CMAKE_CONFIG_ABBR_TYPES=(r d rd rm)

* CMAKE_GENERATOR

The cmake generator name does used from the `/_scripts/*_configure.*` script.
Can be defined multiple times for different platforms.

Example(s):
  CMAKE_GENERATOR:WIN="Visual Studio 14 2015"
  CMAKE_GENERATOR:UNIX="Unix Makefiles"

* CMAKE_GENERATOR_PLATFORM

The cmake version 3.14+ can use a separate architecture name additionally to
the generator name.

Example:
  # required for the CMAKE_OUTPUT_GENERATOR_DIR, because the architecture
  # parameter does not supported in the `environment_system.vars` stage
  CMAKE_GENERATOR_PLATFORM:WIN=Win32

  # must be at least empty to avoid generation of the
  # `*:$/{CMAKE_GENERATOR_PLATFORM}` as an replacement value
  CMAKE_GENERATOR_PLATFORM:UNIX=""

-------------------------------------------------------------------------------
8. PRECONFIGURE
-------------------------------------------------------------------------------

NOTE:
  Some of steps from this section and after will be applicable both for the
  Windows platform (`.bat` file extension) and for the Linux like platform
  (`.sh` file extension).

To run bash shell scripts (`.sh` file extension) you should copy the
`Scripts/Tools/ToolAdaptors/sh/bash_entry` into the `/bin` directory of your
platform.

CAUTION:
  For the Linux like platform do read the `README_EN.linux_x86_64.txt` file
  from the `tacklelib` library to properly set permissions on the file.

To be able to configure and build the sources you must run the
`preconfigure.*` script at least once.

-------------------------------------------------------------------------------
9. CONFIGURE
-------------------------------------------------------------------------------

NOTE:
  For the additional details related particularly to the Linux do read the
  `README_EN.linux_x86_64.txt` file.

run `02_configure.*`

Windows executable utilities can be built if necessary under Microsoft Visual
Studio C++ 2015 Community Edition. The utilities does not require an installed
Microsoft Visual C++ 2015 Redistributables at runtime.

-------------------------------------------------------------------------------
9.1. Generation step(s)
-------------------------------------------------------------------------------

To generate the source files which are not included in a version control system
do call to:

`/_scripts/01_generate_src.*` script.

If some from template instantiated source files has been changed before the
call, then they will be overwritten upon a call by the script unconditionally.

To generate configuration files which are not included in a version control
system do call to:

`/_scripts/02_generate_config.*` script.

If a version of a template file in the first line is different to the version
in the first line of the instantiated file, then an error would be thrown
(instantiated version change protection).

If some from template instantiated configuration files has been changed before
the script call and has the same version with the instantiated one files, then
they will be overwritten upon a call by the script
(another protection through the template file body hashing and caching is not
yet implemented).

If a build is stopping on errors described above, then you have to merge all
respective instantiated configuration files manually from template files before
continue or run the script again.

CAUTION:
  If a template file has been changed without the version line change, then the
  script will overwrite a previously instantiated file without a warning,
  because the script has no functionality to separately check a template file
  body change and so there is no prevension from an accidental overwrite of a
  previously instantiated configuration file with the user changes!

After that you should put or edit existed respective variables inside these
generated files:

* `/_config/environment_system.vars`
* `/_config/environment_user.vars`

The global or third party dependencies which are excluded from the source files
distribution does load through the separate configuration files is pointed by
the _3DPARTY_GLOBAL_ROOTS_LIST and _3DPARTY_GLOBAL_ROOTS_FILE_LIST list
variables.

For example, if:

_3DPARTY_GLOBAL_ROOTS_LIST=("d:/3dparty1" "d:/3dparty2")
_3DPARTY_GLOBAL_ROOTS_FILE_LIST=("environment1.vars" "environment2.vars")

, then the generated file paths would be ordered like this:

`d:/3dparty1/environment1.vars`
`d:/3dparty1/environment2.vars`
`d:/3dparty2/environment1.vars`
`d:/3dparty2/environment2.vars`

, and would be loaded together with the local configuration files but before
them:

`d:/3dparty1/environment1.vars`
`d:/3dparty1/environment2.vars`
`d:/3dparty2/environment1.vars`
`d:/3dparty2/environment2.vars`
`/_config/environment_system.vars`
`/_config/environment_user.vars`

To start use external 3dparty project directories you can take as a basic
example the 3dparty project structure from these links:

Primary:
  * https://svn.code.sf.net/p/tacklelib/3dparty/trunk
First mirror:
  * https://github.com/andry81/tacklelib--3dparty.git

-------------------------------------------------------------------------------
9.2. Configuration step
-------------------------------------------------------------------------------

To make a final configuration call to:

`/_scripts/03_configure.* [<ConfigName>]`, where:

  <ConfigName> has any value from the `CMAKE_CONFIG_TYPES` or
  the `CMAKE_CONFIG_ABBR_TYPES` variables from the `environment_system.vars`
  file or `*` to build all configurations.

NOTE:
  <ConfigName> must be used ONLY if the `CMAKE_GENERATOR` variable value is set
  to a not multiconfig generator, otherwise it must not be used.

-------------------------------------------------------------------------------
10. BUILD
-------------------------------------------------------------------------------

Does not matter which one method below would be selected when the output would
be in a directory pointed by the `CMAKE_BIN_DIR` configuration variable.

-------------------------------------------------------------------------------
10.1. From scripts
-------------------------------------------------------------------------------

1. Run `/_scripts/04_build.* [<ConfigName> [<TargetName>]]`, where:

  <ConfigName> has any value from the `CMAKE_CONFIG_TYPES` or
  the `CMAKE_CONFIG_ABBR_TYPES` variables from the `environment_system.vars`
  file or `*` to build all configurations.

  <TargetName> has any valid target name to build.

NOTE:
  To enumerate all callable target names from the cmake you can type a special
  target - `help`.

-------------------------------------------------------------------------------
10.2. From `Visual Studio`
-------------------------------------------------------------------------------

1. Open `<PROJECT_NAME>.sln` file addressed by a directory path in the
   `CMAKE_BUILD_DIR` dynamic variable.
2. Select any build type has been declared in the `CMAKE_CONFIG_TYPES`
   variable.
3. Run build from the IDE.

-------------------------------------------------------------------------------
10.3. From `Qt Creator`
-------------------------------------------------------------------------------

1. Open `CMakeLists.txt` file.
2. Remove all unsupported configurations not declared in the
   `CMAKE_CONFIG_TYPES` variable like the `Default` from the inner
   configuration list.
3. Select any build type has been declared in the `CMAKE_CONFIG_TYPES`
   variable.
4. Run build from the IDE.

-------------------------------------------------------------------------------
11. INSTALL
-------------------------------------------------------------------------------

1. Run `/_scripts/05_install.* [<ConfigName> [<TargetName>]]`, where:

  <ConfigName> has any value from the `CMAKE_CONFIG_TYPES` or
  the `CMAKE_CONFIG_ABBR_TYPES` variables from the `environment_system.vars`
  file or `*` to install all configurations.

  <TargetName> has any valid target name to install.

The output would be in a directory pointed by the `CMAKE_INSTALL_DIR`
configuration variable.

NOTE:
  The cmake may not support a target selection for a particular generator.

-------------------------------------------------------------------------------
12. POSTINSTALL
-------------------------------------------------------------------------------

NOTE:
  Is not required for the Windows platform.

1. Run `/_scripts/06_post_install.* [<ConfigName>]`, where:

  <ConfigName> has any value from the `CMAKE_CONFIG_TYPES` or
  the `CMAKE_CONFIG_ABBR_TYPES` variables from the `environment_system.vars`
  file or `*` to post install all configurations.

CAUTION:
  The containment of a directory pointed by the `CMAKE_INSTALL_DIR`
  configuration variable may be changed or rearranged, so another run can
  gain different results!

-------------------------------------------------------------------------------
13. KNOWN ISSUES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
13.1. The `CMAKE_BUILD_TYPE variable must not be set in case of a multiconfig
      generator presence and must be set if not: ...` cmake configuration
      error message
-------------------------------------------------------------------------------

The cmake configuration was generated under a cmake generator without
a multiconfig feature but the `CMAKE_BUILT_TYPE` variable was not defined, or
vice versa.

The configuration name value either must be passed explicitly into a script
from the `/_scripts` directory in case of not a multiconfig cmake generator or
must not in case of a multiconfig cmake generator.

Solution #1:

1. Pass the configuration name value explicitly into the script or make it
   not defined.

Solution #2:

1. Change the cmake generator in the `CMAKE_GENERATOR` configuration variable
   to the version with appropriate functionality.

Solution #3:

1. In case of the `Qt Creator` do remove the unsupported `Default`
   configuration at `Project` pane, where the `CMAKE_BUILD_TYPE` variable value
   is not applicable.

-------------------------------------------------------------------------------
14. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
