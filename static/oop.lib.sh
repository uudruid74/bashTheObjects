#!/bin/bash

# ---------------------------------------------------------------------------
# OO support functions
# Original implementation by Pim van Riezen <pi@madscience.nl>
#
# Extra bugs & kludges by Evan K Langlois <uudruid74@gmail.com>
#   more specifically, debug, assert, subclass, constant, static, public,
#   named params, print/println, import, kindof, implements, and destroy
#   I may eventually change it to utilize hashes so it doesn't clutter
#   up the namespace so bad, but it doesn't matter much.  This whole file
#   is a HACK!  Do NOT edit anything in here.  You probably don't even want
#   to read anything in here.  It's ugly!  The code it supports is what we
#   want to be beautiful and pretty.
#
# Parameters are passed by name.  You may also use a single parameter
#	which will be passed as the "value" variable.  You can get a list of
#	all set parameters in the "vars" variable.
#
# 		*** WARNING ***				*** WARNING ***
# WARNING: This code has lots of evals and other tricks.  It is NOT
# suitable for public websites or any other case where security is any
# concern at all!!  You have been Warned!
#
# LICENSE: This code is distributed under the Artistic license 
# ---------------------------------------------------------------------------
source "static/debug.lib.sh"

DEFCLASS=""
CLASS=""
SELF=0

#- Currently only a single dir supported
CLASSPATH="Classes"

