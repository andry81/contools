#!/bin/bash_entry

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Build scripts component library, implements component functions and variables
# for the build scripts.

# Script can be ONLY included by "source" command.
[[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) && (-z "$SOURCE_CONTOOLS_BUILDLIBCOMPONENTS_SH" || SOURCE_CONTOOLS_BUILDLIBCOMPONENTS_SH -eq 0) ]] || return 0 || exit 0 # exit to avoid continue if the return can not be called

SOURCE_CONTOOLS_BUILDLIBCOMPONENTS_SH=1 # including guard

if [[ -z "$SOURCE_TACKLELIB_BASH_TACKLELIB_SH" || SOURCE_TACKLELIB_BASH_TACKLELIB_SH -eq 0 ]]; then
  # builtin search
  for BASH_SOURCE_DIR in "/usr/local/bin" "/usr/bin" "/bin"; do
    [[ -f "$BASH_SOURCE_DIR/bash_tacklelib" ]] && {
      source "$BASH_SOURCE_DIR/bash_tacklelib" || exit $?
      break
    }
  done
fi

tkl_include_or_abort '__init__.sh'
tkl_include_or_abort "$TACKLELIB_BASH_ROOT/tacklelib/baselib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/traplib.sh"

function GetUtilityVersion()
{
  local AppName="$1"
  local AppFilePath="$2"

  if [[ -z "$AppFilePath" || ! -x "$AppFilePath" ]]; then
    echo "Not found or not executable."
    ExitWithError 128 "$TargetScriptFileName: error: can't get $AppName utility version, \"$AppFilePath\" is not found"
  fi

  # drop return value
  RETURN_VALUE=()

  local AppCurVerStr
  case "$AppName" in
    "DejaGnu")
      AppCurVerStr="`"$AppFilePath" --version 2>/dev/null |
        eval /bin/perl.exe "'$CONTOOLS_ROOT/sar.pl'" $DejaGnuVersionPattern1`"
    ;;

    *)
      AppCurVerStr="(`"$AppFilePath" --version 2>/dev/null |
        eval /bin/perl.exe "'$CONTOOLS_ROOT/sar.pl'" $CommonVersionPattern1`)"
    ;;
  esac

  eval "RETURN_VALUE=(`echo "$AppCurVerStr" |
    eval /bin/perl.exe "'$CONTOOLS_ROOT/sar.pl'" $CommonVersionParsePattern1`)"
}

function GetLibVersion()
{
  # drop return value
  RETURN_VALUE=()

  local AppName="$1"

  function LocalReturn()
  {
    rm -f "/tmp/test${TargetScriptProcId}.c"
    rm -f "/tmp/test${TargetScriptProcId}.exe"
  }

  # override RETURN with other traps restore
  PushTrapFunctionMove "$DefaultTrapsStackName" LocalReturn RETURN || return 253

  cat > "/tmp/test${TargetScriptProcId}.c"

  GetAppPath "gcc.exe"
  local GccPath="$RETURN_VALUE"

  if [[ -z "$GccPath" || ! -x "$GccPath" ]]; then
    ExitWithError 129 "$TargetScriptFileName: error: GNU C compiler is not found."
  fi

  "$GccPath" "/tmp/test${TargetScriptProcId}.c" -o "/tmp/test${TargetScriptProcId}.exe" >/dev/null
  LastError=$?
  if (( LastError )); then
    ExitWithError 130 "$TargetScriptFileName: error: ($LastError): can't get $AppName development version, GCC is returned error."
  fi

  local AppCurVerStr="`"/tmp/test${TargetScriptProcId}.exe"`"
  if [[ -z "$AppCurVerStr" ]]; then
    ExitWithError 131 "$TargetScriptFileName: error: $AppName development version is not found."
  fi

  RETURN_VALUE=($AppCurVerStr)
}

### Check library header ###
function CheckLibHeader()
{
  local LibName="$1"
  local LibHeader="$2"

  function LocalReturn()
  {
    rm -f "/tmp/test${TargetScriptProcId}.c"
    rm -f "/tmp/test${TargetScriptProcId}.exe"
  }

  # override RETURN with other traps restore
  PushTrapFunctionMove "$DefaultTrapsStackName" LocalReturn RETURN || return 253

  echo -n "Checking $LibName header... "

  cat > "/tmp/test${TargetScriptProcId}.c"

  GetAppPath "gcc.exe"
  local GccPath="$RETURN_VALUE"

  if [[ -z "$GccPath" || ! -x "$GccPath" ]]; then
    ExitWithError 132 "$TargetScriptFileName: error: GNU C compiler is not found."
  fi

  "$GccPath" "/tmp/test${TargetScriptProcId}.c" -o "/tmp/test${TargetScriptProcId}.exe" >/dev/null
  LastError=$?
  if (( LastError )); then
    echo "Error."
    ExitWithError 133 "$TargetScriptFileName: error: $LibName header \"$LibHeader\" is not found."
  fi

  echo "(\"$LibHeader\") Ok."
}

### Check utility or library version ###
function CheckAppVersion()
{
  local VersionType="$1"

  function LocalReturn()
  {
    echo "Error."
  }

  # override RETURN with other traps restore
  PushTrapFunctionMove "$DefaultTrapsStackName" LocalReturn RETURN || return 253

  # drop value
  RETURN_VALUE=()

  local AppPath=""
  case "$VersionType" in
    "util")
      local AppName="$2"
      local AppFileName="$3"
      local AppAttributeVarName="$4"
      local MinVerAssertLevel="${5:-0}"

      GetAppPath "$AppFileName"
      AppPath="$RETURN_VALUE"

      echo -n "Checking $AppName version... "

      GetUtilityVersion "$AppName" "$AppPath"
    ;;

    "lib")
      local AppName="$2"
      local AppPath="$3"
      local AppAttributeVarName="$4"
      local MinVerAssertLevel="${5:-0}"

      echo -n "Checking $AppName library version... "

      GetLibVersion "$AppName"
    ;;
  esac

  PopTrap "$DefaultTrapsStackName" RETURN

  local AppCurVerArr=("${RETURN_VALUE[@]}")
  local AppCurVerStr
  
  local arg
  local IFS='.-'$' \t'
  for arg in ${AppCurVerArr[@]}; do
    AppCurVerStr="$AppCurVerStr${AppCurVerStr:+ }$arg"
  done

  eval declare "AppCurVerArr=($AppCurVerStr)"
  AppCurVerStr="$(IFS="."; echo -n "${AppCurVerArr[*]}")"

  AssocGet 0 "$AppAttributeVarName" "minVer"
  local AppMinVerArr
  AppMinVerArr=()
  [[ "$RETURN_VALUE" == "0" ]] || eval declare "AppMinVerArr=($RETURN_VALUE)"

  GetVerStrFromArr "${AppMinVerArr[@]}"
  local AppMinVerStr="$RETURN_VALUE"

  AssocGet 0 "$AppAttributeVarName" "maxVer"
  local AppMaxVerArr
  AppMaxVerArr=()
  [[ "$RETURN_VALUE" == "0" ]] || eval declare "AppMaxVerArr=($RETURN_VALUE)"

  GetVerStrFromArr "${AppMaxVerArr[@]}"
  local AppMaxVerStr="$RETURN_VALUE"

  if (( ! ${#AppMinVerArr[@]} && ! ${#AppMaxVerArr[@]} )); then
    echo "(\"$AppPath\" - $AppCurVerStr) Ignored."
    return
  fi

  local AppErrorSubstr="$AppMinVerStr or higher"

  local AppCurVerValue
  local AppCurVerSuffix
  local AppMinVerValue
  local AppMinVerSuffix
  local AppMaxVerValue
  local AppMaxVerSuffix
  local NeedExactVersion=0

  local arg
  local i

  # check minVer <= maxVer, use '~' character as the last in the ASCII characters table for comparison purposes
  if (( ${#AppMinVerArr[@]} )); then
    if (( ${#AppMaxVerArr[@]} )); then
      # normalize lengths of AppMinVerArr and AppMaxVerArr
      if (( ${#AppMinVerArr[@]} < ${#AppMaxVerArr[@]} )); then
        for (( i=${#AppMinVerArr[@]}; i<${#AppMaxVerArr[@]}; i++ )); do
          AppMinVerArr[i]=0
        done
      elif (( ${#AppMaxVerArr[@]} < ${#AppMinVerArr[@]} )); then
        for (( i=${#AppMaxVerArr[@]}; i<${#AppMinVerArr[@]}; i++ )); do
          AppMaxVerArr[i]=0
        done
      fi

      NeedExactVersion=1

      for (( i=0; i<${#AppMinVerArr[@]}; i++ )); do
        AppMinVerValue="${AppMinVerArr[i]%%[\-a-zA-Z]*}"
        AppMinVerSuffix="${AppMinVerArr[i]#$AppMinVerValue}"
        AppMaxVerValue="${AppMaxVerArr[i]%%[\-a-zA-Z]*}"
        AppMaxVerSuffix="${AppMaxVerArr[i]#$AppMaxVerValue}"

        if (( AppMaxVerValue > AppMinVerValue )) || \
          { (( AppMaxVerValue == AppMinVerValue )) && \
            [[ ! "${AppMaxVerSuffix:-${AppMinVerSuffix:+~}}" < "${AppMinVerSuffix:-${AppMaxVerSuffix:+~}}" ]]; }; then
          if (( AppMaxVerValue > AppMinVerValue )) || \
            { (( AppMaxVerValue == AppMinVerValue )) && \
              [[ "${AppMaxVerSuffix:-${AppMinVerSuffix:+~}}" > "${AppMinVerSuffix:-${AppMaxVerSuffix:+~}}" ]]; }; then
            NeedExactVersion=0
          fi
        else
          # invalidate maxVer
          NeedExactVersion=0
          AppMaxVerArr=()
          AppMaxVerStr=""
        fi
      done

      if (( ! NeedExactVersion )); then
        AppErrorSubstr="$AppMinVerStr and not equal or higher than $AppMaxVerStr"
      else
        AppErrorSubstr="$AppMaxVerStr and not higher"
      fi
    fi
  elif (( ${#AppMaxVerArr[@]} )); then
    AppErrorSubstr="less than $AppMaxVerStr"
  fi

  local IsCorrectVersion=1

  if (( ${#AppMinVerArr[@]} )); then
    # normalize lengths of AppMinVerArr and AppCurVerValue
    if (( ${#AppMinVerArr[@]} < ${#AppCurVerArr[@]} )); then
      for (( i=${#AppMinVerArr[@]}; i<${#AppCurVerArr[@]}; i++ )); do
        AppMinVerArr[i]=0
      done
    elif (( ${#AppCurVerArr[@]} < ${#AppMinVerArr[@]} )); then
      for (( i=${#AppCurVerArr[@]}; i<${#AppMinVerArr[@]}; i++ )); do
        AppCurVerArr[i]=0
      done
    fi

    i=0

    for arg in "${AppMinVerArr[@]}"; do
      AppMinVerValue="${arg%%[\-a-zA-Z]*}"
      AppMinVerSuffix="${arg#$AppMinVerValue}"
      [[ -z "$AppMinVerValue" ]] && AppMinVerValue=0
      AppCurVerValue="${AppCurVerArr[i]%%[\-a-zA-Z]*}"
      AppCurVerSuffix="${AppCurVerArr[i]#$AppCurVerValue}"
      [[ -z "$AppCurVerValue" ]] && AppCurVerValue=0

      #echo "AppCurVer: $i: -$AppCurVerValue- -$AppCurVerSuffix-"
      #echo "AppMinVer: $i: -$AppMinVerValue- -$AppMinVerSuffix-"

      if (( AppMinVerValue > AppCurVerValue )) || \
        { (( AppMinVerValue == AppCurVerValue )) && \
          [[ "${AppMinVerSuffix:-${AppCurVerSuffix:+~}}" > "${AppCurVerSuffix:-${AppMinVerSuffix:+~}}" ]]; }; then
        IsCorrectVersion=0
        break
      elif (( AppMinVerValue < AppCurVerValue )) || \
        { (( AppMinVerValue == AppCurVerValue )) && \
          [[ "${AppMinVerSuffix:-${AppCurVerSuffix:+~}}" < "${AppCurVerSuffix:-${AppMinVerSuffix:+~}}" ]]; }; then
        break
      fi

      (( i++ ))
    done
  fi

  if (( IsCorrectVersion && ${#AppMaxVerArr[@]} )); then
    # normalize lengths of AppCurVerValue and AppMaxVerArr
    if (( ${#AppCurVerValue[@]} < ${#AppMaxVerArr[@]} )); then
      for (( i=${#AppCurVerValue[@]}; i<${#AppMaxVerArr[@]}; i++ )); do
        AppCurVerValue[i]=0
      done
    elif (( ${#AppMaxVerArr[@]} < ${#AppCurVerValue[@]} )); then
      for (( i=${#AppMaxVerArr[@]}; i<${#AppCurVerValue[@]}; i++ )); do
        AppMaxVerArr[i]=0
      done
    fi

    IsCorrectVersion=-1 # unknown
    i=0

    for arg in "${AppMaxVerArr[@]}"; do
      AppMaxVerValue="${arg%%[\-a-zA-Z]*}"
      AppMaxVerSuffix="${arg#$AppMaxVerValue}"
      [[ -z "$AppMaxVerValue" ]] && AppMaxVerValue=0
      AppCurVerValue="${AppCurVerArr[i]%%[\-a-zA-Z]*}"
      AppCurVerSuffix="${AppCurVerArr[i]#$AppCurVerValue}"
      [[ -z "$AppCurVerValue" ]] && AppCurVerValue=0

      #echo "AppCurVer: $i: -$AppCurVerValue- -$AppCurVerSuffix-"
      #echo "AppMaxVer: $i: -$AppMaxVerValue- -$AppMaxVerSuffix-"

      if (( AppCurVerValue > AppMaxVerValue )) || \
        { (( AppCurVerValue == AppMaxVerValue )) && \
          [[ "${AppCurVerSuffix:-${AppMaxVerSuffix:+~}}" > "${AppMaxVerSuffix:-${AppCurVerSuffix:+~}}" ]]; }; then
        IsCorrectVersion=0
        break
      elif (( AppMaxVerValue > AppCurVerValue )) || \
        { (( AppCurVerValue == AppMaxVerValue )) && \
          [[ "${AppCurVerSuffix:-${AppMaxVerSuffix:+~}}" < "${AppMaxVerSuffix:-${AppCurVerSuffix:+~}}" ]]; }; then
        IsCorrectVersion=1
        break
      fi

      (( i++ ))
    done

    if (( IsCorrectVersion < 0 )); then
      if (( ! NeedExactVersion )); then
        IsCorrectVersion=0
      else
        IsCorrectVersion=1
      fi
    fi
  fi

  if (( IsCorrectVersion )); then
    echo "(\"$AppPath\" - $AppCurVerStr${AppMinVerStr:+"; minVer=$AppMinVerStr"}${AppMaxVerStr:+"; maxVer=$AppMaxVerStr"}) Ok."
  else
    echo "(\"$AppPath\" - $AppCurVerStr${AppMinVerStr:+"; minVer=$AppMinVerStr"}${AppMaxVerStr:+"; maxVer=$AppMaxVerStr"}) Incorrect version."
    Assert "$MinVerAssertLevel" \
"$TargetScriptFileName: %ASSERT_LEVEL_STR%: $AppName has incorrect version: $AppCurVerStr; Required: $AppErrorSubstr."
  fi
}

function CheckUtilityVersion()
{
  CheckAppVersion "util" "$@"
}

function CheckLibVersion()
{
  CheckAppVersion "lib" "$@"
}

### OS system ###
function CheckOSSystem()
{
  echo -n "Checking OS system... "

  if [[ -z "$OSTYPE" ]]; then
    echo "Error."
    ExitWithError 134 "$TargetScriptFileName: error: OSTYPE variable is not defined."
  fi

  if [[ -z "$SystemRuntimeType" ]]; then
    echo "Error."
    ExitWithError 135 "$TargetScriptFileName: \$OSTYPE = \"$OSTYPE\"
$TargetScriptFileName: error: system runtime type is not declared by the target."
  fi

  if [[ "$OSTYPE" != "$SystemRuntimeType" ]]; then
    echo "Error."
    ExitWithError 136 "$TargetScriptFileName: \$OSTYPE = \"$OSTYPE\"
$TargetScriptFileName: error: build should run under the \"$SystemRuntimeType\" system."
  fi

  echo "(OSTYPE=\"$OSTYPE\"; \"$SystemRuntimePath\") Ok."
}

### Target system ###
function CheckTargetSystem()
{
  echo -n "Checking target system... "

  GetAppPath "uname"
  local UnamePath="$RETURN_VALUE"

  if [[ -z "$UnamePath" || ! -x "$UnamePath" ]]; then
    echo "Error."
    ExitWithError 137 "$TargetScriptFileName: error: uname executable is not found."
  fi

  if [[ -z "$SystemTargetTypePttnStr" ]]; then
    echo "Error."
    ExitWithError 138 "$TargetScriptFileName: \$SystemTargetTypePttnStr = \"$SystemTargetTypePttnStr\"
$TargetScriptFileName: error: system target type is not declared by the target."
  fi

  SystemTargetType="`"$UnamePath" -s`"

  case "$SystemTargetType" in
    $SystemTargetTypePttnStr) ;;
    *)
      echo "Error."
      ExitWithError 139 "$TargetScriptFileName: \$OSTYPE = \"$OSTYPE\"
$TargetScriptFileName: \$SystemTargetType = \"$SystemTargetType\"
$TargetScriptFileName: error: build should run under \"$SystemTargetTypePttnStr\" subsystem."
  esac

  echo "(SystemTargetType=\"$SystemTargetType\"; \"$SystemTargetTypePttnStr\") Ok."
}

### $PATH ###
function CheckVarPATH()
{
  echo -n "Checking \$PATH variable... "

  (echo "$PATH" | grep -E -i "$TargetInvalidPathCharPttnForGrep") >/dev/null
  LastError=$?

  if (( ! LastError )); then
    echo "Fixed."
    echo \
"$TargetScriptFileName: info: \$PATH=\"$PATH\"
$TargetScriptFileName: warning: variable \$PATH should not have invalid characters, fixed." >&2
  else
    echo "Ok."
  fi
}

### /mingw ###
function CheckMingwDir()
{
  if [[ "$SystemRuntimeType" == "msys" ]]; then
    echo -n "Checking \"/mingw\" directory... "

    ConvertBackendPathToNative '/mingw'
    MingwMountPath="$RETURN_VALUE"

    (echo -n "$MingwMountPath/" | tr '\134' '\057' | grep -i "`echo -n "$SystemRuntimePath/" | tr '\134' '\057'`") >/dev/null 2>&1
    LastError=$?

    if (( ! LastError )); then
      echo "Error."
      ExitWithError 140 "$TargetScriptFileName: \"/mingw\": \"$MingwMountPath\"
$TargetScriptFileName: error: \"/mingw\" directory not mounted properly."
    fi
    echo "Ok."
  fi
}

### which utility ###
function CheckUtilityWhich()
{
  echo -n "Checking \"$WhichUtility\" utility... "

  if [[ ! -f "$WhichUtility" ]]; then
    echo "Error."
    ExitWithError 141 "$TargetScriptFileName: error: \"$WhichUtility\" utility is not found."
  fi
  echo "Ok."
}

### gccmrt.sh script ###
function CheckScriptGccmrt()
{
  echo -n "Checking \"gccmrt.sh\" script... "

  local GccMrtPath="$CONTOOLS_ROOT/bash/gccmrt.sh"

  if [[ -z "$GccMrtPath" || ! -f "$GccMrtPath" ]]; then
    echo "Error."
    ExitWithError 142 "$TargetScriptFileName: error: \"gccmrt.sh\" script is not found."
  fi
  echo "(\"$GccMrtPath\") Ok."
}

### Check target configure script ###
function CheckTargetConfigureScript()
{
  echo -n "Checking target \"configure\" script... "

  if [[ ! -f "$TargetInputDirPath/configure" ]]; then
    echo "Error."
    ExitWithError 143 "$TargetScriptFileName: error: \"configure\" script is not found."
  fi
  echo "Ok."
}

### Check target file ###
function CheckTargetFile()
{
  local FileName=($1)

  echo -n "Checking target \"$FileName\" file... "

  if [[ ! -f "$TargetInputDirPath/$FileName" ]]; then
    echo "Error."
    ExitWithError 144 "$TargetScriptFileName: error: \"$TargetName\" \"$FileName\" file is not found."
  fi
  echo "Ok."
}

### Read and save GCC C compiler version into temporary file ###
function CompileGccVersionToFile()
{
  PushTargetStageExitHandler RemoveGccVersionFile

  function LocalReturn()
  {
    rm -f "/tmp/GccUsageVersion.${TargetScriptProcId}.c"
  }
  
  # override RETURN with other traps restore
  PushTrapFunctionMove "$DefaultTrapsStackName" LocalReturn RETURN || return 253

  GetGccPath
  local GccPath="$RETURN_VALUE"

  echo -n "__VERSION__" > "/tmp/GccUsageVersion.${TargetScriptProcId}.c"
  "$GccPath" -E -P "/tmp/GccUsageVersion.${TargetScriptProcId}.c" > "/tmp/GccUsageVersion.${TargetScriptProcId}.i" 2>/dev/null
  LastError=$?
  if (( LastError )); then
    echo "Error."
    ExitWithError 145 "$TargetScriptFileName: error: ($LastError): GCC returned error."
  fi

  return 0
}

### Load GCC C compiler version from temporary file ###
function LoadGccVersionFromFile()
{
  local IFS='' # enables read whole string line into a single variable

  GccUsageVersionStr=""
  if [[ -f "/tmp/GccUsageVersion.${TargetScriptProcId}.i" ]]; then
    read -r GccUsageVersionStr < "/tmp/GccUsageVersion.${TargetScriptProcId}.i"
  fi
  if [[ -z "$GccUsageVersionStr" ]]; then
    ExitWithError 146 "$TargetScriptFileName: error: can't load GccUsageVersion from file."
  fi

  return 0
}

function RemoveGccVersionFile()
{
  rm -f "/tmp/GccUsageVersion.${TargetScriptProcId}.i"
  rm -f "/tmp/GccUsageVersion.${TargetScriptProcId}.c"
}

### GCC attributes ###
function CheckGccVersion()
{
  CheckUtilityVersion 'GCC' 'gcc.exe' 'GccVerAttr' "$1"
}

### Perl attributes ###
function CheckPerlVersion()
{
  CheckUtilityVersion 'Perl' 'perl.exe' 'PerlVerAttr' "$1"
}

### GNU make attributes ###
function CheckGnuMakeAttr()
{
  CheckUtilityVersion 'GNU make' 'make.exe' 'GnuMakeVerAttr' "$1"
}

### GNU libtool attributes ###
function CheckGnuLibtoolAttr()
{
  CheckUtilityVersion 'GNU libtool' 'libtool.exe' 'GnuLibtoolVerAttr' "$1"
}

### GNU M4 attributes ###
function CheckGnuM4Attr()
{
  CheckUtilityVersion 'GNU M4' 'm4.exe' 'GnuM4VerAttr' "$1"
}

### Gettext attributes ###
function CheckGnuGettextAttr()
{
  CheckUtilityVersion 'Gettext' 'gettext.exe' 'GettextVerAttr' "$1"
}

### Flex attributes ###
function CheckFlexAttr()
{
  CheckUtilityVersion 'Flex' 'flex.exe' 'FlexVerAttr' "$1"
}

### Texinfo attributes ###
function CheckTexinfoAttr()
{
  CheckUtilityVersion 'Texinfo' 'info.exe' 'TexinfoVerAttr' "$1"
}

### TeX attributes ###
function CheckTexAttr()
{
  CheckUtilityVersion 'TeX' 'tex.exe' 'TexVerAttr' "$1"
}

### GNU Diffutils attributes ###
function CheckGnuDiffAttr()
{
  CheckUtilityVersion 'GNU Diffutils' 'diff.exe' 'GnuDiffutilsVerAttr' "$1"
}

### Patch attributes ###
function CheckPatchAttr()
{
  CheckUtilityVersion 'Patch' 'patch.exe' 'PatchVerAttr' "$1"
}

### Autoconf attributes ###
function CheckAutoconfAttr()
{
  CheckUtilityVersion 'Autoconf' 'autoconf' 'AutoconfVerAttr' "$1"
}

### Automake attributes ###
function CheckAutomakeAttr()
{
  CheckUtilityVersion 'Automake' 'automake' 'AutomakeVerAttr' "$1"
}

### Autogen attributes ###
function CheckAutogenAttr()
{
  CheckUtilityVersion 'Autogen' 'autogen.exe' 'AutogenVerAttr' "$1"
}

### DejaGnu attributes ###
function CheckDejaGnuAttr()
{
  CheckUtilityVersion 'DejaGnu' 'runtest' 'DejaGnuVerAttr' "$1"
}

### Guile attributes ###
function CheckGuileAttr()
{
  CheckUtilityVersion 'Guile' 'guile.exe' 'GuileVerAttr' "$1"
}

### Guile library attributes ###
function CheckGuileLibAttr()
{
  CheckLibHeader 'Guile' "$1" << _TESTEOF
#include <$1>
int main() { return 0; }
_TESTEOF
  CheckLibVersion 'Guile' "$1" 'GuileDevVerAttr' "$2" << _TESTEOF
#include <stdio.h>
#include <$1>
int main() { printf("%d %d %d",SCM_MAJOR_VERSION,SCM_MINOR_VERSION,SCM_MICRO_VERSION); return 0; }
_TESTEOF
}

### GNU Multiple Precision Library (GMP) library attributes ###
function CheckGnuGmpLibAttr()
{
  CheckLibHeader 'GNU Multiple Precision Library (GMP)' "$1" << _TESTEOF
#include <$1>
int main() { return 0; }
_TESTEOF
  CheckLibVersion 'GNU Multiple Precision Library (GMP)' "$1" 'GnuGMPLibDevVerAttr' "$2" << _TESTEOF
#include <stdio.h>
#include <$1>
int main() { printf("%d %d %d",__GNU_MP_VERSION,__GNU_MP_VERSION_MINOR,__GNU_MP_VERSION_PATCHLEVEL); return 0; }
_TESTEOF
}

### MPFR library attributes ###
function CheckMpfrLibAttr()
{
  CheckLibHeader 'MPFR' "$1" << _TESTEOF
#include <$1>
int main() { return 0; }
_TESTEOF
  CheckLibVersion 'MPFR' "$1" 'MpfrLibDevVerAttr' "$2" << _TESTEOF
#include <stdio.h>
#include <$1>
int main() { printf("%d %d %d",__GNU_MP_VERSION,__GNU_MP_VERSION_MINOR,__GNU_MP_VERSION_PATCHLEVEL); return 0; }
_TESTEOF
}

### GCC testsuite ###
function CheckGccTestsuite()
{
  echo -n "Checking GCC testsuite sources... "

  if [[ ! -f "$TargetInputDirPath/gcc/testsuite/README" ]]; then
    echo "Not found."
    ExitWithError 147 "$TargetScriptFileName: error: GCC testsuite sources doesn't installed or not found."
  fi
  echo "Ok."
}

### Binutils testsuite ###
function CheckBinutilsTestsuite()
{
  echo -n "Checking Binutils testsuite sources... "

  if [[ ! -f "$TargetInputDirPath/binutils/testsuite/ChangeLog" ]]; then
    echo "Not found."
    ExitWithError 148 "$TargetScriptFileName: error: Binutils testsuite sources doesn't installed or not found."
  fi
  echo "Ok."
}

### Guile testsuite ###
function CheckGuileTestsuite()
{
  echo -n "Checking Guile testsuite sources... "

  if [[ ! -f "$TargetInputDirPath/test-suite/guile-test" ]]; then
    echo "Not found."
    ExitWithError 149 "$TargetScriptFileName: error: Guile testsuite sources doesn't installed or not found."
  fi
  echo "Ok."
}

### Autogen testsuite ###
function CheckAutogenTestsuite()
{
  echo -n "Checking Autogen testsuite sources... "

  if [[ ! -f "$TargetInputDirPath/agen5/test/Makefile.in" ]]; then
    echo "Not found."
    ExitWithError 150 "$TargetScriptFileName: error: Guile testsuite sources doesn't installed or not found."
  fi
  echo "Ok."
}
