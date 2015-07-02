#!/bin/bash


class Dictionary
	public get
	public set
	public first
	public count
	public iterateEval
	public dump

	static Hash paramArray

Dictionary::Dictionary() { }

Dictionary::get() {
	println "${paramArray[$value]}"
}

Dictionary::set() {
	for var in $vars; do
		paramArray[$var]="${!var}"
	done
}

Dictionary::count() {
	return ${#paramArray[*]}
}

Dictionary::first() {
	# parameter passed will be the var to hold an iterator
	# need to add a "last" function and iterators will need
	# next, prev, get, set, and insert (reverse do).
	# this also requires some form of "block" with "do"
}

Dictionary::dump() {
	for element in ${all[@]}; do
		println $element
	done
}


