if (NOT CONFIGURE_IN_FILE)
  message(FATAL_ERROR "* CONFIGURE_IN_FILE variable must be defined!")
endif()
if (NOT CONFIGURE_OUT_FILE)
  message(FATAL_ERROR "* CONFIGURE_OUT_FILE variable must be defined!")
endif()

configure_file("${CONFIGURE_IN_FILE}" "${CONFIGURE_OUT_FILE}" @ONLY)

unset(CONFIGURE_IN_FILE CACHE)
unset(CONFIGURE_OUT_FILE CACHE)
