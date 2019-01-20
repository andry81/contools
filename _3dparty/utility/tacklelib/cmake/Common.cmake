cmake_minimum_required(VERSION 3.9)

# at least cmake 3.9 is required for:
#   * Multiconfig generator detection support: see the `GENERATOR_IS_MULTI_CONFIG` global property
#

# CAUTION:
# 1. Be careful with the `set(... CACHE ...)` because it unsets the original
#    variable!
#    From documation:
#     "Finally, whenever a cache variable is added or modified by a command,
#     CMake also removes the normal variable of the same name from the current
#     scope so that an immediately following evaluation of it will expose the
#     newly cached value."
# 2. Be careful with the `set(... CACHE ... FORCE)` because it not just resets
#    the cache and unsets the original variable. Additionally to previously
#    mentioned behaviour it overrides a value passed by the `-D` cmake command
#    line parameter!
# 3. Be careful with the usual `set(<var> <value>)` when the cache value has
#    been already exist, because it actually does not change the cache value but
#    changes state of the ${<var>} value. In another words if you try later to
#    unset the original variable by the `unset(<var>)` then the cached value
#    would be revealed and might be different than after the very first set!
#

include(ForwardVariables)

macro(include_and_echo path)
  message(STATUS "(*) Include: \"${path}\"")
  include(${path})
endmacro()

macro(unset_all var)
  unset(${var})
  unset(${var} CACHE)
endmacro()

# returns "." if paths are equal
function(subtract_absolute_paths from_path to_path var_out)
  string(TOLOWER "${from_path}" from_path_lower)
  string(TOLOWER "${to_path}" to_path_lower)

  if (NOT from_path_lower STREQUAL "")
    if (${to_path_lower} STREQUAL ${from_path_lower})
      set(${var_out} "." PARENT_SCOPE)
      return()
    else()
      file(RELATIVE_PATH rel_path ${to_path_lower} ${from_path_lower})
      if (DEFINED rel_path)
        string(SUBSTRING "${rel_path}" 0 2 rel_path_first_component)
        if(NOT rel_path_first_component STREQUAL ".." AND NOT rel_path STREQUAL from_path_lower)
          set(${var_out} ${rel_path} PARENT_SCOPE)
          return()
        endif()
      endif()
    endif()
  endif()

  set(${var_out} "" PARENT_SCOPE)
endfunction()

function(make_list_from_vargs var_out)
  unset_all(${var_out})
  foreach(arg IN LISTS ARGN)
    list(APPEND ${var_out} ${arg})
  endforeach()
  set(${var_out} ${${var_out}} PARENT_SCOPE)
endfunction()

function(make_list_from_cmd_line var_out cmd_line)
  set(new_list "")
  set(cmd_line_list ${cmd_line})
  separate_arguments(cmd_line_list)
  foreach(arg IN LISTS cmd_line_list) # semicolon separated list in string
    list(APPEND new_list ${arg})
  endforeach()
  set(${var_out} ${new_list} PARENT_SCOPE)
endfunction()

function(make_string_from_list var_out list_value)
  set(new_str "")
  foreach(arg IN LISTS list_value)
    if(new_str)
      set(new_str "${new_str}\;${arg}")
    else()
      set(new_str "${arg}")
    endif()
  endforeach()
  set(${var_out} "${new_str}" PARENT_SCOPE)
endfunction()

function(make_string_from_list_var var_out list_var)
  set(new_str "")
  foreach(arg IN LISTS ${list_var})
    if(new_str)
      set(new_str "${new_str}\;${arg}")
    else()
      set(new_str "${arg}")
    endif()
  endforeach()
  set(${var_out} "${new_str}" PARENT_SCOPE)
endfunction()

function(cache_or_discover_variable var cache_type desc)
  if(NOT DEFINED ${var} AND DEFINED ENV{${var}})
    set(${var} $ENV{${var}} CACHE ${cache_type} ${desc}) # before the normal set, overwise it will remove the normal variable!
    set(${var} $ENV{${var}} PARENT_SCOPE)
  endif()
endfunction()

function(discover_variable_to flag_var var_out var_name cache_type desc)
  if(NOT var_out OR NOT var_name)
    message(FATAL_ERROR "var_out and var_name variables must be not empty: var_out=\"${var_out}\" var_name=\"${var_name}\"")
  endif()

  get_variable(uncached_var cached_var ${var_name})

  if(NOT DEFINED uncached_var)
    if(DEFINED ENV{${var_name}})
      # always force reset from environment
      set(${var_out} $ENV{${var_name}} CACHE ${cache_type} ${desc} FORCE) # before the normal set, overwise it will remove the normal variable!
      set(${var_out} $ENV{${var_name}} PARENT_SCOPE)
      set(${flag_var} 1 PARENT_SCOPE)
    else()
      set(${flag_var} 0 PARENT_SCOPE)
    endif()
  elseif(DEFINED ENV{${var_name}})
    # if no cache then make cache from the normal value, always force reset from environment
    set(${var_out} $ENV{${var_name}} CACHE ${cache_type} ${desc} FORCE) # before the normal set, overwise it will remove the normal variable!
    # restore uncached variable removed by previous set with CACHE (ONLY in case if was no cache before)
    if (uncached_var)
      set(${var_out} ${uncached_var} PARENT_SCOPE)
    else()
      unset(${var_out} PARENT_SCOPE)
    endif()
    set(${flag_var} 2 PARENT_SCOPE)
  else()
    # if no cache then make cache from the normal value
    if (cached_var)
      set(${var_out} ${cached_var} CACHE ${cache_type} ${desc})
    else()
      unset(${var_out} CACHE)
    endif()
    # restore uncached variable removed by previous set with CACHE (ONLY in case if was no cache before)
    if (uncached_var)
      set(${var_out} ${uncached_var} PARENT_SCOPE)
    else()
      unset(${var_out} PARENT_SCOPE)
    endif()
    set(${flag_var} 0 PARENT_SCOPE)
  endif()
endfunction()

function(discover_variable var_name cache_type desc)
  discover_variable_to(is_discovered ${var_name} ${var_name} ${cache_type} ${desc})
  if(is_discovered)
    message(STATUS "(*) discovered environment variable: ${var_name}=\"${${var_name}}\"")
  endif()
endfunction()

function(discover_builtin_variables prefix_list cache_type desc)
  if(ARGN)
    foreach(prefix IN LISTS prefix_list)
      foreach(suffix IN LISTS ARGN)
        set(var ${prefix}_${suffix})
        discover_variable_to(is_discovered new_${var} ${var} ${cache_type} ${desc})
        if(${var})
          # append if was not empty
          set(${var} "${${var}} ${new_${var}}")
        else()
          set(${var} "${new_${var}}")
        endif()
        set(${var} "${${var}}" PARENT_SCOPE)
        #unset_all(new_${var})
        if(is_discovered)
          message(STATUS "(*) discovered environment variable: (builtin) ${var}=\"${${var}}\"")
        endif()
      endforeach()
    endforeach()
  else()
    foreach(prefix IN LISTS prefix_list)
      set(var ${prefix})
      discover_variable_to(is_discovered new_${var} ${var} ${cache_type} ${desc})
      if(${var})
        # append if was not empty
        set(${var} "${${var}} ${new_${var}}")
      else()
        set(${var} "${new_${var}}")
      endif()
      set(${var} "${${var}}" PARENT_SCOPE)
      #unset_all(new_${var})
      if(is_discovered)
        message(STATUS "(*) discovered environment variable: (builtin) ${var}=\"${${var}}\"")
      endif()
    endforeach()
  endif()
endfunction()

