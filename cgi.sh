#!/bin/bash
source static/oop.lib.sh
DEBUG=1

new Query cgi
new HtmlPage main title: "Cgi Test"

new Div results content: $(cgi.get big sanitize:true)
arrayText=$(cgi.dump all: hello bye good night done)
new Div arrayTextDiv content: ${arrayText}
new Div par1 content: "<p>hello now brown cow</p>"

new Form userinput
userinput.text prompt: "Username" value: "Me"
userinput.append value: "<br />"
userinput.text prompt: "Password"
userinput.append value: "<br />"
userinput.submit url: "submit.php" value:"OK"

main.add all: arrayTextDiv userinput results

main.render


