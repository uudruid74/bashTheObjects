#!/bin/bash

import Icon
import Style

class HtmlPage 

	public Title
	public Style
	public Icon
	public add
	public render

	static title "No Title Set"
	static icon ""
	static stylelist Array
	static contentlist Array
	static Singleton ""
	const CGI_Header "Content-type: text/html\n"


HtmlPage::instance() {
	return_instance $1
}

HtmlPage::HtmlPage() {
	if [[ -n $style ]]; then
		HtmlPage::add
	fi
	set_instance
}

HtmlPage::Title() { println "$title"; }
HtmlPage::dumpTitle() { 
	println "<title>$title</title>" 
}

HtmlPage::setvar() { :; }

HtmlPage::Icon() { println "$icon"; }
HtmlPage::Style() { println "$style"; }

HtmlPage::dumpStyles() {
	for sheet in "${stylelist[@]}"; do
		debug 3 "####### ${#stylelist[@]} dumping sheet $sheet"
		if [[ -n $sheet ]]; then
			$sheet.dump
		fi
	done
}

HtmlPage::add() {
	if [[ -n $content ]]; then
		contentlist+=($content)
		debug 3 "ADD: ${#contentlist[@]} adding content [$content]"
	fi
	if [[ -n $style ]]; then
		stylelist+=("$style")
		debug 3 "${#stylelist[@]} adding style [$style]"
	fi
	if [[ -n $all ]]; then
		for c in ${all[@]}; do
			contentlist+=($c)
		done
	fi
}

HtmlPage::dumpContents() {
	assert '[ ${#contentlist[@]} -gt 0 ]'
	for object in "${contentlist[@]}"; do
		debug 3 "####### ${#contentlist[@]} dumping object [$object]"
		if [[ -n $object ]]; then
			$object.dump
		fi
	done
}

HtmlPage::dumpHeader() {
	println "<head>"
	if [[ -n $title ]]; then
		HtmlPage::dumpTitle
	fi
	if [[ ${#stylelist[@]} -gt 0 ]]; then
		HtmlPage::dumpStyles
	fi
	if [[ -n $icon ]]; then
		$icon.dump
	fi
	println "</head>"
}

HtmlPage::dumpBody() {
	println "<body>";
	HtmlPage::dumpContents
	println "</body>"
}

HtmlPage::render() {
	if [[ -n ${GATEWAY_INTERFACE} ]]; then
		println "$CGI_Header"
	fi
	println "<html>"
	HtmlPage::dumpHeader
	HtmlPage::dumpBody
	println "</html>"
}

