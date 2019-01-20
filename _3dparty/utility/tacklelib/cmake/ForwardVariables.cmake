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

function(is_variable is_var_out var_name)
  if(NOT is_var_out OR is_var_out STREQUAL var_name)
    message(FATAL_ERROR "is_var_out must be not empty and not equal to var_name:\n is_var_out=\"${is_var_out}\"\n var_name=\"${var_name}\"")
  endif()

  if (NOT DEFINED var_name OR var_name STREQUAL "" OR var_name STREQUAL ".")
    set(${is_var_out} 0 PARENT_SCOPE)
  endif()

  get_cmake_property(vars_list VARIABLES)

  list(FIND vars_list ${var_name} var_index)
  if(NOT var_index EQUAL -1)
    set(${is_var_out} 1 PARENT_SCOPE)
  else()
    set(${is_var_out} 0 PARENT_SCOPE)
  endif()
endfunction()

function(is_argv_variable is_var_out var_name)
  # simple test w/o call to slow MATCH operator
  string(SUBSTRING "${var_name}" 0 4 var_prefix)
  if (var_prefix STREQUAL "ARGV")
    set(${is_var_out} 1 PARENT_SCOPE)
  else()
    set(${is_var_out} 0 PARENT_SCOPE)
  endif()
endfunction()

function(is_arg_variable is_var_out var_name)
  # simple test w/o call to slow MATCH operator
  string(SUBSTRING "${var_name}" 0 3 var_prefix)
  if (var_prefix STREQUAL "ARG")
    set(${is_var_out} 1 PARENT_SCOPE)
  else()
    set(${is_var_out} 0 PARENT_SCOPE)
  endif()
endfunction()

# custom user stack over local variables with virtual variables handle like ARGV and ARGV0..N

macro(pushset_variable_to_stack var_name var_value)
  if (DEFINED _2BA2974B_vars_stack[${var_name}]::size)
    set(_2BA2974B_vars_stack_size ${_2BA2974B_vars_stack\[${var_name}\]\:\:size})
    set(_2BA2974B_vars_stack[${var_name}]::${_2BA2974B_vars_stack_size} ${${var_name}})
    math(EXPR _2BA2974B_vars_stack_size ${_2BA2974B_vars_stack_size}+1)
    set(_2BA2974B_vars_stack[${var_name}]::size ${_2BA2974B_vars_stack_size})
    # cleanup local variables
    unset(_2BA2974B_vars_stack_size)
  else()
    set(_2BA2974B_vars_stack[${var_name}]::0 ${${var_name}})
    set(_2BA2974B_vars_stack[${var_name}]::size 1)
  endif()

  set(${var_name} ${var_value})
endmacro()

macro(pushunset_variable_to_stack var_name)
  if (DEFINED _2BA2974B_vars_stack[${var_name}]::size)
    set(_2BA2974B_vars_stack_size ${_2BA2974B_vars_stack\[${var_name}\]\:\:size})
    set(_2BA2974B_vars_stack[${var_name}]::${_2BA2974B_vars_stack_size} ${${var_name}})
    math(EXPR _2BA2974B_vars_stack_size ${_2BA2974B_vars_stack_size}+1)
    set(_2BA2974B_vars_stack[${var_name}]::size ${_2BA2974B_vars_stack_size})
    # cleanup local variables
    unset(_2BA2974B_vars_stack_size)
  else()
    set(_2BA2974B_vars_stack[${var_name}]::0 ${${var_name}})
    set(_2BA2974B_vars_stack[${var_name}]::size 1)
  endif()

  unset(${var_name})
endmacro()

