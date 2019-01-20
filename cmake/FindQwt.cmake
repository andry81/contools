# Qt Widgets for Technical Applications
# available at http://qwt.sourceforge.net/
#
# The module defines the following variables:
#  QWT_FOUND - the system has Qwt
#  QWT_INCLUDE_DIR - where to find qwt_plot.h
#  QWT_INCLUDE_DIRS - qwt includes
#  QWT_LIBRARY - where to find the Qwt library
#  QWT_LIBRARY_DIRS - list of paths with found Qwt libraries (debug, release)
#  QWT_LIBRARIES - aditional libraries
#  QWT_MAJOR_VERSION - major version
#  QWT_MINOR_VERSION - minor version
#  QWT_PATCH_VERSION - patch version
#  QWT_VERSION_STRING - version (ex. 5.2.1)
#  QWT_ROOT_DIR - root dir (ex. /usr/local)


find_path(QWT_INCLUDE_DIR
  NAMES qwt_plot.h
  HINTS ${QT_INCLUDE_DIR} ${QWT_ROOT} ENV QWT_ROOT
  PATH_SUFFIXES include qwt
)

set(QWT_INCLUDE_DIRS ${QWT_INCLUDE_DIR})

# version
set(_VERSION_FILE ${QWT_INCLUDE_DIR}/qwt_global.h)
if (EXISTS ${_VERSION_FILE})
  file(STRINGS ${_VERSION_FILE} _VERSION_LINE REGEX "define[ ]+QWT_VERSION_STR")
  if (_VERSION_LINE)
    string(REGEX REPLACE ".*define[ ]+QWT_VERSION_STR[ ]+\"(.*)\".*" "\\1" QWT_VERSION_STRING "${_VERSION_LINE}")
    string(REGEX REPLACE "([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\1" QWT_MAJOR_VERSION "${QWT_VERSION_STRING}")
    string(REGEX REPLACE "([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\2" QWT_MINOR_VERSION "${QWT_VERSION_STRING}")
    string(REGEX REPLACE "([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\3" QWT_PATCH_VERSION "${QWT_VERSION_STRING}")
  endif()
endif()

# check version
set(_QWT_VERSION_MATCH TRUE)
if (Qwt_FIND_VERSION AND QWT_VERSION_STRING)
  if (Qwt_FIND_VERSION_EXACT)
    if (NOT Qwt_FIND_VERSION VERSION_EQUAL QWT_VERSION_STRING)
      set(_QWT_VERSION_MATCH FALSE)
    endif()
  elseif (QWT_VERSION_STRING VERSION_LESS Qwt_FIND_VERSION)
    set(_QWT_VERSION_MATCH FALSE)
  endif()
endif()

# find qwt libs
find_library(QWT_LIBRARY_RELEASE
  NAMES qwt
  HINTS ENV QWT_ROOT ${QWT_ROOT} ${QT_LIBRARY_DIR}
  PATH_SUFFIXES lib
)

if (WIN32)
  find_library(QWT_LIBRARY_DEBUG
    NAMES qwtd
    HINTS ENV QWT_ROOT ${QWT_ROOT} ${QT_LIBRARY_DIR}
    PATH_SUFFIXES lib
  )
endif()

# adjust qwt libs variables
if (QWT_LIBRARY_RELEASE AND NOT QWT_LIBRARY_DEBUG)
  set(QWT_LIBRARY_DEBUG ${QWT_LIBRARY_RELEASE})
  set(QWT_LIBRARY       ${QWT_LIBRARY_RELEASE})
  set(QWT_LIBRARIES     ${QWT_LIBRARY_RELEASE})
elseif (QWT_LIBRARY_DEBUG AND NOT QWT_LIBRARY_RELEASE)
  set(QWT_LIBRARY_RELEASE ${QWT_LIBRARY_DEBUG})
  set(QWT_LIBRARY         ${QWT_LIBRARY_DEBUG})
  set(QWT_LIBRARIES       ${QWT_LIBRARY_DEBUG})
elseif (QWT_LIBRARY_DEBUG AND QWT_LIBRARY_RELEASE)
  # if the generator supports configuration types then set
  # optimized and debug libraries, or if the CMAKE_BUILD_TYPE has a value
  if (CMAKE_CONFIGURATION_TYPES OR CMAKE_BUILD_TYPE)
    set(QWT_LIBRARY optimized ${QWT_LIBRARY_RELEASE} debug ${QWT_LIBRARY_DEBUG})
  else()
    # if there are no configuration types and CMAKE_BUILD_TYPE has no value
    # then just use the release libraries
    set(QWT_LIBRARY ${QWT_LIBRARY_RELEASE})
  endif()
  set(QWT_LIBRARIES optimized ${QWT_LIBRARY_RELEASE} debug ${QWT_LIBRARY_DEBUG})
endif()

if (QWT_LIBRARY_RELEASE)
  get_filename_component(_qwt_library_release_dir "${QWT_LIBRARY_RELEASE}" DIRECTORY)
  list(APPEND QWT_LIBRARY_DIRS ${_qwt_library_release_dir})
endif()
if (QWT_LIBRARY_DEBUG)
  get_filename_component(_qwt_library_debug_dir "${QWT_LIBRARY_DEBUG}" DIRECTORY)
  list(APPEND QWT_LIBRARY_DIRS ${_qwt_library_debug_dir})
endif()
if (QWT_LIBRARY_DIRS)
  list(REMOVE_DUPLICATES QWT_LIBRARY_DIRS)
endif()

# try to guess root dir from include dir
if (QWT_INCLUDE_DIR)
  string(REGEX REPLACE "(.*)/include.*" "\\1" QWT_ROOT_DIR ${QWT_INCLUDE_DIR})
# try to guess root dir from library dir
elseif(QWT_LIBRARY)
  string(REGEX REPLACE "(.*)/lib[/|32|64].*" "\\1" QWT_ROOT_DIR ${QWT_LIBRARY})
endif()

set(QWT_DEFINITIONS "-DQWT_DLL")

# handle the QUIETLY and REQUIRED arguments
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Qwt
    REQUIRED_VARS QWT_LIBRARY QWT_INCLUDE_DIR QWT_LIBRARY_DIRS _QWT_VERSION_MATCH QWT_DEFINITIONS
    VERSION_VAR QWT_VERSION_STRING
)

mark_as_advanced(
  QWT_LIBRARY
  QWT_LIBRARIES
  QWT_INCLUDE_DIR
  QWT_INCLUDE_DIRS
  QWT_LIBRARY_DIRS
  QWT_MAJOR_VERSION
  QWT_MINOR_VERSION
  QWT_PATCH_VERSION
  QWT_VERSION_STRING
  QWT_ROOT_DIR
  QWT_DEFINITIONS
)
