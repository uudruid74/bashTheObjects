import Tag
import Div

class Pre
	subclass Div
	
Pre::set() { :; }
Pre::dump() {
	println "<div${classname}${idtag}><pre>"
	tr '|' '\n' <<<"$content"
	println "</pre></div>"
}