#- Need a tool to generate object id's
if [[ -x $(which uuidgen) ]]; then
  __UUIDGEN() { local u=$(uuidgen); echo ${u//-/}; }
elif [[ -x $(which md5sum) ]]; then
  __UUIDGEN() { local u; read -rs -n 256 u </dev/urandom; echo $u | md5sum | cut -d ' ' -f 1; }
else 
  echo Install UUIDGEN or MD5SUM.  Exitting!
  exit 1
fi

copyToGlobal() {
	local from=$1
	local to=$2
	local temp=$(eval "declare -p \$from" 2>/dev/null)
  	temp="${temp/$from=/$to=}"
  	temp="${temp/--/-g}"
  	temp="${temp/-a/-ag}"
  	temp="${temp/-A/-Ag}"
  	eval "$temp"
  	local new=$(eval "declare -p \$to" 2>/dev/null)
  	debug 6 "Copied $from to $to ($temp) ($new)"
}

#- Now on to the really messy stuff

class() {
  DEFCLASS="$1"
  debug 4 "Creating new class $DEFCLASS"
  eval CLASS_${DEFCLASS}_VARS=""
  eval CLASS_${DEFCLASS}_FUNCTIONS=""
  eval CLASS_${DEFCLASS}_STATICS=""
  eval CLASS_${DEFCLASS}_CONSTS=""
  public ${DEFCLASS}	#- make constructor public?
  #- Note that you can use "destroy var" and it
  #- attempts cleanup and calls your "ondestroy" method
}

static() { #- class vars
  local varname="CLASS_${DEFCLASS}_STATICS"
  eval $varname="\"\${$varname}$2 \""
  if [[ -n $2 ]]; then
	if [[ $1 == "Array" ]]; then
		eval "declare -ag CLASS_${DEFCLASS}_$2=(\"$3\")"
	elif [[ $1 == "Hash" ]]; then
		eval "declare -Ag CLASS_${DEFCLASS}_$2['init']=\"$3\""
	elif [[ $1 == 'var' ]]; then
		eval "CLASS_${DEFCLASS}_$2=\"$3\""
	else
  		import $1
		eval "new $1 CLASS_${DEFCLASS}_$2 \"$3\""
  	fi
  fi
}

const() { #- constant class vars
  local varname="CLASS_${DEFCLASS}_CONSTS"
  eval $varname="\"\${$varname}$2 \""
  if [[ -n $2 ]]; then
    if [[ $1 == "Array" ]]; then
		eval "declare -ag CLASS_${DEFCLASS}_$2=(\"$3\")"
	elif [[ $1 == "Hash" ]]; then
		eval "declare -Ag CLASS_${DEFCLASS}_$2['init']=\"$3\""
	elif [[ $1 == 'var' ]]; then
		eval "declare -g CLASS_${DEFCLASS}_$2=\"$3\""
	else
    	import $1
    	eval "new $1 CLASS_${DEFCLASS}_$2 \"$3\""
    	eval "declare -g CLASS_${DEFCLASS}_$2"
    fi
  fi
}

#- NOTE: public is to make a function public.  You can always call the raw
#- class:: functions from within the same class instead of going through
#- the SELF pointer (protected is not yet supported).  I will likely add
#- a way to do this for all defined functions with declare | grep -f $CLASS
#- Public functions don't require the variable name prefix when called from
#- inside another class function.

public() {
  debug 5 "Making $1 public"
  local varname="CLASS_${DEFCLASS}_FUNCTIONS"
  eval "$varname=\"\${$varname}$1 \""
}

inst() {	#- instance vars
  local varname="CLASS_${DEFCLASS}_VARS"
  eval $varname="\"\${$varname}$2 \""
  if [[ -n $2 ]]; then
	if [[ $1 == "Array" ]]; then
		eval "declare -ag INIT_${DEFCLASS}_$2=(\"$3\")"
	elif [[ $1 == "Hash" ]]; then
		eval "declare -Ag INIT_${DEFCLASS}_$2['init']=\"$3\""
	elif [[ $1 == "var" ]]; then
		eval "INIT_${DEFCLASS}_$2=\"$3\""
	else
		import $1
		eval "new $1 INIT_${DEFCLASS}_$2 \"$3\""
	fi
  fi
}

loadvar() {
  debug 4 "Loading Variables for object $SELF"
  eval "varlist=\"\$CLASS_${CLASS}_VARS\""
  for var in $varlist; do
  	copyToGlobal INSTANCE_${SELF}_${var} $var
  done
  eval "varlist=\"\$CLASS_${CLASS}_STATICS\""
  for var in $varlist; do
	copyToGlobal CLASS_${CLASS}_${var} $var
  done
  eval "varlist=\"\$CLASS_${CLASS}_CONSTS\""
  for var in $varlist; do
	copyToGlobal CLASS_${CLASS}_${var} $var
  done
  cbreak
}

loadfunc() {
  eval "funclist=\"\$CLASS_${CLASS}_FUNCTIONS\""
  for func in $funclist; do
    eval "${func}() { ${CLASS}::${func} \$@; return \$?; }"
  done
}

savevar() {
  debug 4 "Saving variables in object $SELF"
  eval "varlist=\"\$CLASS_${CLASS}_VARS\""
  for var in $varlist; do
  	copyToGlobal $var INSTANCE_${SELF}_${var}
  	unset $var
  done
  eval "varlist=\"\$CLASS_${CLASS}_STATICS\""
  for var in $varlist; do
	copyToGlobal $var CLASS_${CLASS}_${var}
  	unset $var
  done
  cbreak
}

typeof() {
  local var=$1
  eval "local uuid=\$$var"
  eval println \${TYPEOF_$uuid}
}

kindof() { # kindof class varname
  local var=$2
  local type=$1
  eval "local uuid=\$$var"
  eval "local class=\${TYPEOF_$uuid}"
  while [[ -n $class ]]; do
    if [[ $type == $class ]]; then
      return 0;
    fi
    eval "class=\"\$SUPER_$class\""
  done
  return 1;
}

implements() { # implements funcname variable
  local var=$2
  local func=$1
  eval "self=\$$var"
  eval "CLASS=\${TYPEOF_$self}"
  classhas "$func" "$CLASS"
  return $?;		#- failed
}

classhas() {		#- like implements, but for a class
  local CLASS=$2
  local func=$1
  while [[ -n $CLASS ]]; do
    eval "funclist=\"\$CLASS_${CLASS}_FUNCTIONS\""
    for funcname in $funclist; do
      if [[ $funcname == $func ]]; then
        return 0;	#- found
      fi
    done
  done
  return 1;		#- failed
}

fn_exists() {
    declare -f -F $1 > /dev/null
    return $?
}

callMethod() { 		#- Named arguments now seperates value from var
	local SAVESELF="$SELF"
	local SELF="$1"
	local CNAME="$CLASS"
	local CLASS="$2"
	local FNAME="$3"
	shift 3
	local tempvalue
	local tempvar
	local rt

	debug 5 "callMethod: $CLASS::$FNAME"
	loadvar; loadfunc

	debug 3 "Arglist = ${arglist[*]}"
	for arg in "${arglist[@]}"; do
		debug 3 "Command Arg Parsing [$arg]"
		if [[ $arg == *: ]]; then
			tempvar="${arg%:*}"
			tempvalue=''
			if [[ $tempvar == "all" ]]; then
				local all; declare -a all=('')
			fi
			continue
		else
			if [[ -z $tempvar ]]; then
				tempvar="value"
				tempvalue="$arg"
			elif [[ $tempvar == "all" ]]; then
				all+=("${arg}")
			else
				tempvalue="$arg"
			fi
		fi
		if [[ $tempvar != "all" ]]; then
			eval "local $tempvar=\"$tempvalue\""
			debug 6 "Setting $tempvar=$tempvalue"
			eval "vars=\"\$vars $tempvar\""
		else
			debug 6 "all=${all[*]}"
		fi
	done
	while ! fn_exists "${CLASS}::${FNAME}"; do
		local newclass
		debug 3 "${CLASS}::${FNAME} does not exist"
		eval "newclass=\"\$SUPER_$CLASS\""
		if [[ -z $newclass ]]; then
			debug 2 "Can't find superclass for ${CLASS}"
			break
		else
			debug 3 "Changed CLASS to $newclass"
			CLASS="%newclass"
		fi
	done
	debug 6 "Arguments complete - calling ${CLASS}::${FNAME} all=${all[*]}"
	eval "${CLASS}::${FNAME}"
	rt=$?
	savevar
	CLASS=$CNAME
	SELF=$SAVESELF
	return $rt
}

new() {
  import $1
  local _objclass="$1"
  local varname="$2"
  shift 2
  debug 5 "NEW ${_objclass} ${varname}"
  local _uuid=$(__UUIDGEN)
  eval TYPEOF_${_uuid}=$_objclass
  eval $varname=$_uuid
  local _funclist
  eval "_funclist=\"\$CLASS_${_objclass}_FUNCTIONS\""
  for _func in $_funclist; do
    eval "${varname}.${_func}() { local arglist=(\"\${@}\"); callMethod $_uuid $_objclass $_func; }"
  done
  local _varlist
  eval "_varlist=\"\$CLASS_${_objclass}_VARS\""
  for _var in $_varlist; do
    eval "INSTANCE_${_uuid}_${_var}=\"\$INIT_${_objclass}_${_var}\""
  done
  eval "${varname}.${_objclass} \$@ || true"
  savevar
}

#- for use by classes only, should have a "static instance"
set_instance() {
	instance="$SELF"
}

#- called from Class::instance to set a variable to the singleton
return_instance() {
	local funclist
	local class=$(eval "println \${TYPEOF_$instance}")
	eval "$1=\"$instance\""
	eval "funclist=\"\$CLASS_${class}_FUNCTIONS\""

    for func in $funclist; do
      eval "$1.${func}() { arglist=(\"\${@}\"); callMethod \"$instance\" \"$class\" \"$func\"; }"
    done
}

destroy() {	# function to call destructors
  local varname="$1"
  eval "SELF=\$$1"
  local varlist
  if implements ondestroy $varname; then
    eval "$varname.ondestroy"
  fi
  eval "varlist=\"\$CLASS_${CLASS}_VARS\""
  for var in $varlist; do
    eval "unset INSTANCE_${SELF}_$varname"
  done
  eval "unset $varname"
}

import() {
  local DEFCLASS_SAVE=$DEFCLASS
  if [ -z "$(eval println \$CLASS_$1_FUNCTIONS)" ]; then
  	source "$CLASSPATH/$1.class.sh"
    debug 4 "Importing $CLASSPATH/$1.class.sh"
  else
    debug 4 "Class already loaded"
  fi
  DEFCLASS=$DEFCLASS_SAVE
}

subclass() { 		#- this is probably really broken
	import $1
    local funclist
    local SUPERCLASS="$1"
    eval "SUPER_${DEFCLASS}=\"${SUPERCLASS}\""
    debug 3 "Set superclass of [${SUPERCLASS}] to [${DEFCLASS}]"
    eval "funclist=\"\${CLASS_${SUPERCLASS}_FUNCTIONS}\""
    for func in $funclist; do
      eval "public $func"
      current_definition=$(declare -f $1::${func})
      current_definition=${current_definition#*\{}
      current_definition=${current_definition%\}}
      if [[ -z ${current_definition} ]]; then
        current_definition=':;';
      fi
      eval "${DEFCLASS}::${func}() { ${current_definition} }"
    done
    current_definition=$(declare -f $1::$1)
    current_definition=${current_definition#*\{}
    current_definition=${current_definition%\}}
    if [[ -z $current_definition ]]; then
      current_definition=":;"
    fi
    eval "${DEFCLASS}::${DEFCLASS}() { ${current_definition} }"

  eval "varlist=\"\$CLASS_${SUPERCLASS}_VARS\""
  debug 4 "SUBCLASSING ${DEFCLASS} with ${SUPERCLASS} using $varlist"
  for var in $varlist; do
  	debug 4 "class $DEFCLASS->$SUPERCLASS Var: $var"
    eval "INIT_${DEFCLASS}_${var}=\"\$INIT_${SUPERCLASS}_${var}\""
  done
  eval "CLASS_${DEFCLASS}_VARS=\"\$CLASS_${SUPERCLASS}_VARS\""

  eval "varlist=\"\$CLASS_${SUPERCLASS}_STATICS\""
  for var in $varlist; do
    eval "CLASS_${DEFCLASS}_$var=\"\$CLASS_${SUPERCLASS}_$var\""
  done
  eval "CLASS_${DEFCLASS}_STATICS=\"\$CLASS_${SUPERCLASS}_STATICS \$CLASS_${DEFCLASS}_STATICS\""

  eval "varlist=\"\$CLASS_${SUPERCLASS}_CONSTS\""
  for var in $varlist; do
    eval "CLASS_${DEFCLASS}_$var=\"\$CLASS_${SUPERCLASS}_$var\""
  done
  eval "CLASS_${DEFCLASS}_CONSTS=\"\$CLASS_${SUPERCLASS}_CONSTS \$CLASS_${DEFCLASS}_CONSTS\""
}

