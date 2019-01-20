if (NOT INCLUDE_FILE)
  message(FATAL_ERROR "* INCLUDE_FILE variable must be defined!")
endif()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

include(Version)

generate_build_version_variables()
generate_build_version_include_file(${INCLUDE_FILE})

unset(INCLUDE_FILE CACHE)
unset(BUILD_VERSION_DATE_TIME_STR CACHE)
unset(BUILD_VERSION_DATE_TIME_TOKEN CACHE)