macro(declare_builtin_variables)
  # include guard
  if (NOT DEFINED BUILDIN_VARIABLES_DECLARED)
    set(BUILDIN_VARIABLES_DECLARED 1)

    message(STATUS "(*) CMAKE_VERSION=${CMAKE_VERSION}")
    message(STATUS "(*) CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}")
    message(STATUS "(*) OSTYPE=$ENV{OSTYPE} CMAKE_C_COMPILER_ID=${CMAKE_C_COMPILER_ID} CMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}")

    # check if generator is multiconfig
    get_property(GENERATOR_IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
    message(STATUS "(*) GENERATOR_IS_MULTI_CONFIG=${GENERATOR_IS_MULTI_CONFIG} CMAKE_CONFIGURATION_TYPES=${CMAKE_CONFIGURATION_TYPES}")

    # declare some variables
    if("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU" OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
      set(GCC 1)
    endif()

    if(GENERATOR_IS_MULTI_CONFIG)
      set(CMAKE_DEFAULT_CONFIGURATION_TYPES ${CMAKE_CONFIGURATION_TYPES})
    else()
      set(CMAKE_DEFAULT_CONFIGURATION_TYPES Debug;Release;MinSizeRel;RelWithDebInfo)
    endif()

    set(CMAKE_NOTPRINTABLE_MATCH_CHARS " \t")
    set(CMAKE_NOTFLAG_MATCH_CHARS "${CMAKE_NOTPRINTABLE_REGEX_CHARS}\"")
    set(CMAKE_QUOTABLE_MATCH_CHARS ";,${CMAKE_NOTPRINTABLE_REGEX_CHARS}")

    set(CMAKE_NOTPRINTABLE_REGEX_CHARS " \\t")
    set(CMAKE_NOTFLAG_REGEX_CHARS "${CMAKE_NOTPRINTABLE_REGEX_CHARS}\"")
    set(CMAKE_QUOTABLE_REGEX_CHARS ";,${CMAKE_NOTPRINTABLE_REGEX_CHARS}")
  endif()
endmacro()

function(generate_regex_replace_expression out_regex_match_var out_regex_replace_var in_regex_match_var in_replace_to)
  if(${in_regex_match_var} MATCHES "[^\\\\]\\(|^\\(" OR "${in_replace_to}" MATCHES "\\\\0|\\\\1|\\\\2|\\\\3|\\\\4|\\\\5|\\\\6|\\\\7|\\\\8|\\\\9")
    message(FATAL_ERROR "generate_regex_replace_expression: input regex match expression does not support groups capture: in_regex_match_var=${${in_regex_match_var}} in_replace_to=${in_replace_to}")
  endif()

  string(REGEX REPLACE "\\\\" "\\\\" in_replace_to_escaped "${in_replace_to}")
  set(${out_regex_match_var} "([${CMAKE_NOTFLAG_REGEX_CHARS}]*)${${in_regex_match_var}}([${CMAKE_NOTFLAG_REGEX_CHARS}]*)" PARENT_SCOPE)
  set(${out_regex_replace_var} "\\1${in_replace_to_escaped}\\2" PARENT_SCOPE)
endfunction()

macro(configure_environment supported_compilers)
  # basic checks, must be executed each time
  declare_builtin_variables()

  set(has_supported_compiler 0)
  foreach(compiler ${supported_compilers})
    if(${compiler})
      set(has_supported_compiler 1)
    endif()
  endforeach()

  if(NOT has_supported_compiler)
    message(FATAL_ERROR "platform is not implemented, supported compilers: ${supported_compilers}")
  endif()

  discover_variable(MSYS STRING "msys environment flag")
  discover_variable(MINGW STRING "mingw environment flag")
  discover_variable(CYGWIN STRING "cygwin environment flag")

  # detection of msys/mingw/cygwin environments
  if ("$ENV{OSTYPE}" STREQUAL "msys")
    set(MSYS ON)
    set(MINGW ON)
  elseif ("$ENV{OSTYPE}" STREQUAL "mingw")
    set(MINGW ON)
  elseif ("$ENV{OSTYPE}" STREQUAL "cygwin")
    set(CYGWIN ON)
  endif()

  if(NOT GENERATOR_IS_MULTI_CONFIG AND NOT CMAKE_BUILD_TYPE)
    message(FATAL_ERROR "CMAKE_BUILD_TYPE variable must be set explicitly under not multiconfig cmake generator!")
  endif()

  if (NOT DEFINED CONFIGURE_ENVIRONMENT_EXECUTED)
    set(CONFIGURE_ENVIRONMENT_EXECUTED 1)

    # discover base set of shell variables
    discover_variable(CMAKE_OUTPUT_ROOT   PATH "cmake output directory root")
    discover_variable(CMAKE_BUILD_ROOT    PATH "cmake build output directory root")
    discover_variable(CMAKE_BIN_ROOT      PATH "cmake binaries output directory root")
    discover_variable(CMAKE_LIB_ROOT      PATH "cmake libraries output directory root")
    discover_variable(CMAKE_INSTALL_ROOT  PATH "cmake install output directory root")
    discover_variable(CMAKE_CPACK_ROOT    PATH "cmake cpack/bundle output directory root")

    if (DEFINED CMAKE_CACHEFILE_DIR)
      string(TOLOWER "${CMAKE_CACHEFILE_DIR}" cmake_cachefile_dir_lower)
      string(TOLOWER "${CMAKE_BUILD_ROOT}" cmake_build_root_lower)
      if (NOT cmake_cachefile_dir_lower STREQUAL cmake_build_root_lower)
        message(FATAL_ERROR "Cmake cache file directory is not the cmake build root directory which might means cmake was previous configured out of the build directory. To continue do remove the external cache file:\n CMAKE_BUILD_ROOT=\"${CMAKE_BUILD_ROOT}\"\n CMAKE_CACHEFILE_DIR=\"${CMAKE_CACHEFILE_DIR}\"")
      endif()
      unset(cmake_cachefile_dir_lower)
      unset(cmake_build_root_lower)
    endif()

    discover_variable(CMAKE_RUNTIME_OUTPUT_DIRECTORY  PATH "cmake builtin variable runtime output directory")
    discover_variable(CMAKE_LIBRARY_OUTPUT_DIRECTORY  PATH "cmake builtin variable libraries output directory")
    discover_variable(CMAKE_INSTALL_PREFIX            PATH "cmake builtin variable install prefix")
    discover_variable(CPACK_OUTPUT_FILE_PREFIX        PATH "cmake cpack builtin variable output directory")

    discover_variable(PROJECT_ROOT        PATH "project with sources directory root")

    # set special variables to default if is empty
    if(NOT CMAKE_OUTPUT_ROOT)
      set(CMAKE_OUTPUT_ROOT ${CMAKE_CURRENT_LIST_DIR}/_out)
    endif()
    if(NOT CMAKE_BUILD_ROOT)
      set(CMAKE_BUILD_ROOT ${CMAKE_OUTPUT_ROOT}/build)
    endif()
    if(NOT CMAKE_BIN_ROOT)
      set(CMAKE_BIN_ROOT ${CMAKE_OUTPUT_ROOT}/bin)
    endif()
    if(NOT CMAKE_LIB_ROOT)
      set(CMAKE_LIB_ROOT ${CMAKE_OUTPUT_ROOT}/lib)
    endif()
    if(NOT CMAKE_INSTALL_ROOT)
      set(CMAKE_INSTALL_ROOT ${CMAKE_OUTPUT_ROOT}/install)
    endif()
    if(NOT CMAKE_CPACK_ROOT)
      set(CMAKE_CPACK_ROOT ${CMAKE_OUTPUT_ROOT}/pack)
    endif()

    if(NOT PROJECT_ROOT)
      set(PROJECT_ROOT ${CMAKE_CURRENT_LIST_DIR})
    endif()

    if(GENERATOR_IS_MULTI_CONFIG)
      if (NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BIN_ROOT})
      endif()
      if (NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
        set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIB_ROOT})
      endif()

      if (NOT CPACK_OUTPUT_FILE_PREFIX)
        set(CPACK_OUTPUT_FILE_PREFIX ${CMAKE_CPACK_ROOT})
      endif()
    else()
      set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BIN_ROOT})
      set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIB_ROOT})

      set(CPACK_OUTPUT_FILE_PREFIX ${CMAKE_CPACK_ROOT})
    endif()

    set(CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_ROOT}) # cmake creates the build type subdirectory on itself

    # CAUTION:
    #   We have to detect the executor to check if the `environment_local.cmake`
    #   has to be already generated. If not we must stop immediately and warn the
    #   user to run the `_script/configure_nogen` BEFORE cmake direct execution by
    #   the IDE!

    detect_qt_creator()
    if (IS_EXECUTED_BY_QT_CREATOR)
      if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/environment_local.cmake)
        message(FATAL_ERROR "(*) The `environment_local.cmake` is not properly generated, use the `_scripts/configure_nogen` to generage the file and then edit values manually!")
      endif()
    endif()

    # Always reconfigure `environment_config.cmake` for not multiconfig cmake generator.
    # The `environment_config.cmake.in` must always exist.
    if (GENERATOR_IS_MULTI_CONFIG)
      configure_file_if_not_exist_and_include(${CMAKE_CURRENT_LIST_DIR}/environment_config.cmake.in ${CMAKE_CURRENT_LIST_DIR}/environment_config.cmake)
    else()
      reconfigure_file_and_include(${CMAKE_CURRENT_LIST_DIR}/environment_config.cmake.in ${CMAKE_CURRENT_LIST_DIR}/environment_config.cmake)
    endif()

    # generates `environment_local.cmake` from the `environment_local.cmake.in` if not done yet and includes it unconditionally
    if (EXISTS ${CMAKE_CURRENT_LIST_DIR}/environment_local.cmake.in)
      configure_file_if_not_exist_and_include(${CMAKE_CURRENT_LIST_DIR}/environment_local.cmake.in ${CMAKE_CURRENT_LIST_DIR}/environment_local.cmake)
    endif()

    # CAUTION:
    #   IDE like QtCreator uses `CMakeLists.txt.user` file to store and load cached
    #   versions of cmake environment variables. But it's change in cmake may won't
    #   promote respective change to IDE. To make it changed you have to CLOSE IDE
    #   AND DELETE FILE WITH CACHED VARIABLES - `CMakeLists.txt.user`!

    discover_variable(ENV_ROOT PATH "environment root directory")
    discover_variable(ENV_FILENAME STRING "environment file name")

    # searches `environment.cmake` and includes it, basically this environment contains global environment additional to the local environment
    include(FindEnvironment)

    # in case of intersection reinclude the local environment
    if(EXISTS "${ENV_FILE}") # included
      if (NOT CMAKE_BUILD_TYPE)
        if (EXISTS ${CMAKE_CURRENT_LIST_DIR}/environment_config.cmake)
          include_and_echo(${CMAKE_CURRENT_LIST_DIR}/environment_config.cmake)
        endif()
      else()
        include_and_echo(${CMAKE_CURRENT_LIST_DIR}/environment_config.cmake)
      endif()

      if (EXISTS ${CMAKE_CURRENT_LIST_DIR}/environment_local.cmake)
        include_and_echo(${CMAKE_CURRENT_LIST_DIR}/environment_local.cmake)
      endif()
    endif()

    # base set variables discovery
    discover_variable(CMAKE_CONFIG_TYPES STRING "cmake externally declared configuration types")
    if (CMAKE_CONFIG_TYPES)
      # reset type to the list
      make_list_from_cmd_line(CMAKE_CONFIG_TYPES "${CMAKE_CONFIG_TYPES}")
      make_string_from_list_var(CMAKE_CONFIG_TYPES CMAKE_CONFIG_TYPES)
      # override CMAKE_CONFIGURATION_TYPES
      set(CMAKE_CONFIGURATION_TYPES ${CMAKE_CONFIG_TYPES})
      string(TOUPPER "${CMAKE_CONFIG_TYPES}" CMAKE_CONFIG_TYPES)
      message(STATUS "(*) variable update: CMAKE_CONFIGURATION_TYPES=${CMAKE_CONFIGURATION_TYPES}")
    else()
      make_list_from_cmd_line(CMAKE_CONFIG_TYPES "${CMAKE_CONFIGURATION_TYPES}")
      string(TOUPPER "${CMAKE_CONFIG_TYPES}" CMAKE_CONFIG_TYPES)
      message(STATUS "(*) variable update: CMAKE_CONFIG_TYPES=${CMAKE_CONFIG_TYPES}")
    endif()

    discover_builtin_variables(CMAKE_CXX_FLAGS STRING "cmake compilation flags")
    discover_builtin_variables(CMAKE_EXE_LINKER_FLAGS STRING "cmake exe linker flags")
    discover_builtin_variables(CMAKE_MODULE_LINKER_FLAGS STRING "cmake module linker flags")
    discover_builtin_variables(CMAKE_STATIC_LINKER_FLAGS STRING "cmake static linker flags")
    discover_builtin_variables(CMAKE_SHARED_LINKER_FLAGS STRING "cmake shared linker flags")

    # all other variables generated by `CMAKE_CONFIG_TYPES` suffix
    discover_builtin_variables("CMAKE_CXX_FLAGS;CMAKE_EXE_LINKER_FLAGS;CMAKE_MODULE_LINKER_FLAGS;CMAKE_STATIC_LINKER_FLAGS;CMAKE_SHARED_LINKER_FLAGS"
        STRING "cmake flags related to a configuration" ${CMAKE_CONFIG_TYPES})
  endif()
