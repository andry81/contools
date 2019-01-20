# include guard to avoid macro hooks recursion
if (NOT DEFINED ENABLE_TARGETS_EXTENSION_INCLUDE_DEFINED)
set(ENABLE_TARGETS_EXTENSION_INCLUDE_DEFINED 1)

include(Common)
include(ForwardVariables)

if (NOT ENABLE_TARGETS_EXTENSION_FUNCTION_INVOKERS)
  # much faster, but builtin variables ARGx are emulated here

  macro(add_library_invoker)
    _add_library(${ARGV})
  endmacro()

  macro(add_executable_invoker)
    _add_executable(${ARGV})
  endmacro()

  macro(add_custom_target_invoker)
    _add_custom_target(${ARGV})
  endmacro()

  macro(add_subdirectory_invoker)
    _add_subdirectory(${ARGV})
  endmacro()

  macro(add_target_subdirectory_invoker)
    # WORKAROUND:
    #  Because builtin system functions like add_subdirectory does not change
    #  some builtin variables like ARGVn, then we have to replace them by local
    #  variants to emulate arguments shift!
    #
    begin_emulate_shift_argv_arguments(${ARGV})
    add_subdirectory_begin(${ARGV})
    _add_subdirectory(${ARGV}) # DOES NOT CHANGE ARGVn arguments!
    add_subdirectory_end(${ARGV})
    end_emulate_shift_argv_arguments()
  endmacro()

  macro(find_package_invoker)
    # WORKAROUND:
    #  Because builtin system functions like add_subdirectory does not change
    #  some builtin variables like ARGVn, then we have to replace them by local
    #  variants to emulate arguments shift!
    #
    #begin_emulate_shift_argv_arguments(${ARGV})
    _find_package(${ARGV})
    #end_emulate_shift_argv_arguments()
  endmacro()
else()
  # slower, but builtin variables ARGx can be controlled here through the variable forwarding logic

  # We should prepare arguments list before call to system function because in the real world a function can exist as a MACRO.
  # This means the ARGx built-in variables MAY BECOME INVALID and relate to a different function signature!
  # We must restore them into original state by call to a potential macro through an intermediate function!

  function(add_library_invoker)
    # Now ARGx built-in variables would be related to the add_library_invoker function parameters list instead of upper caller
    # which might has different/shifted parameters list!
    # But now we have to propogate all changed variables here into upper context by ourselves!
    begin_track_variables()
    _add_library(${ARGV})
    forward_changed_variables_to_parent_scope()
    end_track_variables()
  endfunction()

  function(add_executable_invoker)
    # Now ARGx built-in variables would be related to the add_executable_invoker function parameters list instead of upper caller
    # which might has different/shifted parameters list!
    # But now we have to propogate all changed variables here into upper context by ourselves!
    begin_track_variables()
    _add_executable(${ARGV})
    forward_changed_variables_to_parent_scope()
    end_track_variables()
  endfunction()

  function(add_custom_target_invoker)
    # Now ARGx built-in variables would be related to the add_custom_target_invoker function parameters list instead of upper caller
    # which might has different/shifted parameters list!
    # But now we have to propogate all changed variables here into upper context by ourselves!
    begin_track_variables()
    _add_custom_target(${ARGV})
    forward_changed_variables_to_parent_scope()
    end_track_variables()
  endfunction()

  macro(add_target_subdirectory_invoker)
    add_subdirectory_begin(${ARGV})
    add_subdirectory_invoker(${ARGV})
    add_subdirectory_end(${ARGV})
  endmacro()

  function(add_subdirectory_invoker)
    # Now ARGx built-in variables would be related to the add_subdirectory_invoker function parameters list instead of upper caller
    # which might has different/shifted parameters list!
    # But now we have to propogate all changed variables here into upper context by ourselves!
    begin_track_variables()
    _add_subdirectory(${ARGV})
    forward_changed_variables_to_parent_scope()
    end_track_variables()
  endfunction()

  function(find_package_invoker)
    # Now ARGx built-in variables would be related to the find_package_invoker function parameters list instead of upper caller
    # which might has different/shifted parameters list!
    # But now we have to propogate all changed variables here into upper context by ourselves!
    begin_track_variables()
    _find_package(${ARGV})
    forward_changed_variables_to_parent_scope()
    end_track_variables()
  endfunction()
endif()

macro(add_library)
  add_library_begin(${ARGV})
  add_library_invoker(${ARGV})
  add_library_end(${ARGV})
endmacro()

macro(add_executable)
  add_executable_begin(${ARGV})
  add_executable_invoker(${ARGV})
  add_executable_end(${ARGV})
endmacro()

macro(add_custom_target)
  add_custom_target_begin(${ARGV})
  add_custom_target_invoker(${ARGV})
  add_custom_target_end(${ARGV})
endmacro()

macro(add_subdirectory)
  add_subdirectory_begin(${ARGV})
  add_subdirectory_invoker(${ARGV})
  add_subdirectory_end(${ARGV})
endmacro()

macro(find_package _arg0)
  if(${ARGC} GREATER 1)
    # drop extension parameters before call to a system function
    is_variable(_4E6AC8D8_is_argv0_var_name ${ARGV0})
    if (_4E6AC8D8_is_argv0_var_name AND IS_DIRECTORY "${${ARGV0}}")
      find_package_begin(${ARGV})
      #message(" 1 find_package_invoker(${ARGN})")
      find_package_invoker(${ARGN})
      find_package_end(${ARGV})
    elseif (_4E6AC8D8_is_argv0_var_name AND EXISTS "${${ARGV0}}")
      # not a directory path
      #message(" 2 find_package_invoker(${ARGN})")
      find_package_begin(. ${ARGN})
      find_package_invoker(${ARGN})
      find_package_end(. ${ARGN})
    else()
      # compatability
      #message(" 3 find_package_invoker(${ARGV})")
      find_package_begin(. ${ARGV})
      find_package_invoker(${ARGV})
      find_package_end(. ${ARGV})
    endif()
    unset(_4E6AC8D8_is_argv0_var_name)
  else()
    # compatability
    #message(" 4 find_package_invoker(${ARGV})")
    find_package_begin(. ${ARGV})
    find_package_invoker(${ARGV})
    find_package_end(. ${ARGV})
  endif()
endmacro()

function(get_global_targets_list var)
  get_property(${var} GLOBAL PROPERTY GlobalTargetList)
  set(${var} ${${var}} PARENT_SCOPE)
endfunction()

function(set_global_targets_list)
  set_property(GLOBAL PROPERTY GlobalTargetList ${ARGN})
endfunction()

endif()
