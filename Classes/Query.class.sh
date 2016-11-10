#!/bin/bash

class Query
	public get
	public encode
	public decode
	public sanitize
	public dump
	public values

	static Hash paramArray

Query::Query() {
	declare -a temparray
	local saveIFS=$IFS
	IFS='=&'
	temparray=($QUERY_STRING)
	for (( i=0; i<${#temparray[@]}; i+=2 ))
	do
		paramArray[${temparray[i]}]="${temparray[i+1]}"
	done
	IFS=$saveIFS
}

Query::get() {
	if [[ -n $QUERY_STRING ]]; then
		if [[ $sanitize == true ]]; then
			value=${paramArray[$value]}
			println "$(Query::sanitize)"
		else
			println "${paramArray[$value]}"
		fi
	else
		read -e -p "Enter value for $value=" value
		println "$value"
	fi
}

Query::sanitize() {
	#- probably needs work
	local clean
	clean=${value//\.\./}
	clean=${clean//[;\|\/$]/}
	println $clean
}

Query::encode() {
    local length="${#value}"
    for (( i = 0; i < length; i++ )); do
        local c="${value:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c"
        esac
    done
}
 
Query::decode() {
    local url_encoded="${value//+/ }"
    printf '%b' "${url_encoded//%/\x}"
}

Query::dump() {
	for element in ${all[@]}; do
		println "$element=${paramArray[$element]}\n"
	done
}

#- Other Environment Vars available
#-----------------------------------------------
#- SERVER_SIGNATURE=
#- HTTP_KEEP_ALIVE=300
#- HTTP_USER_AGENT=Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.7.12) Gecko/20050922 Fedora/1.7.12-1.3.1
#- SERVER_PORT=80
#- HTTP_HOST=localhost
#- DOCUMENT_ROOT=/var/www/html
#- HTTP_ACCEPT_CHARSET=ISO-8859-1,utf-8;q=0.7,*;q=0.7
#- SCRIPT_FILENAME=/var/www/cgi-bin/env.sh
#- REQUEST_URI=/cgi-bin/env.sh?namex=valuex&namey=valuey&namez=valuez
#- SCRIPT_NAME=/cgi-bin/env.sh
#- HTTP_CONNECTION=keep-alive
#- REMOTE_PORT=37958
#- PATH=/sbin:/usr/sbin:/bin:/usr/bin
#- PWD=/var/www/cgi-bin
#- SERVER_ADMIN=root@localhost
#- HTTP_ACCEPT_LANGUAGE=en-us,en;q=0.5
#- HTTP_ACCEPT=text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
#- REMOTE_ADDR=198.168.93.176
#- SHLVL=1
#- SERVER_NAME=localhost
#- SERVER_SOFTWARE=Apache/2.2.3 (CentOS)
#- QUERY_STRING=namex=valuex&namey=valuey&namez=valuez
#- SERVER_ADDR=192.168.93.42
#- GATEWAY_INTERFACE=CGI/1.1
#- SERVER_PROTOCOL=HTTP/1.1
#- HTTP_ACCEPT_ENCODING=gzip,deflate
#- REQUEST_METHOD=GET 
