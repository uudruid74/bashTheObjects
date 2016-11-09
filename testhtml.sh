#!/bin/bash

source static/oop.lib.sh
DEBUG=2

import HtmlPage
import Div

new HtmlPage Page title: Testing
new Div main content: "This is a div!" class: "fullsize"

new Div random content: "testing" class: "inner"
new Div random2 content: $(random.dump) class: "outer"
Page.add content: random2

new Style globalStyle url: "install/theme.css"
new Style mainStyle url: "install/fullsizediv.css"

Page.add style: globalStyle
Page.add style: mainStyle content: main

#- example of fetching singleton instance
new Style buttonStyle url: "install/button.css"
HtmlPage::instance gipage
gipage.add style: buttonStyle

Page.render

