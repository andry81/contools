function(generate_build_version_variables)
  string(TIMESTAMP BUILD_VERSION_DATE_TIME_STR "%Y-%m-%d %H:%M:%S" UTC)
  string(TIMESTAMP BUILD_VERSION_DATE_TIME_TOKEN "%Y_%m_%d_%H_%M_%S" UTC)

  set(BUILD_VERSION_DATE_TIME_STR ${BUILD_VERSION_DATE_TIME_STR} PARENT_SCOPE)
  set(BUILD_VERSION_DATE_TIME_TOKEN ${BUILD_VERSION_DATE_TIME_TOKEN} PARENT_SCOPE)
endfunction()

function(generate_build_version_include_file include_file)
  file(WRITE ${include_file} "")
  file(APPEND ${include_file} "#pragma once\n\n")
  file(APPEND ${include_file} "#define BUILD_VERSION_DATE_TIME_STR \"${BUILD_VERSION_DATE_TIME_STR}\"\n")
  file(APPEND ${include_file} "#define BUILD_VERSION_DATE_TIME_TOKEN ${BUILD_VERSION_DATE_TIME_TOKEN}\n")
endfunction()
