#!/bin/bash
source static/oop.lib.sh

new Query cgi
new HtmlPage main title: "Traceroute" refresh: 1
destination=$(cgi.get q)
if [[ ! -z $destination ]]; then
	if [[ ! -r "/tmp/traceresults.$destination" ]]; then
		(traceroute $destination ; echo DONE) \
			>/tmp/traceresults.$destination & 
		(sleep 300 && rm /tmp/traceresults.$destination) &
		sleep 1
	fi
	new Pre results
	precontent="$(tr '\n*' '|-' <"/tmp/traceresults.$destination")"
	if grep 'DONE'<<<"$precontent" >/dev/null; then
		main.norefresh
	fi
	results.setContent content: "$precontent"
else
	new Div results content: "No Destination Specified<br />"
fi
main.add all: results reloader
main.header add: "<style>body { background-color: black; color: yellow; } </style>"
main.render
