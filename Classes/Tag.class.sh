class Tag

	public setContent
	public dump
	public set

	inst var content
	inst var classname
	inst var idtag
	static var tag "-"

Tag::Tag() {
	if [[ -n $class ]]; then
		classname=" class=\"$class\""
	fi
	if [[ -n $id ]]; then
		idtag=" id=\"$id\""
	else
		idtag=" id=\"$varname\""
	fi
}

Tag::setContent() { content="$content"; }
Tag::set() { :; }
Tag::dump() {
	println "<${tag}${classname}${idtag}>$content</$tag>"
}
