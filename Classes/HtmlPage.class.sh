#!/bin/bash

class HtmlPage 

	public Title
	public Style
	public Icon
	public add
	public render
	public norefresh
	public header

	static var title "No Title Set"
	static var icon ""
	static var refresh ""
	static Array stylelist
	static Array contentlist
	static var Singleton ""
	inst  var headerinfo ""
	const var CGI_Header "Content-type: text/html\r\n"
	const var CGI_Redirect "Refresh: 0; url="


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
HtmlPage::norefresh() { refresh=''; }
HtmlPage::Icon() { println "$icon"; }
HtmlPage::Style() { println "$style"; }
HtmlPage::header() { headerinfo="$headerinfo\n$add"; }

HtmlPage::dumpStyles() {
	for sheet in "${stylelist[@]}"; do
		debug 3 "####### ${#stylelist[@]} dumping sheet $sheet"
		if [[ -n $sheet ]]; then
			$sheet.dump
		fi
	done
}

HtmlPage::add() {
	debug 5 "Html::add with all = ${all[*]}"
	if [[ -n $content ]]; then
		contentlist+=($content)
		debug 3 "ADD: ${#contentlist[@]} adding content [$content]"
	fi
	if [[ -n $value ]]; then
		contentlist+=($value)
		debug 3 "ADD: ${#contentlist[@]} adding content [$value]"
	fi

	if [[ -n $style ]]; then
		stylelist+=("$style")
		debug 3 "${#stylelist[@]} adding style [$style]"
	fi
	if [[ -n ${all[*]} ]]; then
		for c in ${all[@]}; do
			debug 3 "Adding content from $c"
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
	if [[ -n $refresh ]]; then
		println "<script>setTimeout(function() { location.reload(); }, 1000);</script>"
		println "<noscript><meta http-equiv=\"refresh\" content=\"$refresh\"></noscript>"
	fi
	if [[ -n $title ]]; then
		HtmlPage::dumpTitle
	fi
	if [[ ${#stylelist[@]} -gt 0 ]]; then
		HtmlPage::dumpStyles
	fi
	if [[ -n $icon ]]; then
		$icon.dump
	fi
	if [[ -n $headerinfo ]]; then
		println "$headerinfo"
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

HtmlPage::redirect() {
	if [[ -n $url ]]; then
		$value = $url
	fi
	println "${CGI_Redirect}$value\r\n${CGI_Header}\r\n\r\n";
}


