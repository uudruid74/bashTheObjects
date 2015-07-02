class Link
	public setURL
	public dump
	public url

	inst var url

	#- abstract rel, type

Link::setURL() { :; }
Link::url() { println $url; }
Link::Link() { :; }
Link::dump() {
	println "<link rel=\"$rel\" type=\"$type\" href=\"$url\" />"
}