macro(popset_variable_from_stack var_name)
  if (NOT DEFINED _2BA2974B_vars_stack[${var_name}]::size)
    message(FATAL_ERROR "macro stack is already undefined or not yet defined")
  endif()

  set(_2BA2974B_vars_stack_size ${_2BA2974B_vars_stack\[${var_name}\]\:\:size})
  if (_2BA2974B_vars_stack_size GREATER 1)
    math(EXPR _2BA2974B_vars_stack_size ${_2BA2974B_vars_stack_size}-1)
    set(${var_name} ${_2BA2974B_vars_stack\[${var_name}\]\:\:${_2BA2974B_vars_stack_size}})
    set(_2BA2974B_vars_stack[${var_name}]::size ${_2BA2974B_vars_stack_size})
    unset(_2BA2974B_vars_stack\[${var_name}\]\:\:${_2BA2974B_vars_stack_size})
  else()
    # check if special ARGx variable
    is_arg_variable(_2BA2974B_is_arg_var ${var_name})
    if (NOT _2BA2974B_is_arg_var)
      set(${var_name} ${_2BA2974B_vars_stack\[${var_name}\]\:\:0}) # if value was not set then equivalent to unset
    else()
      # we can not set/unset virtual variables, instead we must unset a local variable to remove interference with the virtual one
      unset(${var_name})
    endif()
    # cleanup the stack
    unset(_2BA2974B_vars_stack[${var_name}]::size)
    unset(_2BA2974B_vars_stack[${var_name}]::0)
  endif()

  # cleanup local variables
  unset(_2BA2974B_vars_stack_size)
endmacro()

# custom user stack over property variables

function(pushset_property_to_stack prop_entry prop_name var_value)
  get_property(prop_value ${prop_entry} PROPERTY ${prop_name})

  set(vars_stack_size_var _2BA2974B_vars_stack[${prop_name}]::size)
  get_property(is_vars_stack_set ${prop_entry} PROPERTY ${vars_stack_size_var} SET)
  if (is_vars_stack_set)
    get_property(vars_stack_size ${prop_entry} PROPERTY ${vars_stack_size_var})
    set_property(${prop_entry} PROPERTY _2BA2974B_vars_stack[${prop_name}]::${vars_stack_size} ${prop_value})
    math(EXPR vars_stack_size ${vars_stack_size}+1)
    set_property(${prop_entry} PROPERTY _2BA2974B_vars_stack[${prop_name}]::size ${vars_stack_size})
  else()
    set_property(${prop_entry} PROPERTY _2BA2974B_vars_stack[${prop_name}]::0 ${prop_value})
    set_property(${prop_entry} PROPERTY _2BA2974B_vars_stack[${prop_name}]::size 1)
  endif()

  set_property(${prop_entry} PROPERTY ${prop_name} ${var_value})
endfunction()

function(pushunset_property_to_stack prop_entry prop_name)
  get_property(prop_value ${prop_entry} PROPERTY ${prop_name})

  set(vars_stack_size_var _2BA2974B_vars_stack[${prop_name}]::size)
  get_property(is_vars_stack_set ${prop_entry} PROPERTY ${vars_stack_size_var} SET)
  if (is_vars_stack_set)
    get_property(vars_stack_size ${prop_entry} PROPERTY ${vars_stack_size_var})
    set_property(${prop_entry} PROPERTY _2BA2974B_vars_stack[${prop_name}]::${vars_stack_size} ${prop_value})
    math(EXPR vars_stack_size ${vars_stack_size}+1)
    set_property(${prop_entry} PROPERTY _2BA2974B_vars_stack[${prop_name}]::size ${vars_stack_size})
  else()
    set_property(${prop_entry} PROPERTY _2BA2974B_vars_stack[${prop_name}]::0 ${prop_value})
    set_property(${prop_entry} PROPERTY _2BA2974B_vars_stack[${prop_name}]::size 1)
  endif()

  set_property(${prop_entry} PROPERTY ${prop_name}) # unset property
endfunction()