endmacro()

function(configure_file_and_include_impl tmpl_file_path out_file_path do_recofigure)
  if(NOT EXISTS ${tmpl_file_path})
    message(FATAL_ERROR "template input file does not exist: \"${tmpl_file_path}\"")
  endif()

  get_filename_component(out_file_dir ${out_file_path} DIRECTORY)
  if(NOT EXISTS ${out_file_dir})
    message(FATAL_ERROR "output file directory does not exist: \"${out_file_dir}\"")
  endif()

  # override current environment variables by locally stored
  if(do_recofigure OR NOT EXISTS "${out_file_path}")
    message(STATUS "(*) Generating file: \"${tmpl_file_path}\" -> \"${out_file_path}\"")
    set(CONFIGURE_IN_FILE "${tmpl_file_path}")
    set(CONFIGURE_OUT_FILE "${out_file_path}")
    include(ConfigureFile)
  endif()

  include_and_echo("${out_file_path}")
endfunction()

function(configure_file_if_not_exist_and_include tmpl_file_path out_file_path)
  configure_file_and_include_impl(${tmpl_file_path} ${out_file_path} 0)
endfunction()

function(reconfigure_file_and_include tmpl_file_path out_file_path)
  configure_file_and_include_impl(${tmpl_file_path} ${out_file_path} 1)
endfunction()

function(exclude_paths_from_path_list exclude_list_var include_list_var path_list exclude_path_list verbose_flag)
  if(verbose_flag)
    message(STATUS "(**) exclude_paths_from_path_list: exclude list: ${exclude_path_list}")
  endif()

  if(NOT include_list_var STREQUAL "" AND NOT include_list_var STREQUAL ".")
    set(include_list_var_defined 1)
  endif()
  if(NOT exclude_list_var STREQUAL "" AND NOT exclude_list_var STREQUAL ".")
    set(exclude_list_var_defined 1)
  endif()

  if(NOT include_list_var_defined AND NOT exclude_list_var_defined)
    message(FATAL_ERROR "at least one output list variable must be defined")
  endif()

  set(include_list "")
  set(exclude_list "")

  foreach(path IN LISTS path_list)
    set(_excluded 0)
    foreach(exclude_path IN LISTS exclude_path_list)
      if("${path}" MATCHES "(.*)${exclude_path}(.*)")
        if(verbose_flag)
          message(STATUS "(**) exclude_paths_from_path_list: excluded: ${path}")
        endif()
        set(_excluded 1)
        break()
      endif()
    endforeach()
    if(NOT _excluded)
      list(APPEND include_list "${path}")
    else()
      list(APPEND exclude_list "${path}")
    endif()
  endforeach()

  if(verbose_flag)
    message(STATUS "(**) exclude_paths_from_path_list: include list: ${include_list}")
  endif()

  if (include_list_var_defined)
    set(${include_list_var} ${include_list} PARENT_SCOPE)
  endif()
  if (exclude_list_var_defined)
    set(${exclude_list_var} ${exclude_list} PARENT_SCOPE)
  endif()
endfunction()

function(exclude_file_paths_from_path_list exclude_list_var include_list_var path_list exclude_file_path_list verbose_flag)
  if(verbose_flag)
    message(STATUS "(**) exclude_file_paths_from_path_list: exclude list: ${exclude_file_path_list}")
  endif()

  if(NOT include_list_var STREQUAL "" AND NOT include_list_var STREQUAL ".")
    set(include_list_var_defined 1)
  endif()
  if(NOT exclude_list_var STREQUAL "" AND NOT exclude_list_var STREQUAL ".")
    set(exclude_list_var_defined 1)
  endif()

  if(NOT include_list_var_defined AND NOT exclude_list_var_defined)
    message(FATAL_ERROR "at least one output list variable must be defined")
  endif()

  set(include_list "")
  set(exclude_list "")

  foreach(path IN LISTS path_list)
    set(_excluded 0)
    foreach(exclude_file_path IN LISTS exclude_file_path_list)
      if("${path}|" MATCHES "(.*)${exclude_file_path}\\|")
        if(verbose_flag)
          message(STATUS "(**) exclude_file_paths_from_path_list: excluded: ${path}")
        endif()
        set(_excluded 1)
        break()
      endif()
    endforeach()
    if(NOT _excluded)
      list(APPEND include_list "${path}")
    else()
      list(APPEND exclude_list "${path}")
    endif()
  endforeach()

  if(verbose_flag)
    message(STATUS "(**) exclude_file_paths_from_path_list: include list: ${include_list}")
  endif()

  if (include_list_var_defined)
    set(${include_list_var} ${include_list} PARENT_SCOPE)
  endif()
  if (exclude_list_var_defined)
    set(${exclude_list_var} ${exclude_list} PARENT_SCOPE)
  endif()
endfunction()

function(include_paths_from_path_list include_list_var path_list include_path_list verbose_flag)
  if(verbose_flag)
    message(STATUS "(**) include_paths_from_path_list: include list: ${include_path_list}")
  endif()

  set(include_list "")

  foreach(path IN LISTS path_list)
    foreach(include_path IN LISTS include_path_list)
      if("${path}" MATCHES "(.*)${include_path}(.*)")
        if(verbose_flag)
          message(STATUS "(**) include_paths_from_path_list: included: ${path}")
        endif()
        list(APPEND include_list "${path}")
      endif()
    endforeach()
  endforeach()

  set(${include_list_var} ${include_list} PARENT_SCOPE)
endfunction()

function(include_file_paths_from_path_list include_list_var path_list include_file_path_list verbose_flag)
  if(verbose_flag)
    message(STATUS "(**) include_file_paths_from_path_list: include list: ${include_file_path_list}")
  endif()

  set(include_list "")

  foreach(path IN LISTS path_list)
    foreach(include_file_path IN LISTS include_file_path_list)
      if("${path}|" MATCHES "(.*)${include_file_path}\\|")
        if(verbose_flag)
          message(STATUS "(**) include_file_paths_from_path_list: included: ${path}")
        endif()
        list(APPEND include_list "${path}")
      endif()
    endforeach()
  endforeach()

  set(${include_list_var} ${include_list} PARENT_SCOPE)
