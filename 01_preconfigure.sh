#!/bin/bash

# Script ONLY for execution.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0) ]]; then 

source "/bin/bash_entry" || exit $?
tkl_include "__init__.sh" || exit $?

function Call()
{
  echo ">$@"
  echo
  "$@"
  LastError=$?
  return $LastError
}

function Pause()
{
  local key
  read -n1 -r -p "Press any key to continue..." key
  echo
}

case "$OSTYPE" in
  mingw* | msys* | cygwin*)
    Call "${COMSPEC//\\//}" /c "${BASH_SOURCE_DIR}/01_preconfigure.bat" $@
    exit $?
    ;;
  *)
    echo "1. Download `https://sf.net/p/tacklelib/3dparty`."
    echo "2. Read the instructions from the readme file in the downloaded project to checkout third party sources."
    echo "3. Press any key to continue and select the `_src` subdirectory in the project as a third party catalog."

    Pause

    _3DPARTY_ROOT=$("${UTILITY_ROOT}/wxFileDialog" "" "${CONFIGURE_ROOT}" "Select the third party catalog to link with..." -de)

    if [[ ! -d "${_3DPARTY_ROOT}" ]]; then
      if [[ -z "${_3DPARTY_ROOT}" ]]; then
        echo "error: $0: third party catalog is not selected." >&2
      else
        echo "error: $0: third party catalog does not exist: `${_3DPARTY_ROOT}`" >&2
      fi
      exit 255
    fi

    Call ln -s "$BASH_SOURCE_DIR/_3dparty" "${_3DPARTY_ROOT}"

    Call ln -s "$BASH_SOURCE_DIR/_3dparty/utility/tacklelib/tacklelib/_scripts" "$BASH_SOURCE_DIR/_scripts"
    Call ln -s "$BASH_SOURCE_DIR/_3dparty/utility/tacklelib/tacklelib/cmake" "$BASH_SOURCE_DIR/cmake"
    ;;
esac

fi