function(popset_property_from_stack var_out prop_entry prop_name)
  set(vars_stack_size_var _2BA2974B_vars_stack[${prop_name}]::size)
  get_property(is_vars_stack_set ${prop_entry} PROPERTY ${vars_stack_size_var} SET)
  if (NOT is_vars_stack_set)
    message(FATAL_ERROR "macro stack is already undefined or not yet defined")
  endif()

  get_property(vars_stack_size ${prop_entry} PROPERTY ${vars_stack_size_var})
  if (vars_stack_size GREATER 1)
    math(EXPR vars_stack_size ${vars_stack_size}-1)
    set(stack_top_prop_name _2BA2974B_vars_stack[${prop_name}]::${vars_stack_size})
    get_property(prop_value ${prop_entry} PROPERTY ${stack_top_prop_name})
    set_property(${prop_entry} PROPERTY _2BA2974B_vars_stack[${prop_name}]::size ${vars_stack_size})
    set_property(${prop_entry} PROPERTY ${stack_top_prop_name}) # property unset
  else()
    # cleanup the stack
    set(stack_top_prop_name _2BA2974B_vars_stack[${prop_name}]::0)
    get_property(prop_value ${prop_entry} PROPERTY ${stack_top_prop_name})
    set_property(${prop_entry} PROPERTY _2BA2974B_vars_stack[${prop_name}]::size) # property unset
    set_property(${prop_entry} PROPERTY ${stack_top_prop_name}) # property unset
  endif()

  set_property(${prop_entry} PROPERTY ${prop_name} ${prop_value})

  if (NOT var_out STREQUAL "" AND NOT var_out STREQUAL ".")
    set(${var_out} ${prop_value} PARENT_SCOPE)
  endif()
endfunction()

macro(begin_emulate_shift_argv_arguments)
  # WORKAROUND:
  #  Because we can not change values of ARGV0..N arguments, then we have to
  #  replace them by local variables to emulate arguments shift!
  #

  if (NOT "${ARGV}" STREQUAL "")
    pushset_variable_to_stack(ARGV "${ARGV}")
  else()
    pushunset_variable_to_stack(ARGV)
  endif()

  # update ARGVn variables
  set(_6CFB89A4_index 0)
  foreach(_6CFB89A4_arg IN LISTS ARGV)
    if (NOT "${_6CFB89A4_arg}" STREQUAL "")
      pushset_variable_to_stack(ARGV${_6CFB89A4_index} "${_6CFB89A4_arg}")
    else()
      pushunset_variable_to_stack(ARGV${_6CFB89A4_index})
    endif()
    math(EXPR _6CFB89A4_index ${_6CFB89A4_index}+1)
  endforeach()

  pushset_variable_to_stack(_6CFB89A4_num_emul_argv ${_6CFB89A4_index})

  # cleanup local variables
  unset(_6CFB89A4_arg)
  unset(_6CFB89A4_index)
endmacro()

macro(end_emulate_shift_argv_arguments)
  set(_6CFB89A4_index 0)
  while(_6CFB89A4_index LESS _6CFB89A4_num_emul_argv)
    popset_variable_from_stack(ARGV${_6CFB89A4_index})
    math(EXPR _6CFB89A4_index ${_6CFB89A4_index}+1)
  endwhile()
  popset_variable_from_stack(_6CFB89A4_num_emul_argv)

  popset_variable_from_stack(ARGV)

  # cleanup local variables
  unset(_6CFB89A4_index)
endmacro()

macro(end_emulate_shift_argvn_arguments)
  set(_6CFB89A4_max 10)
  set(_6CFB89A4_index 0)
  while(_6CFB89A4_index LESS _6CFB89A4_max)
    popset_variable_from_stack(ARGV${_6CFB89A4_index})
    math(EXPR _6CFB89A4_index ${_6CFB89A4_index}+1)
  endwhile()

  # cleanup local variables
  unset(_6CFB89A4_index)
  unset(_6CFB89A4_max)
endmacro()