endfunction()

function(source_group_by_path_list group_path type path_list include_path_list verbose_flag)
  set(include_list "")

  foreach(path IN LISTS path_list)
    foreach(include_path IN LISTS include_path_list)
      if("${path}" MATCHES "(.*)${include_path}(.*)")
        if(verbose_flag)
          message(STATUS "(**) source_group_from_include_list: ${group_path} -> (${type}) \"${path}\"")
        endif()
        list(APPEND include_list ${path})
      endif()
    endforeach()
  endforeach()

  if(include_list)
    source_group("${group_path}" ${type} ${include_list})
  endif()
endfunction()

function(source_group_by_file_path_list group_path type path_list include_file_path_list verbose_flag)
  set(include_list "")

  foreach(path IN LISTS path_list)
    foreach(include_file_path IN LISTS include_file_path_list)
      if("${path}|" MATCHES "(.*)${include_file_path}\\|")
        if(verbose_flag)
          message(STATUS "(**) source_group_from_include_list: ${group_path} -> (${type}) \"${path}\"")
        endif()
        list(APPEND include_list ${path})
      endif()
    endforeach()
  endforeach()

  if(include_list)
    source_group("${group_path}" ${type} ${include_list})
  endif()
endfunction()

function(source_groups_from_dir_list source_group_root type path_dir_list path_glob_suffix)
  string(REGEX REPLACE "/" "\\\\" source_group_root "${source_group_root}")

  foreach(path_dir IN LISTS path_dir_list)
    #message(STATUS path_dir=${path_dir})
    if(NOT EXISTS ${path_dir}/)
      continue()
    endif()

    file(GLOB_RECURSE children_list RELATIVE ${path_dir} "${path_dir}/${path_glob_suffix}")

    set(group_path_dir_list "")

    get_filename_component(abs_path_dir ${path_dir} ABSOLUTE)

    foreach(child_path IN LISTS children_list)
      get_filename_component(abs_child_path ${path_dir}/${child_path} ABSOLUTE)

      file(RELATIVE_PATH child_rel_path ${abs_path_dir} ${abs_child_path})
      if(child_rel_path)
        get_filename_component(child_rel_dir ${child_rel_path} DIRECTORY)

        string(REGEX REPLACE "/" "\\\\" source_group_dir "${child_rel_dir}")
        if(source_group_root)
          #message(STATUS "source_groups_from_dir_list: ${source_group_root}\\${source_group_dir} -> ${child_rel_path}")
          source_group("${source_group_root}\\${source_group_dir}" ${type} "${path_dir}/${child_path}")
        else()
          #message(STATUS "source_groups_from_dir_list: ${source_group_dir} -> ${child_rel_path}")
          source_group("${source_group_dir}" ${type} "${path_dir}/${child_path}")
        endif()
      endif()
    endforeach()
  endforeach()
endfunction()

