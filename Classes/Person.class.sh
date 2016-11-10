class Person
        public show
        public set
        public Name
        public Age
        public Sex
        inst var Name "Saranyan"
        inst var Age 10
        inst var Sex "Male"

Person::Person() { :; }
Person::set() { :; }
Person::Name() { println $Name; }
Person::Age() { println $Age; }
Person::Sex() { println $Sex; }
Person::show() {
	Person::Name
	Person::Age
	Person::Sex
}
