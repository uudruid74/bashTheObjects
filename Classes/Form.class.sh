class Form 

	public head
	public foot
	public append
	public width
	public text
	public radio
	public submit
	public set
	public dump

	inst var prefix
	inst var formData
	inst var postfix
	inst var classname
	inst var idtag
	inst var action

	static var fieldwidth "20"

Form::Form() {
	 if [[ -n $class ]]; then
		classname=" class=\"$class\""
	 fi
	 if [[ -n $id ]]; then
		idtag=" id=\"$id\""
	 else
		idtag=" id=\"$varname\""
	 fi
}

Form::width() {
	fieldwidth=$value
}

Form::head() { 
	local content
	if [[ -x $content ]]; then
		content=$value;
	fi
	prefix=$content; 
}

Form::foot() {
	local content
	if [[ -z $content ]]; then
		content=$value
	fi
	postfix=$content; 
}

Form::append() {
	local content
	if [[ -z $content ]]; then
		content=$value
	fi
	formData="${formData}${content}";
}

Form::text() {
	type="text"
	Form::Field
}

Form::radio() {
	type="radio"
	if [[ -n $checked ]]; then
		checked="checked"
	fi
	Form::Field
}

Form::submit() {
	type="submit"
	if [[ -n $url ]]; then
		action=$url
	fi
	Form::Field
}

Form::Field() {
	local name
	local width
	local default

	if [[ -z $name ]]; then
		name=$prompt
	fi
	if [[ -z $name ]]; then
		name=$type
	fi
	if [[ -z $width ]]; then
		width=$fieldwidth;
	fi
	if [[ -z $default ]]; then
		default=$value;
	fi
	if [[ -z $default ]] && [[ -n ${paramArray[$name]} ]]; then
		default=${paramArray[$name]}
	fi

	formData="${formData}${prompt} <input type=\"$type\" \
name=\"$name\" width=\"$width\" value=\"$default\" $checked/>\n"
}

Form::dump() {
	println "<form${classname}${idtag} action=\"$action\">
${prefix}${formData}${postfix}</form>\n"
}