function(declare_target_builtin_properties target)
  # ignore all aliases because of read only
  get_target_property(target_origin ${target} ALIASED_TARGET)
  if (target_origin)
    return()
  endif()

  get_target_property(target_type ${target} TYPE)

  # avoid error: INTERFACE_LIBRARY targets may only have whitelisted properties.
  if(NOT target_type STREQUAL "INTERFACE_LIBRARY")
    set_property(GLOBAL APPEND PROPERTY GlobalTargetList ${target})

    get_property(is_global_CMAKE_CURRENT_PACKAGE_NAME_set GLOBAL PROPERTY CMAKE_CURRENT_PACKAGE_NAME SET)
    get_property(is_global_CMAKE_CURRENT_PACKAGE_SOURCE_DIR_set GLOBAL PROPERTY CMAKE_CURRENT_PACKAGE_SOURCE_DIR SET)
    get_property(is_target_PACKAGE_SOURCE_DIR_set TARGET ${target} PROPERTY PACKAGE_SOURCE_DIR SET)

    # back compatability, just in case
    get_property(is_target_property_SOURCE_DIR_set TARGET ${target} PROPERTY SOURCE_DIR SET)
    if (NOT is_target_property_SOURCE_DIR_set)
      set_target_properties(${target} PROPERTIES SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    if (is_global_CMAKE_CURRENT_PACKAGE_NAME_set)
      get_property(global_CMAKE_CURRENT_PACKAGE_NAME GLOBAL PROPERTY CMAKE_CURRENT_PACKAGE_NAME)
      set_target_properties(${target} PROPERTIES PACKAGE_NAME "${global_CMAKE_CURRENT_PACKAGE_NAME}")
    else()
      set_target_properties(${target} PROPERTIES PACKAGE_NAME "${PROJECT_NAME}")
    endif()

    if (is_global_CMAKE_CURRENT_PACKAGE_SOURCE_DIR_set)
      get_property(global_CMAKE_CURRENT_PACKAGE_SOURCE_DIR GLOBAL PROPERTY CMAKE_CURRENT_PACKAGE_SOURCE_DIR)
      set_target_properties(${target} PROPERTIES PACKAGE_SOURCE_DIR "${global_CMAKE_CURRENT_PACKAGE_SOURCE_DIR}")
    else()
      # cmake list directory instead, but that is still not a package directory!
      set_target_properties(${target} PROPERTIES PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}")
    endif()

    # in case if cmake list directory would require too
    get_property(is_target_property_LIST_DIR_set TARGET ${target} PROPERTY LIST_DIR SET)
    if (NOT is_target_property_LIST_DIR_set)
      set_target_properties(${target} PROPERTIES LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")
    endif()
  endif()
endfunction()

function(get_target_alias_from_command_line target_alias_var)
  # search for ALIAS name
  set(target_alias "")
  set(arg_index 0)
  set(arg_alias_index -1)
  foreach(arg IN LISTS ARGN)
    if(arg_alias_index EQUAL -1)
      if(arg STREQUAL "ALIAS")
        set(arg_alias_index ${arg_index})
      endif()
    else()
      set(${target_alias_var} ${arg} PARENT_SCOPE)
      return()
    endif()

    math(EXPR arg_index "${arg_index}+1")
  endforeach()

  set(${target_alias_var} "" PARENT_SCOPE)
endfunction()

function(add_library_begin target)
  get_target_alias_from_command_line(target_alias ${ARGN})
  add_library_target_begin_message(${target} "${target_alias}" ${ARGN})
endfunction()

function(add_library_end target)
  register_target(${target})
endfunction()

function(add_library_target_begin_message target target_alias)
  get_property(current_package_name GLOBAL PROPERTY CMAKE_CURRENT_PACKAGE_NAME)

  if (NOT target_alias)
    message("adding library target: ${current_package_name}//${target}...")
  else()
    message("adding library target: ${current_package_name}//${target} -> ${target_alias}...")
  endif()
endfunction()

function(add_executable_begin target)
  get_target_alias_from_command_line(target_alias ${ARGN})
  add_executable_target_begin_message(${target} "${target_alias}" ${ARGN})
endfunction()

function(add_executable_end target)
  register_target(${target})
endfunction()

function(add_executable_target_begin_message target target_alias)
  get_property(current_package_name GLOBAL PROPERTY CMAKE_CURRENT_PACKAGE_NAME)

  if (NOT target_alias)
    message("adding executable target: ${current_package_name}//${target}...")
  else()
    message("adding executable target: ${current_package_name}//${target} -> ${target_alias}...")
  endif()
endfunction()

function(add_custom_target_begin target)
  get_target_alias_from_command_line(target_alias ${ARGN})
  add_custom_target_begin_message(${target} "${target_alias}" ${ARGN})
endfunction()

function(add_custom_target_end target)
  register_target(${target})
endfunction()

function(add_custom_target_begin_message target target_alias)
  get_property(current_package_name GLOBAL PROPERTY CMAKE_CURRENT_PACKAGE_NAME)

  if (NOT target_alias)
    message("adding custom target: ${current_package_name}//${target}...")
  else()
    message("adding custom target: ${current_package_name}//${target} -> ${target_alias}...")
  endif()
endfunction()

function(register_target target)
  declare_target_builtin_properties(${target})
endfunction()

function(unregister_directory_scope_targets)
  get_global_targets_list(targets_list)

  if (NOT targets_list)
    return()
  endif()

  set(targets_to_remove "")

  foreach(target IN LISTS targets_list)
    get_target_property(is_target_imported ${target} IMPORTED)
    get_target_property(is_target_imported_global ${target} IMPORTED_GLOBAL)
    if (is_target_imported AND NOT is_target_imported_global)
      list(APPEND targets_to_remove ${target})
    endif()
  endforeach()

  if (targets_to_remove)
    list(REMOVE_ITEM targets_list ${targets_to_remove})
  endif()

  set_global_targets_list(${targets_list})
endfunction()

function(add_subdirectory_begin target_src_dir)
  add_subdirectory_begin_message(${target_src_dir} ${ARGN})
  get_filename_component(target_src_dir_abs ${target_src_dir} ABSOLUTE)
  pushset_property_to_stack(GLOBAL CMAKE_CURRENT_PACKAGE_SOURCE_DIR ${target_src_dir_abs})
endfunction()

function(add_subdirectory_end target_src_dir)
  popset_property_from_stack(. GLOBAL CMAKE_CURRENT_PACKAGE_SOURCE_DIR)
  unregister_directory_scope_targets()
  add_subdirectory_end_message(${target_src_dir} ${ARGN})
endfunction()

macro(add_subdirectory_prepare_message)
  set(target_bin_dir "")
  set(arg_index 0)
  foreach(arg IN LISTS ARGN)
    if(arg_index EQUAL 0)
      if(NOT arg STREQUAL "EXCLUDE_FROM_ALL")
        set(target_bin_dir ${arg})
      endif()
    endif()
    math(EXPR arg_index "${arg_index}+1")
  endforeach()

  # get relative path to the source/binary directory from cmake top level directory - PROJECT_SOURCE_DIR
  get_filename_component(target_src_dir_abs ${target_src_dir} ABSOLUTE)
  #message(PROJECT_SOURCE_DIR=${PROJECT_SOURCE_DIR})
  #message(target_src_dir_abs=${target_src_dir_abs})
  file(RELATIVE_PATH target_src_dir_path ${PROJECT_SOURCE_DIR} ${target_src_dir_abs})
  if(target_src_dir_path STREQUAL "." OR target_src_dir_path STREQUAL "")
    set(target_src_dir_path ${target_src_dir})
  endif()

  set(target_bin_dir_msg_line "")
  if(target_bin_dir)
    get_filename_component(target_bin_dir_abs ${target_bin_dir} ABSOLUTE)
    file(RELATIVE_PATH target_bin_dir_path ${PROJECT_SOURCE_DIR} ${target_bin_dir_abs})
    if(target_bin_dir_path STREQUAL "." OR target_src_dir_path STREQUAL "")
      set(target_bin_dir_path "${target_bin_dir}")
    endif()

    set(target_bin_dir_msg_line " bin=\"${target_bin_dir_path}\"")
  endif()
endmacro()

function(add_subdirectory_begin_message target_src_dir)
  add_subdirectory_prepare_message(${ARGV})
  get_property(current_package_name GLOBAL PROPERTY CMAKE_CURRENT_PACKAGE_NAME)
  message("entering subdirectory: ${current_package_name}//\"${target_src_dir_path}\"${target_bin_dir_msg_line}...")
endfunction()

function(add_subdirectory_end_message target_src_dir)
  add_subdirectory_prepare_message(${ARGV})
  get_property(current_package_name GLOBAL PROPERTY CMAKE_CURRENT_PACKAGE_NAME)
  message("leaving subdirectory: ${current_package_name}//\"${target_src_dir_path}\"${target_bin_dir_msg_line}")
endfunction()

function(find_package_begin package_src_dir_var package)
  find_package_begin_message(${package_src_dir_var} ${package} ${ARGN})
  pushset_property_to_stack(GLOBAL CMAKE_CURRENT_PACKAGE_NAME ${package})
  if (NOT package_src_dir_var STREQUAL "" AND NOT package_src_dir_var STREQUAL ".")
    pushset_property_to_stack(GLOBAL CMAKE_CURRENT_PACKAGE_SOURCE_DIR ${${package_src_dir_var}})
  else()
    pushunset_property_to_stack(GLOBAL CMAKE_CURRENT_PACKAGE_SOURCE_DIR)
  endif()
endfunction()

function(find_package_end package_src_dir_var package)
  popset_property_from_stack(. GLOBAL CMAKE_CURRENT_PACKAGE_NAME)
  popset_property_from_stack(. GLOBAL CMAKE_CURRENT_PACKAGE_SOURCE_DIR)
  unregister_directory_scope_targets()
  find_package_end_message(${package_src_dir_var} ${package} ${ARGN})
endfunction()

function(find_package_begin_message package_src_dir_var package)
  if (NOT package_src_dir_var STREQUAL "" AND NOT package_src_dir_var STREQUAL ".")
    message("entering package: ${package}: ${package_src_dir_var}=\"${${package_src_dir_var}}\"...")
  else()
    message("entering package: ${package}...")
  endif()
endfunction()

function(find_package_end_message package_src_dir_var package)
  if (NOT package_src_dir_var STREQUAL "" AND NOT package_src_dir_var STREQUAL ".")
    message("leaving package: ${package}: ${package_src_dir_var}=\"${${package_src_dir_var}}\"")
  else()
    message("leaving package: ${package}")
  endif()
endfunction()

function(add_pch_header create_pch_header from_pch_src to_pch_bin use_pch_header include_pch_header sources sources_out_var)
  # MSVC arguments can be mixed, canonicalize all
  set(create_pch_header_fixed ${create_pch_header})
  set(from_pch_src_fixed ${from_pch_src})
  set(to_pch_bin_fixed ${to_pch_bin})
  set(use_pch_header_fixed ${use_pch_header})
  set(include_pch_header_fixed ${include_pch_header})
  set(sources_fixed "")

  string(REPLACE "\\" "/" create_pch_header_fixed ${create_pch_header_fixed})
  string(REPLACE "\\" "/" from_pch_src_fixed ${from_pch_src_fixed})
  string(REPLACE "\\" "/" to_pch_bin_fixed ${to_pch_bin_fixed})
  string(REPLACE "\\" "/" use_pch_header_fixed ${use_pch_header_fixed})
  string(REPLACE "\\" "/" include_pch_header_fixed ${include_pch_header_fixed})
  foreach(src IN LISTS sources)
    string(REPLACE "\\" "/" src_fixed ${src})
    list(APPEND sources_fixed ${src_fixed})
  endforeach()

  set(pch_bin_file "${CMAKE_CURRENT_BINARY_DIR}/${to_pch_bin_fixed}")

  exclude_file_paths_from_path_list(. sources_filtered "${sources_fixed}" "/.*\\.h.*" 0)

  string(REPLACE "." "\\." from_pch_src_regex ${from_pch_src})
  exclude_file_paths_from_path_list(. sources_filtered "${sources_filtered}" "/${from_pch_src_regex}" 0)

  set(use_and_include_pch_header "/Yu\"${use_pch_header_fixed}\"")
  if(include_pch_header)
    set(use_and_include_pch_header "${use_and_include_pch_header} /FI\"${include_pch_header_fixed}\"")
  endif()

  set_source_files_properties(${sources_filtered}
                              PROPERTIES COMPILE_FLAGS "${use_and_include_pch_header} /Fp\"${pch_bin_file}\""
                                         OBJECT_DEPENDS "${pch_bin_file}")  

  # at the last to reset the properties in case if `from_pch_src` is a part of `sources`
  set_source_files_properties(${from_pch_src_fixed}
                              PROPERTIES COMPILE_FLAGS "/Yc\"${create_pch_header_fixed}\" /Fp\"${pch_bin_file}\""
                                         OBJECT_OUTPUTS "${pch_bin_file}")

  if(sources_out_var)
    list(APPEND ${sources_out_var} ${pch_src})
    set(${sources_out_var} ${${sources_out_var}} PARENT_SCOPE)
  endif()
endfunction()

macro(_parse_config_names_list_var list_var)
  set(config_types_ "")
  set(config_types "")
  set(has_all_config_types 0)
  set(has_default_config_type 0)

  if(${list_var})
    foreach(config_name IN LISTS ${list_var})
      if(${config_name} STREQUAL "*")
        set(has_all_config_types 1)

        foreach(config_type IN LISTS CMAKE_DEFAULT_CONFIGURATION_TYPES)
          list(APPEND config_types ${config_type})
        endforeach()
      else()
        list(APPEND config_types "${config_name}")
      endif()

      if(${config_name} STREQUAL ".")
        set(has_default_config_type 1)
      endif()
    endforeach()
  endif()
endmacro()

function(remove_global_optimization_flags)
  set(_args .;${ARGN})
  _parse_config_names_list_var(_args)

  if(MSVC)
    set(_compiler_flags_to_remove /O[^${CMAKE_NOTPRINTABLE_REGEX_CHARS}]+ /GL /GT)
    set(_linker_flags_to_remove /LTCG[^${CMAKE_NOTPRINTABLE_REGEX_CHARS}]*)
  elseif(GCC)
    set(_compiler_flags_to_remove -O[^${CMAKE_NOTPRINTABLE_REGEX_CHARS}]+) #-flto(-[^-]+)? -fwhopr(-[^-]+)?)
    set(_linker_flags_to_remove "")
  else()
    message(FATAL_ERROR "remove_global_optimization_flags: platform is not implemented")
  endif()

  foreach(config_type IN LISTS config_types)
    if(${config_type} STREQUAL ".")
      set(config_type_suffix "")
    else()
      string(TOUPPER "_${config_type}" config_type_suffix)
    endif()

    if(_compiler_flags_to_remove)
      foreach(flag_var
        CMAKE_CXX_FLAGS)
        foreach(flag IN LISTS _compiler_flags_to_remove)
          if(${flag_var}${config_type_suffix})
            generate_regex_replace_expression(flag_match_expr flag_replace_expr flag "")
            string(REGEX REPLACE "${flag_match_expr}" "${flag_replace_expr}" ${flag_var}${config_type_suffix} ${${flag_var}${config_type_suffix}})
            set(${flag_var}${config_type_suffix} ${${flag_var}${config_type_suffix}} PARENT_SCOPE)
          endif()
        endforeach()
      endforeach()
    endif()

    if(_linker_flags_to_remove)
      foreach(flag_var
        CMAKE_EXE_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS CMAKE_STATIC_LINKER_FLAGS CMAKE_SHARED_LINKER_FLAGS)
        foreach(flag IN LISTS _linker_flags_to_remove)
          if(${flag_var}${config_type_suffix})
            generate_regex_replace_expression(flag_match_expr flag_replace_expr flag "")
            string(REGEX REPLACE "${flag_match_expr}" "${flag_replace_expr}" ${flag_var}${config_type_suffix} ${${flag_var}${config_type_suffix}})
            set(${flag_var}${config_type_suffix} ${${flag_var}${config_type_suffix}} PARENT_SCOPE)
          endif()
        endforeach()
      endforeach()
    endif()
  endforeach()
endfunction()

function(fix_global_flags)
  set(_args .;${ARGN})
  _parse_config_names_list_var(_args)

  # invalid case flags
  if(MSVC)
    set(_compiler_flags_to_upcase "")
    set(_linker_flags_to_upcase /machine:X86)
  elseif(GCC)
    set(_compiler_flags_to_upcase "")
    set(_linker_flags_to_upcase "")
  else()
    message(FATAL_ERROR "fix_global_flags: platform is not implemented")
  endif()

  foreach(config_type IN LISTS config_types)
    if(${config_type} STREQUAL ".")
      set(config_type_suffix "")
    else()
      string(TOUPPER "_${config_type}" config_type_suffix)
    endif()

    if(_compiler_flags_to_upcase)
      foreach(flag_var
        CMAKE_CXX_FLAGS)
        foreach(flag IN LISTS _compiler_flags_to_upcase)
          if(${flag_var}${config_type_suffix})
            string(TOUPPER "${flag}" flag_uppercase)
            generate_regex_replace_expression(flag_match_expr flag_replace_expr flag "${flag_uppercase}")
            string(REGEX REPLACE "${flag_match_expr}" "${flag_replace_expr}" ${flag_var}${config_type_suffix} ${${flag_var}${config_type_suffix}})
            set(${flag_var}${config_type_suffix} ${${flag_var}${config_type_suffix}} PARENT_SCOPE)
          endif()
        endforeach()
      endforeach()
    endif()

    if(_linker_flags_to_upcase)
      foreach(flag_var
        CMAKE_EXE_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS CMAKE_STATIC_LINKER_FLAGS CMAKE_SHARED_LINKER_FLAGS)
        foreach(flag IN LISTS _linker_flags_to_upcase)
          if(${flag_var}${config_type_suffix})
            string(TOUPPER "${flag}" flag_uppercase)
            generate_regex_replace_expression(flag_match_expr flag_replace_expr flag "${flag_uppercase}")
            string(REGEX REPLACE "${flag_match_expr}" "${flag_replace_expr}" ${flag_var}${config_type_suffix} ${${flag_var}${config_type_suffix}})
            set(${flag_var}${config_type_suffix} ${${flag_var}${config_type_suffix}} PARENT_SCOPE)
          endif()
        endforeach()
      endforeach()
    endif()
  endforeach()
endfunction()

function(set_global_link_type type)
  set(_config_types .;${CMAKE_DEFAULT_CONFIGURATION_TYPES})
  _parse_config_names_list_var(_config_types)

  # all flags variables here must be list representable (index queriable)
  if(MSVC)
    if(${type} STREQUAL "dynamic")
      set(_compiler_flags_to_replace /MT /MTd)
      set(_compiler_flags_to_replace_by /MD /MDd)
      set(_linker_flags_to_replace "")
      set(_linker_flags_to_replace_by "")
    elseif(${type} STREQUAL "static")
      set(_compiler_flags_to_replace /MD /MDd)
      set(_compiler_flags_to_replace_by /MT /MTd)
      set(_linker_flags_to_replace "")
      set(_linker_flags_to_replace_by "")
    endif()
  elseif(GCC)
    set(_compiler_flags_to_replace "")
    set(_compiler_flags_to_replace_by "")
    set(_linker_flags_to_replace "")
    set(_linker_flags_to_replace_by "")

    if(${type} STREQUAL "dynamic")
      set(CMAKE_SHARED_LIBS ON)
    elseif(${type} STREQUAL "static")
      set(CMAKE_SHARED_LIBS OFF)
    endif()
  else()
    message(FATAL_ERROR "set_global_link_type: platform is not implemented")
  endif()

  foreach(config_type IN LISTS config_types)
    if(${config_type} STREQUAL ".")
      set(config_type_suffix "")
    else()
      string(TOUPPER "_${config_type}" config_type_suffix)
    endif()

    if(_compiler_flags_to_replace)
      foreach(flag_var
        CMAKE_CXX_FLAGS)
        set(flag_index 0)
        foreach(flag IN LISTS _compiler_flags_to_replace)
          if(${flag_var}${config_type_suffix})
            list(GET _compiler_flags_to_replace_by ${flag_index} flag_to_replace_by)
            generate_regex_replace_expression(flag_match_expr flag_replace_expr flag "${flag_to_replace_by}")
            string(REGEX REPLACE "${flag_match_expr}" "${flag_replace_expr}" ${flag_var}${config_type_suffix} ${${flag_var}${config_type_suffix}})
            set(${flag_var}${config_type_suffix} ${${flag_var}${config_type_suffix}} PARENT_SCOPE)
          endif()

          MATH(EXPR flag_index "${flag_index}+1")
        endforeach()
      endforeach()
    endif()

    if(_linker_flags_to_replace)
      foreach(flag_var
        CMAKE_EXE_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS CMAKE_STATIC_LINKER_FLAGS CMAKE_SHARED_LINKER_FLAGS)
        set(flag_index 0)
        foreach(flag IN LISTS _linker_flags_to_replace)
          if(${flag_var}${config_type_suffix})
            list(GET _linker_flags_to_replace_by ${flag_index} flag_to_replace_by)
            generate_regex_replace_expression(flag_match_expr flag_replace_expr flag "${flag_to_replace_by}")
            string(REGEX REPLACE "${flag_match_expr}" "${flag_replace_expr}" ${flag_var}${config_type_suffix} ${${flag_var}${config_type_suffix}})
            set(${flag_var}${config_type_suffix} ${${flag_var}${config_type_suffix}} PARENT_SCOPE)
          endif()

          MATH(EXPR flag_index "${flag_index}+1")
        endforeach()
      endforeach()
    endif()
  endforeach()
endfunction()

# create basic set of preprocessor definitions, compiler and linker flags for all configurations
# flags_list:
#   - console     - console application
#   - gui         - GUI application
#   - 32bit       - 32-bit linkage on non 32-bit subsystem
function(initialize_executable_target_defaults target flags_list)
  initialize_target_defaults_impl(${target} ${flags_list})
endfunction()

# create basic set of preprocessor definitions, compiler and linker flags for all configurations
# flags_list:
#   - 32bit       - 32-bit linkage on non 32-bit subsystem
function(initialize_library_target_defaults target flags_list)
  initialize_target_defaults_impl(${target} ${flags_list})
endfunction()

function(initialize_target_defaults_impl target flags_list)
  message(STATUS "Initializing target: ${target}...")

  if(TARGET ${target})
    get_target_property(target_type ${target} TYPE)

    foreach(config_type IN LISTS CMAKE_DEFAULT_CONFIGURATION_TYPES)
      string(TOUPPER "${config_type}" config_type_upper)

      # definitions
      if(config_type_upper STREQUAL "DEBUG")
        add_target_compile_definitions(${target} ${config_type_upper}
          PUBLIC
            _DEBUG
        )
      elseif(config_type_upper STREQUAL "RELEASE" OR
             config_type_upper STREQUAL "MINSIZEREL" OR
             config_type_upper STREQUAL "RELWITHDEBINFO")
        add_target_compile_definitions(${target} ${config_type_upper}
          PUBLIC
            NDEBUG
        )
      endif()

      # compilation flags
      if(MSVC)
        if(target_type STREQUAL "EXECUTABLE" OR
           target_type STREQUAL "STATIC_LIBRARY" OR
           target_type STREQUAL "SHARED_LIBRARY" OR
           target_type STREQUAL "MODULE_LIBRARY")
          if(config_type_upper STREQUAL "DEBUG")
            add_target_compile_properties(${target} ${config_type_upper}
              /Od     # always drop optimization in debug
            )
          endif()
        endif()
      elseif(GCC)
        if(target_type STREQUAL "EXECUTABLE" OR
           target_type STREQUAL "STATIC_LIBRARY" OR
           target_type STREQUAL "SHARED_LIBRARY" OR
           target_type STREQUAL "MODULE_LIBRARY")
          if(config_type_upper STREQUAL "DEBUG")
            add_target_compile_properties(${target} ${config_type_upper}
              -O0     # always drop optimization in debug
            )
          endif()
          if(config_type_upper STREQUAL "DEBUG" OR config_type_upper STREQUAL "RELWITHDEBINFO")
            add_target_compile_properties(${target} ${config_type_upper}
              -g
            )
          endif()
        endif()
      endif()
    endforeach()

    foreach(flag IN LISTS flags_list)
      # indifferent to Windows or Linux, has meaning to console/GUI linkage.
      if(flag STREQUAL "console")
        if(target_type STREQUAL "EXECUTABLE" OR
           target_type STREQUAL "SHARED_LIBRARY" OR
           target_type STREQUAL "MODULE_LIBRARY")
          add_target_compile_definitions(${target} *
            PUBLIC
              _CONSOLE
          )

          if(MSVC)
            add_target_link_properties(${target} NOTSTATIC *
              /SUBSYSTEM:CONSOLE
            )
          endif()
        endif()

      elseif(flag STREQUAL "gui")
        if(target_type STREQUAL "EXECUTABLE" OR
           target_type STREQUAL "SHARED_LIBRARY" OR
           target_type STREQUAL "MODULE_LIBRARY")
          add_target_compile_definitions(${target} *
            PUBLIC
              _WINDOWS
          )

          if(MSVC)
            add_target_link_properties(${target} NOTSTATIC *
              /SUBSYSTEM:WINDOWS
            )
          endif()
        endif()

      elseif(flag STREQUAL "32bit")
        if(GCC)
          add_target_compile_properties(${target} *
            -m32        # compile 32 bit target
          )

          add_target_link_properties(${target} NOTSTATIC *
            -m32        # link 32 bit target
          )
        endif()
      endif()
    endforeach()
  endif()
endfunction()

function(add_target_compile_definitions targets config_names inheritance_type)
  if(ARGN)
    _parse_config_names_list_var(config_names)

    if(has_all_config_types OR has_default_config_type)
      foreach(target IN LISTS targets)
        foreach(arg IN LISTS ARGN)
          if (arg STREQUAL "PRIVATE" OR arg STREQUAL "INTERFACE" OR arg STREQUAL "PUBLIC")
            message(FATAL_ERROR "PRIVATE/INTERFACE/PUBLIC types should not be in the list of targets, use another function call to declare different visibility targets")
          endif()
          # arg must be a string here
          target_compile_definitions(${target} ${inheritance_type} "${arg}")
        endforeach()
      endforeach()
    else()
      foreach(config_type IN LISTS config_types)
        foreach(target IN LISTS targets)
          foreach(arg IN LISTS ARGN)
            if (arg STREQUAL "PRIVATE" OR arg STREQUAL "INTERFACE" OR arg STREQUAL "PUBLIC")
              message(FATAL_ERROR "PRIVATE/INTERFACE/PUBLIC types should not be in the list of targets, use another function call to declare different visibility targets")
            endif()
            # arg must be a string here
            target_compile_definitions(${target} ${inheritance_type} "\$<\$<CONFIG:${config_type}>:${arg}>")
          endforeach()
        endforeach()
      endforeach()
    endif()
  else()
    message(FATAL_ERROR "add_target_compile_definitions: no arguments found")
  endif()
endfunction()

function(add_target_compile_properties targets config_names)
  _parse_config_names_list_var(config_names)

  foreach(target IN LISTS targets)
    # get previous properties
    get_target_property(PROP_LIST_${target} ${target} COMPILE_OPTIONS)

    # PROP_LIST can be list here
    set(PROP_LIST "")

    # convert string to list
    if(PROP_LIST_${target})
      foreach(arg IN LISTS PROP_LIST_${target})
        list(APPEND PROP_LIST ${arg})
      endforeach()
    endif()

    if(ARGN)
      if(has_all_config_types OR has_default_config_type)
        foreach(arg IN LISTS ARGN)
          list(APPEND PROP_LIST ${arg})
        endforeach()
      else()
        foreach(config_type IN LISTS config_types)
          foreach(arg IN LISTS ARGN)
            list(APPEND PROP_LIST "\$<\$<CONFIG:${config_type}>:${arg}>")
          endforeach()
        endforeach()
      endif()
    else()
      message(FATAL_ERROR "add_target_compile_properties: no arguments found")
    endif()

    if(PROP_LIST)
      set_target_properties(${target} PROPERTIES
        COMPILE_OPTIONS "${PROP_LIST}"
      )
    endif()
  endforeach()
endfunction()

function(add_target_link_directories targets config_names inheritance_type)
  if(ARGN)
    _parse_config_names_list_var(config_names)

    if(has_all_config_types OR has_default_config_type)
      foreach(target IN LISTS targets)
        foreach(arg IN LISTS ARGN)
          if (arg STREQUAL "PRIVATE" OR arg STREQUAL "INTERFACE" OR arg STREQUAL "PUBLIC")
            message(FATAL_ERROR "PRIVATE/INTERFACE/PUBLIC types should not be in the list of targets, use another function call to declare different visibility targets")
          endif()
          # arg must be a string here
          if (${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.13.0")
            target_link_directories(${target} ${inheritance_type} "${arg}")
          else()
            link_directories("${arg}")
          endif()
        endforeach()
      endforeach()
    else()
      foreach(config_type IN LISTS config_types)
        foreach(target IN LISTS targets)
          foreach(arg IN LISTS ARGN)
            if (arg STREQUAL "PRIVATE" OR arg STREQUAL "INTERFACE" OR arg STREQUAL "PUBLIC")
              message(FATAL_ERROR "PRIVATE/INTERFACE/PUBLIC types should not be in the list of targets, use another function call to declare different visibility targets")
            endif()
            # arg must be a string here
            if (${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.13.0")
              target_link_directories(${target} ${inheritance_type} "\$<\$<CONFIG:${config_type}>:${arg}>")
            else()
              link_directories("${arg}")
            endif()
          endforeach()
        endforeach()
      endforeach()
    endif()
  else()
    message(FATAL_ERROR "add_target_compile_definitions: no arguments found")
  endif()
endfunction()

function(add_target_link_properties targets linker_type config_names)
  _parse_config_names_list_var(config_names)

  set(ignore_notstatic 0)
  set(ignore_static 0)

  if (linker_type STREQUAL "*" OR linker_type STREQUAL ".")
    # use in all linker types
  elseif (linker_type STREQUAL "STATIC")
    set(ignore_notstatic 1)
  elseif (linker_type STREQUAL "NOTSTATIC")
    set(ignore_static 1)
  else()
    message(FATAL_ERROR "Unrecognized linker type: \"${linker_type}\"")
  endif()

  foreach(target IN LISTS targets)
    # static libraries has special flag variables for the linkage
    get_target_property(target_type ${target} TYPE)
    if(target_type STREQUAL "STATIC_LIBRARY")
      if (ignore_static)
        continue()
      endif()
      set(link_flags_name STATIC_LIBRARY_FLAGS)
    else()
      if (ignore_notstatic)
        continue()
      endif()
      set(link_flags_name LINK_FLAGS)
    endif()

    foreach(config_type IN LISTS config_types)
      if(${config_type} STREQUAL ".")
        set(config_type_suffix "")
      else()
        string(TOUPPER "_${config_type}" config_type_suffix)
      endif()

      get_target_property(PROP_LIST_${target} ${target} ${link_flags_name}${config_type_suffix})

      # PROP_LIST must be a string here
      set(PROP_LIST "")
      if(PROP_LIST_${target})
        foreach(arg IN LISTS PROP_LIST_${target})
          if(PROP_LIST)
            set(PROP_LIST "${PROP_LIST} ${arg}")
          else()
            set(PROP_LIST "${arg}")
          endif()
        endforeach()
      endif()

      if(ARGN)
        foreach(arg IN LISTS ARGN)
          if(PROP_LIST)
            if(NOT arg MATCHES "[${CMAKE_QUOTABLE_MATCH_CHARS}]")
              set(PROP_LIST "${PROP_LIST} ${arg}")
            else()
              set(PROP_LIST "${PROP_LIST} \"${arg}\"")
            endif()
          else()
            if(NOT arg MATCHES "[${CMAKE_QUOTABLE_MATCH_CHARS}]")
              set(PROP_LIST "${arg}")
            else()
              set(PROP_LIST "\"${arg}\"")
            endif()
          endif()
        endforeach()
      else()
        message(FATAL_ERROR "add_target_link_properties: no arguments found")
      endif()

      if(PROP_LIST)
        set_target_properties(${target} PROPERTIES
          ${link_flags_name}${config_type_suffix} "${PROP_LIST}"
        )
      endif()
    endforeach()
  endforeach()
endfunction()

function(get_target_compile_property out_var_name target config_type)
  get_target_property(target_type ${target} TYPE)
  if(${config_type} STREQUAL ".")
    set(config_type_suffix "")
  else()
    string(TOUPPER "_${config_type}" config_type_suffix)
  endif()

  get_target_property(${out_var_name} ${target} COMPILE_OPTIONS${config_type_suffix})

  set(${out_var_name} ${${out_var_name}} PARENT_SCOPE)
endfunction()

function(get_target_link_property out_var_name target config_type)
  get_target_property(target_type ${target} TYPE)
  if(${config_type} STREQUAL ".")
    set(config_type_suffix "")
  else()
    string(TOUPPER "_${config_type}" config_type_suffix)
  endif()

  if(target_type STREQUAL "STATIC_LIBRARY")
    get_target_property(${out_var_name} ${target} STATIC_LIBRARY_FLAGS${config_type_suffix})
  else()
    get_target_property(${out_var_name} ${target} LINK_FLAGS${config_type_suffix})
  endif()

  set(${out_var_name} ${${out_var_name}} PARENT_SCOPE)
endfunction()

function(get_target_link_libraries_recursively out_var_name target)
  set(link_libs "")
  get_target_link_libraries_recursively_impl(0 link_libs ${target} ${ARGN})
  #message(FATAL_ERROR "  target=${target} all=${link_libs}")

  set(${out_var_name} ${link_libs} PARENT_SCOPE)
endfunction()

function(get_target_link_libraries_recursively_impl nest_counter out_var_name target)
  math(EXPR next_nest_counter "${nest_counter}+1")

  get_target_property(link_libs ${target} LINK_LIBRARIES)

  #message("  target=${target} nest_counter=${nest_counter} link_libs=${link_libs}")

  if (link_libs)
    set(link_libs_more "")
    set(link_libs_recur "")

    foreach(link_lib IN LISTS link_libs)
      if (TARGET ${link_lib})
        get_target_link_libraries_recursively_impl(${next_nest_counter} link_libs_recur ${link_lib})
        if (link_libs_recur)
          list(APPEND link_libs_more ${link_libs_recur})
          list(REMOVE_DUPLICATES link_libs_more)
        endif()
        #message("    target=${link_lib} nest_counter=${nest_counter} link_libs_recur=${link_libs_recur}")
      endif()
    endforeach()

    list(APPEND link_libs ${link_libs_more})
    list(REMOVE_DUPLICATES link_libs)

    set(${out_var_name} ${link_libs} PARENT_SCOPE)
  else()
    set(${out_var_name} "" PARENT_SCOPE)
  endif()

  #message("    target=${target} nest_counter=${nest_counter} link_libs_more=${link_libs_more}")
endfunction()

function(add_target_subdirectory target_root_dir_var target target_binary_root)
  is_variable(is_target_root_dir_var ${target_root_dir_var})
  if (is_target_root_dir_var)
    if (TARGET ${target})
      return() # ignore if already added from common ancestor subdirectory
    endif()
    add_target_subdirectory_invoker(${${target_root_dir_var}} ${target_binary_root})
  endif()
endfunction()

function(print_flags)
  if(ARGN)
    foreach(flag_var IN LISTS ARGN)
      if(${flag_var})
        message(STATUS "* ${flag_var}=${${flag_var}}")
      else()
        message(STATUS "* ${flag_var}=")
      endif()
    endforeach(flag_var)
  else()
    message(FATAL_ERROR "ARGN must be defined and not empty")
  endif()
endfunction()

function(print_global_flags)
  set(_args .;${ARGN})
  _parse_config_names_list_var(_args)

  foreach(flag_var
          CMAKE_CXX_FLAGS CMAKE_EXE_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS
          CMAKE_STATIC_LINKER_FLAGS CMAKE_SHARED_LINKER_FLAGS)
    foreach(config_type IN LISTS config_types)
      if(${config_type} STREQUAL ".")
        set(config_type_suffix "")
      else()
        string(TOUPPER "_${config_type}" config_type_suffix)
      endif()

      print_flags(${flag_var}${config_type_suffix})
    endforeach()
  endforeach()
endfunction()

function(set_target_folder target_root_dir_var package_target_rel_path_pattern
         target_pattern_include_list target_pattern_exclude_list
         target_type_include_list target_type_exclude_list folder_path)
  set_target_property(${target_root_dir_var} "${package_target_rel_path_pattern}"
    ${target_pattern_include_list} ${target_pattern_exclude_list}
    "${target_type_include_list}" "${target_type_exclude_list}"
    FOLDER "${folder_path}")
endfunction()

function(set_target_property target_root_dir_var package_target_rel_path_pattern
         target_pattern_include_list target_pattern_exclude_list
         target_type_include_list target_type_exclude_list
         property_type property_value)
  if(package_target_rel_path_pattern STREQUAL "")
    message(FATAL_ERROR "package target relative path pattern must not be empty")
  endif()

  if(${target_root_dir_var} STREQUAL "" OR NOT IS_DIRECTORY "${${target_root_dir_var}}")
    return()
  endif()

  set(target_root_dir ${${target_root_dir_var}})
  get_filename_component(target_root_dir_abs ${target_root_dir} ABSOLUTE)

  string(TOLOWER "${target_root_dir_abs}" target_root_dir_path_abs_lower)

  get_global_targets_list(targets_list)

  foreach(target IN LISTS targets_list)
    # ignore all aliases because of read only
    get_target_property(target_origin ${target} ALIASED_TARGET)
    if (target_origin)
      continue()
    endif()

    set(is_target_applied 1)

    # target exclude by pattern
    foreach (target_to_exclude IN LISTS target_pattern_exclude_list)
      if (NOT target_to_exclude STREQUAL "" AND NOT target_to_exclude STREQUAL "." AND
          ${target} MATCHES ${target_to_exclude})
        set(is_target_applied 0)
        break()
      endif()
    endforeach()

    if (NOT is_target_applied)
      continue()
    endif()

    # target include by pattern
    set(is_target_applied 0)
    foreach (target_to_include IN LISTS target_pattern_include_list)
      # check on invalid include sequences at first
      if (target_to_include STREQUAL ".")
        message(FATAL_ERROR "target include pattern should not contain sequences related ONLY to the exclude patterns: target_to_include=\"${target_to_include}\"")
      endif()

      if (target_to_include STREQUAL "*")
        set(is_target_applied 1)
        break()
      elseif(${target} MATCHES ${target_to_include}) # should not be linked by OR with previous condition, otherwise compilation error
        set(is_target_applied 1)
        break()
      endif()
    endforeach()

    if (NOT is_target_applied)
      continue()
    endif()

    get_target_property(target_type ${target} TYPE)

    #message("** TYPE: ${target_type} TARGET: ${target}")

    # avoid error: INTERFACE_LIBRARY targets may only have whitelisted properties.
    if(target_type STREQUAL "INTERFACE_LIBRARY")
      continue()
    endif()

    set(is_target_type_applied 0)

    foreach (target_type_to_include IN LISTS target_type_include_list)
      # check on invalid include sequences at first
      if (target_type_to_include STREQUAL ".")
        message(FATAL_ERROR "target type include pattern should not contain sequences related ONLY to the exclude patterns: target_type_to_include=\"${target_type_to_include}\"")
      endif()

      if (target_type_to_include STREQUAL "*" OR target_type_to_include STREQUAL target_type)
        set(is_target_type_applied 1)
        foreach (target_type_to_exclude IN LISTS target_type_exclude_list)
          if (NOT target_type_to_exclude STREQUAL "" AND NOT target_type_to_exclude STREQUAL "." AND
              target_type_to_exclude STREQUAL target_type)
            set(is_target_type_applied 0)
            break()
          endif()
        endforeach()
        if (is_target_type_applied)
          break()
        endif()
      endif()
    endforeach()

    if (NOT is_target_type_applied)
      continue()
    endif()

    get_target_property(package_src_dir ${target} PACKAGE_SOURCE_DIR)
    if (package_src_dir)
      string(TOLOWER "${package_src_dir}" package_src_dir_lower)

      subtract_absolute_paths(${package_src_dir_lower} ${target_root_dir_path_abs_lower} package_target_rel_path_dir)
      #message("  target=${target}\n   package_src_dir_lower=${package_src_dir_lower}\n   target_root_dir_path_abs_lower=${target_root_dir_path_abs_lower}\n   package_target_rel_path_dir=${package_target_rel_path_dir}\n   package_target_rel_path_pattern=${package_target_rel_path_pattern}\n")

      if (NOT package_target_rel_path_dir STREQUAL "")
        if(package_target_rel_path_pattern STREQUAL ".") # special pattern means "equal to package source directory" or "not recursively from package source directory"
          if(package_target_rel_path_dir STREQUAL package_target_rel_path_pattern)
            set_target_properties(${target} PROPERTIES ${property_type} ${property_value})
            #message(  "set_target_properties(${target} PROPERTIES ${property_type} ${property_value}\n")
          endif()
        elseif(package_target_rel_path_pattern STREQUAL "*") # special pattern means "any"
          set_target_properties(${target} PROPERTIES ${property_type} ${property_value})
          #message(  "set_target_properties(${target} PROPERTIES ${property_type} ${property_value}\n")
        elseif(package_target_rel_path_dir MATCHES ${package_target_rel_path_pattern})
          set_target_properties(${target} PROPERTIES ${property_type} ${property_value})
          #message(  "set_target_properties(${target} PROPERTIES ${property_type} ${property_value}\n")
        endif()
      endif()
    endif()
  endforeach()
endfunction()
