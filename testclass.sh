#!/bin/bash
source static/oop.lib.sh

class Car
	public Car
	public set
	public Drive
	public Stop
	public Check
	public getColor
	public testpvt

	inst var color "red"
	inst var motion

Car::Car() {
	motion="Stop"
}

Car::set() { :; }
Car::Drive() { motion="Go"; }
Car::Stop() { motion="Stop"; }
Car::Check() { println "$motion"; }
Car::getColor() { println "$color"; }
Car::testpvt() { Car::pvtFunc; }
Car::pvtFunc() { println "private function of $(getColor) car"; }

class Cat
	public Cat
	public set
	public Drive
	public Stop
	public Check
	public getColor
	public setVoice
	public speak
	public ondestroy
	inst var color "black"
	inst var motion
	inst var voice "MEOW"

Cat::Cat() {
	motion="Sleeping"
}
Cat::setVoice() { voice=$value; }
Cat::speak() { println "==$voice=="; }
Cat::set() { :; }
Cat::Drive() { motion="Run"; }
Cat::Stop() { motion="Sleep"; }
Cat::Check() { println "$motion"; }
Cat::getColor() { println "$color"; }
Cat::ondestroy() { println "RWORW!!"; }

import Cat
import Car
debug 1 "Imported %s %s" "Cat" "Car"

new Car limo color: black
new Cat whiskers color: orange
new Car jag color: black
new Cat blackie

println
println "Blackie is a $(blackie.getColor) $(typeof blackie)"
println "Whiskers is a $(whiskers.getColor) $(typeof whiskers)"
println "He says $(whiskers.speak)"
whiskers.setVoice "Hisss!!!"
println "And sometimes $(whiskers.speak)"
println "Jag is a $(jag.getColor) $(typeof jag)"
jag.set color: blue
println "But I just painted the $(typeof jag) $(jag.getColor)"
println "Private ... $(jag.testpvt)"

println Testing complex arguments...
jag.set color: "light blue"


println The jag\'s color is now $(jag.getColor)
colorname="a pretty aweful shade of crap"
jag.set color: $colorname
println The jag is now $(jag.getColor)

class Kitten
	subclass Cat
	inst var size

new Kitten junior
if kindof Cat junior; then
  println "Junior is a type of CAT!"
else
  println "Junior is NOT A CAT"
fi

if kindof Car junior; then
	println "Junior is form of Car"
else
	println "Junior is NOT A CAR"
fi

println "Can he speak?"
if implements speak junior; then
  junior.speak
fi

println "Asserts ..."
assert 'kindof Cat junior'

println "junior is a $(typeof junior)"
println "He says $(junior.speak)"
println "He is $(junior.getColor)"
println "whiskers is a $(typeof whiskers)"
assert 'implements ondestroy whiskers'
destroy whiskers

#assert 'implements ondestroy whiskers'
println "whiskers is a $(typeof whiskers)"

assert '[ 5 -gt 3 ]'
assert '[ 3 -gt 5 ]'

# declare -F | grep "Cat::"
