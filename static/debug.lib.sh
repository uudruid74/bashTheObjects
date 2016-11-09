#!/bin/bash
#
# Little Debug Tools
#

# Save this
OIFS=$IFS

trap breakpoint INT

#- Debug Levels are :
#- 0 No Debug 			3 Warnings
#- 1 Asserts only 		4 Trace User Msgs/cbreak
#- 2 Errors 			5 Trace Every Method
#-        6 Trace Parameter Setting
#- You can also make this a filename to capture all debug messages
DEBUG=1 				#- Default; change on the fly

#- NOTE: echo is really buggy ie: print a string that starts with a dash
#- So, use the following functions instead of echo or echo -n

print() { printf "%b" "$*"; }
println() { printf "%b\n" "$*"; }
ttyout() { printf "%b" "$*" >/dev/tty; }

OUT_RED=$(tput setaf 1)		#- red
OUT_ORG=$(tput setaf 3)		#- orange
OUT_OFF=$(tput sgr0)		#- normal

assert()                  #  If condition false,
{                         #+ exit from script
                          #+ with appropriate error message.
  if [[ $DEBUG -eq 0 ]]; then
	return 0
  fi
  E_PARAM_ERR=98
  E_ASSERT_FAILED=99
  read LINE SUB FILE<<<$(caller 0)

  if [[ $# -lt 1 ]]     #  Not enough parameters passed
  then                    #+ to assert() function.
    return $E_PARAM_ERR   #  No damage done.
  fi

  if eval "$1"; then
    return 0
  else
    println "Assertion failed[$?]:  \"$1\" in $SUB from file \"$FILE\", line $LINE"
    exit $E_ASSERT_FAILED
  # else
  #   return
  #   and continue executing the script.
  fi  
}

debug() {
  read LINE SUB FILENAME <<<$(caller 0)
  # args level format args...
  # DEBUG can be a debug level or a debug filename for exhaustive logging
  if [[ -z $DEBUG || $DEBUG -eq 0 ]]; then
	return
  fi
  local level=$1
  local fmt=$2
  shift 2
  if [[ "0123456789" =~ $DEBUG ]]; then
  	if [[ $level -gt $DEBUG ]]; then
		return
  	fi
  	eval "printf \"DEBUG[$FILENAME:$SUB:$LINE]: $fmt\\\\n\" \$@" >&2
  else
	eval "printf \"DEBUG[$FILENAME:$SUB:$LINE]: $fmt\\\\n\" \$@" >>$DEBUG
  fi
}


breakpoint() {				#- Manual breakpoints, debug level 4+
	bt
	realbreak
}

cbreak() {				#- conditional breakpoint
	if [[ DEBUG -lt 4 ]]; then
		return
	fi
	realbreak
}

realbreak() {
	local CIFS=$IFS
	local LINE
	local SUB
	local FILENAME
	IFS=$OIFS
	read LINE SUB FILENAME <<<$(caller 0)
	shift
	local commandline="exit"
	ttyout $OUT_ORG
	eval "sed '${LINE}q;d' $FILENAME"
	ttyout $OUT_OFF
	while [[ -n $commandline ]]; do
		read -e -p "${OUT_RED}$SUB ($FILENAME:$LINE):${OUT_OFF} " commandline
		[[ -n $commandline ]] && eval "$commandline"
	done
	IFS=$CIFS
}

c() {					#- Content - 10 lines
	read LINE SUB FILENAME <<<$(caller 2)
	local start=$(($LINE - 5))
	ttyout $(tail -n+$start $FILENAME | head -n5)
	ttyout $OUT_ORG
	ttyout $(eval "sed '${LINE}q;d' $FILENAME")
	ttyout $OUT_OFF
	start=$(($LINE + 1))
	ttyout $(tail -n+$start $FILENAME | head -n4)
}

bt() {					#- backtrace
	local CIFS=$IFS
	local command="exit"
	local level=0
	local LINE
	local SUB="bt"
	local FILENAME
	IFS=$OIFS
	while [[ $SUB != "main" ]] && [[ -n $SUB ]]; do
		level=$((level + 1))
		read LINE SUB FILENAME <<<$(caller $level)
		eval "printf '  %.0s' >/dev/tty {1..$level}"
		ttyout "➥  $SUB ($FILENAME:$LINE)\n"
	done
	IFS=$CIFS
}


