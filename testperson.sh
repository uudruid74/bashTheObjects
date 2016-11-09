#!/bin/bash
source static/oop.lib.sh
DEBUG=1
import Person

new Person Christy Name: "Christy" Age: 21 Sex: "female"
new Person Evan Name: "Evan" Age: 41 Sex: "male"

println "$(Evan.Name) is a $(Evan.Sex) aged $(Evan.Age)"
println "$(Christy.Name) is a $(Christy.Sex) aged $(Christy.Age)"
println "Stats for Evan ..."
Evan.show

assert 'kindof Person Evan'
assert '[ $Evan = $Evan ]'
assert 'kindof Person Christy'
assert '[ $Evan = $Christy ]'

