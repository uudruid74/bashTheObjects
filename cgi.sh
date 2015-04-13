#!/bin/bash
source static/oop.lib.sh
DEBUG=1

import Query
import HtmlPage
import Div

new Query cgi
new HtmlPage main title:"Cgi Test"
new Div results content:$(cgi.get big sanitize:true)
arrayText=$(cgi.dumpArray all:hello bye good night done)
new Div arrayTextDiv content:${arrayText}
new Div par1 content:"<p>hello now brown cow</p>"

main.add all:arrayTextDiv results 

main.render