# CAUTION:
# 1. User must not use builtin ARGC/ARGV/ARGN/ARGV0..N variables because they are a part of function/macro call stack
#
function(get_variable uncached_var_out cached_var_out var_name)
  if (uncached_var_out AND NOT uncached_var_out STREQUAL ".")
    set(uncached_var_out_is_defined 1)
  else()
    set(uncached_var_out_is_defined 0)
  endif()

  if (cached_var_out AND NOT cached_var_out STREQUAL ".")
    set(cached_var_out_is_defined 1)
  else()
    set(cached_var_out_is_defined 0)
  endif()

  if (NOT uncached_var_out_is_defined AND NOT cached_var_out_is_defined)
    message(FATAL_ERROR "at least one output variable must be defined")
  endif()

  if (uncached_var_out_is_defined)
    if (uncached_var_out STREQUAL var_name)
      message(FATAL_ERROR "uncached_var_out and var_name variables must be different: \"${uncached_var_out}\"")
    endif()
  endif()

  if (uncached_var_out_is_defined OR cached_var_out_is_defined)
    if (uncached_var_out STREQUAL cached_var_out)
      message(FATAL_ERROR "uncached_var_out and cached_var_out variables must be different: \"${cached_var_out}\"")
    endif()
  endif()

  # check for specific builtin variables
  string(SUBSTRING "${var_name}" 0 3 _5FC3B9AA_var_forbidden)
  if (_5FC3B9AA_var_forbidden STREQUAL "ARG")
    message(FATAL_ERROR "specific builtin variables are forbidden to use: \"${var_name}\"")
  endif()

  get_property(_5FC3B9AA_var_cache_value_is_set CACHE "${var_name}" PROPERTY VALUE SET)

  if (NOT _5FC3B9AA_var_cache_value_is_set)
    if (cached_var_out_is_defined)
      unset(${uncached_var_out} PARENT_SCOPE)
    endif()
    if (uncached_var_out_is_defined)
      set(${uncached_var_out} ${${var_name}} PARENT_SCOPE)
    endif()
  else()
    if (cached_var_out_is_defined)
      # propogate cached variant of a variable
      if (DEFINED ${var_name})
        set(${cached_var_out} ${${var_name}} PARENT_SCOPE)
      else()
        unset(${cached_var_out} PARENT_SCOPE)
      endif()
    endif()

    if (uncached_var_out_is_defined)
      # save cache properties of a variable
      get_property(_5FC3B9AA_var_cache_value CACHE "${var_name}" PROPERTY VALUE)
      get_property(_5FC3B9AA_var_cache_type CACHE "${var_name}" PROPERTY TYPE)
      get_property(_5FC3B9AA_var_cache_docstring CACHE "${var_name}" PROPERTY HELPSTRING)

      # remove cached variant of a variable
      unset(${var_name} CACHE)

      # propogate uncached variant of a variable
      if (DEFINED ${var_name})
        set(${uncached_var_out} ${${var_name}} PARENT_SCOPE)
      else()
        unset(${uncached_var_out} PARENT_SCOPE)
      endif()

      # restore cache properties of a variable
      #message("set(${var_name} \"${_5FC3B9AA_var_cache_value}\" CACHE \"${_5FC3B9AA_var_cache_type}\" \"${_5FC3B9AA_var_cache_docstring}\")")
      set(${var_name} ${_5FC3B9AA_var_cache_value} CACHE ${_5FC3B9AA_var_cache_type} "${_5FC3B9AA_var_cache_docstring}")
    endif()
  endif()
endfunction()

