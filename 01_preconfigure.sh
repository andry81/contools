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
    Call "${COMSPEC//\\//}" /c "$CONFIGURE_ROOT/01_preconfigure.bat" $@
    exit $?
    ;;
  *)
    echo "1. Download the local third party project: `contools--3dparty`: `https://sf.net/p/tacklelib/3dparty`"
    echo "2. Read the instructions from the readme file in the downloaded project to checkout third party sources."
    echo "3. Press any key to continue and select the `_src` subdirectory in the `contools--3dparty` project as a third party catalog."

    Pause

    _3DPARTY_ROOT=$("$UTILITY_ROOT/wxFileDialog" "" "$CONFIGURE_ROOT" "Select the third party catalog to link with..." -de)

    if [[ ! -d "$_3DPARTY_ROOT" ]]; then
      if [[ -z "$_3DPARTY_ROOT" ]]; then
        echo "error: $0: third party catalog is not selected." >&2
      else
        echo "error: $0: third party catalog does not exist: `$_3DPARTY_ROOT`" >&2
      fi
      exit 255
    fi

    Call ln -s "$CONFIGURE_ROOT/_3dparty" "$_3DPARTY_ROOT"

    Call ln -s "$CONFIGURE_ROOT/_3dparty/utility/tacklelib/tacklelib/_scripts" "$CONFIGURE_ROOT/_scripts"
    Call ln -s "$CONFIGURE_ROOT/_3dparty/utility/tacklelib/tacklelib/cmake" "$CONFIGURE_ROOT/cmake"
    ;;
esac

fi
