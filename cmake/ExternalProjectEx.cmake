INCLUDE(ExternalProject)

# get external project property to an user defined variable
function(get_project_property var name prop)
  string(TOUPPER "${var}" VAR)
  get_property(is_ep_set TARGET ${name} PROPERTY _EP_${prop} SET)
  if(NOT is_ep_set)
    message(FATAL_ERROR "External project \"${name}\" has no ${prop}")
  endif()
  get_property(${var} TARGET ${name} PROPERTY _EP_${prop})
  set(${var} "${${var}}" PARENT_SCOPE)
endfunction()

# function exists to configure external project inplace
function(ExternalProject_DoConfigure name)
  ExternalProject_Get_Property(${name} source_dir binary_dir tmp_dir)

  # Depend on other external projects (file-level).
  set(file_deps)
  get_property(deps TARGET ${name} PROPERTY _EP_DEPENDS)
  foreach(dep IN LISTS deps)
    if (${CMAKE_MAJOR_VERSION} GREATER 2 AND ${CMAKE_MINOR_VERSION} GREATER 7 AND ${CMAKE_PATCH_VERSION} GREATER 9)
        _ep_get_step_stampfile(${dep} "done" done_stamp_file)
        list(APPEND file_deps ${done_stamp_file})
    else()
        get_property(dep_stamp_dir TARGET ${dep} PROPERTY _EP_STAMP_DIR)
        list(APPEND file_deps ${dep_stamp_dir}${cfgdir}/${dep}-done)
    endif()
  endforeach()

  get_property(cmd_set TARGET ${name} PROPERTY _EP_CONFIGURE_COMMAND SET)
  if(cmd_set)
    get_property(cmd TARGET ${name} PROPERTY _EP_CONFIGURE_COMMAND)
  else()
    get_target_property(cmake_command ${name} _EP_CMAKE_COMMAND)
    if(cmake_command)
      set(cmd "${cmake_command}")
    else()
      set(cmd "${CMAKE_COMMAND}")
    endif()

    get_property(cmake_args TARGET ${name} PROPERTY _EP_CMAKE_ARGS)
    list(APPEND cmd ${cmake_args})

    # Replace list separators.
    get_property(sep TARGET ${name} PROPERTY _EP_LIST_SEPARATOR)
    if(sep AND cmd)
      string(REPLACE "${sep}" "\\;" cmd "${cmd}")
    endif()

    # If there are any CMAKE_CACHE_ARGS, write an initial cache and use it
    get_property(cmake_cache_args TARGET ${name} PROPERTY _EP_CMAKE_CACHE_ARGS)
    if(cmake_cache_args)
      set(_ep_cache_args_script "${tmp_dir}/${name}-cache.cmake")
      _ep_write_initial_cache(${name} "${_ep_cache_args_script}" "${cmake_cache_args}")
      list(APPEND cmd "-C${_ep_cache_args_script}")
    endif()

    get_target_property(cmake_generator ${name} _EP_CMAKE_GENERATOR)
    if(cmake_generator)
      list(APPEND cmd "-G${cmake_generator}" "${source_dir}")
    else()
      if(CMAKE_EXTRA_GENERATOR)
        list(APPEND cmd "-G${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}"
          "${source_dir}")
      else()
        list(APPEND cmd "-G${CMAKE_GENERATOR}" "${source_dir}")
      endif()
    endif()
  endif()

  # If anything about the configure command has changed, (command itself, cmake,
  # cmake args or cmake generator), then re-run the configure step.
  # Details: https://public.kitware.com/Bug/view.php?id=10258
  #
  if(NOT EXISTS ${tmp_dir}/${name}-cfgcmd.txt.in)
    file(WRITE ${tmp_dir}/${name}-cfgcmd.txt.in "cmd='\@cmd\@'\n")
  endif()
  configure_file(${tmp_dir}/${name}-cfgcmd.txt.in ${tmp_dir}/${name}-cfgcmd.txt)
  list(APPEND file_deps ${tmp_dir}/${name}-cfgcmd.txt)
  list(APPEND file_deps ${_ep_cache_args_script})

  get_property(log TARGET ${name} PROPERTY _EP_LOG_CONFIGURE)
  if(log)
    set(log LOG 1)
  else()
    set(log "")
  endif()
  message(STATUS "Start configure external project ${name}...")
  message(COMMAND ${cmd}
        WORKING_DIRECTORY ${binary_dir}
        RESULT_VARIABLE configure_RESULT
        OUTPUT_VARIABLE configure_OUTPUT
        ERROR_VARIABLE configure_ERROR)
  if (configure_RESULT)
    message(WARNING "${name}'s cmake configure failed:")
    message(WARNING "Error code: " ${configure_RESULT})
    message(WARNING "Output: " ${configure_OUTPUT})
    message(WARNING "Error output: " ${configure_ERROR})
  else()
    message(STATUS "Configure external project ${name} success")
  endif()        
endfunction()