# Start to track variables for change or adding.
# Note that variables starting with underscore are NOT ignored.
function(begin_track_variables)
  # all variables with the `_39067B90_` prefix will be gnored by the search logic itself
  get_cmake_property(_39067B90_old_vars VARIABLES)

  #message(" _39067B90_old_vars=${_39067B90_old_vars}")

  foreach(_39067B90_var IN LISTS _39067B90_old_vars)
    # check for this function variables
    string(SUBSTRING "${_39067B90_var}" 0 10 _39067B90_var_prefix)
    if (_39067B90_var_prefix STREQUAL "_39067B90_")
      continue()
    endif()

    # check for special stack variables, should not be tracked, handles separately
    string(SUBSTRING "${_39067B90_var}" 0 10 _39067B90_var_prefix)
    if (_39067B90_var_prefix STREQUAL "_2BA2974B_")
      continue()
    endif()

    # check for specific builtin variables
    string(SUBSTRING "${_39067B90_var}" 0 3 _39067B90_var_prefix)
    if (_39067B90_var_prefix STREQUAL "ARG")
      continue()
    endif()

    # we must compare with uncached variable variant ONLY
    get_variable(_39067B90_old_${_39067B90_var} . ${_39067B90_var})
    if (DEFINED _39067B90_old_${_39067B90_var})
      set(_39067B90_old_${_39067B90_var} ${_39067B90_old_${_39067B90_var}} PARENT_SCOPE)
    # no need to unset because of uniqueness of a variable name
    #else()
    #  unset(_39067B90_old_${_39067B90_var} PARENT_SCOPE)
    endif()
    #message(" _39067B90_old_${_39067B90_var}=\"${_39067B90_old_${_39067B90_var}}\"")
  endforeach()
endfunction()

# forward_changed_variables_to_parent_scope([exclusions])
# Forwards variables that was added/changed since last call to start_track_variables() to the parent scope.
# Note that variables starting with underscore are NOT ignored.
macro(forward_changed_variables_to_parent_scope)
  # all variables with the `_39067B90_` prefix will be gnored by the search logic itself
  get_cmake_property(_39067B90_vars VARIABLES)
  set(_39067B90_ignore_vars ${ARGN})

  #message(" _39067B90_vars=${_39067B90_vars}")
  foreach(_39067B90_var IN LISTS _39067B90_vars)
    list(FIND _39067B90_ignore_vars ${_39067B90_var} _39067B90_is_var_ignored)
    if(NOT _39067B90_is_var_ignored EQUAL -1)
      continue()
    endif()

    # check for this function variables
    string(SUBSTRING "${_39067B90_var}" 0 10 _39067B90_var_prefix)
    if (_39067B90_var_prefix STREQUAL "_39067B90_")
      continue()
    endif()

    # check for special stack variables, should not be tracked, handles separately
    string(SUBSTRING "${_39067B90_var}" 0 10 _39067B90_var_prefix)
    if (_39067B90_var_prefix STREQUAL "_2BA2974B_")
      continue()
    endif()

    # check for specific builtin variables
    string(SUBSTRING "${_39067B90_var}" 0 3 _39067B90_var_prefix)
    if (_39067B90_var_prefix STREQUAL "ARG")
      continue()
    endif()

    # we must compare with uncached variable variant ONLY
    get_variable(_39067B90_var_uncached . ${_39067B90_var})

    if(DEFINED _39067B90_old_${_39067B90_var})
      if (DEFINED _39067B90_var_uncached)
        if(NOT _39067B90_var_uncached STREQUAL _39067B90_old_${_39067B90_var})
          set(${_39067B90_var} ${_39067B90_var_uncached} PARENT_SCOPE)
        endif()
      else()
        unset(${_39067B90_var} PARENT_SCOPE)
      endif()
    elseif (DEFINED _39067B90_var_uncached)
      set(${_39067B90_var} ${_39067B90_var_uncached} PARENT_SCOPE)
    endif()
  endforeach()
endmacro()

function(end_track_variables)
  get_cmake_property(_9F05B048_vars VARIABLES)
  #message(" _9F05B048_vars=${_9F05B048_vars}")

  foreach(_9F05B048_var IN LISTS _9F05B048_vars)
    string(SUBSTRING "${_9F05B048_var}" 0 10 _9F05B048_var_prefix)
    if (NOT _9F05B048_var_prefix STREQUAL "_39067B90_")
      continue()
    endif()

    unset(${_9F05B048_var} PARENT_SCOPE)
    #unset(${_9F05B048_var}) # must be unset here too to retest at the end
    #message(" unset ${_9F05B048_var}")
  endforeach()

  # CAUTION: For correct check all variables must be unset in the current scope too!
  #get_cmake_property(_9F05B048_vars VARIABLES)
  #message(" _9F05B048_vars=${_9F05B048_vars}")
endfunction()
