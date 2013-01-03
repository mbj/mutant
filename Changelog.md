# v0.2.10 2013-01-03

* [fixed] Do not mutate receivers away when message name is a keyword

[Compare v0.2.9..v0.2.10](https://github.com/mbj/mutant/compare/v0.2.9...v0.2.10)

# v0.2.9 2013-01-02

* [feature] Mutate instance and global variable assignments
* [feature] Mutate super calls

[Compare v0.2.8..v0.2.9](https://github.com/mbj/mutant/compare/v0.2.8...v0.2.9)

# v0.2.8 2012-12-29

* [feature] Do not mutate argument or local variable names beginning with an underscore
* [feature] Mutate unary calls ```coerce(object)``` => ```object```
* [feature] Mutate method call receivers ```foo.bar``` => ```foo```

[Compare v0.2.7..v0.2.8](https://github.com/mbj/mutant/compare/v0.2.7...v0.2.8)

# v0.2.7 2012-12-21

* [fixed] Use latest adamantium and ice_nine

[Compare v0.2.6..v0.2.7](https://github.com/mbj/mutant/compare/v0.2.6...v0.2.7)

# v0.2.6 2012-12-14

* [fixed] Correctly set file and line of injected mutants

[Compare v0.2.5..v0.2.6](https://github.com/mbj/mutant/compare/v0.2.5...v0.2.6)

# v0.2.5 2012-12-12

* [feature] Add --debug flag for showing killer output and mutation
* [feature] Run noop mutation per subject to guard against initial failing specs
* [feature] Mutate default into required arguments
* [feature] Mutate default literals
* [feature] Mutate unwinding of pattern args ```|(a, b), c|``` => ```|a, b, c|```
* [feature] Mutate define and block arguments
* [feature] Mutate block arguments, inklusive pattern args
* [feature] Recurse into block bodies
* [change] Unvendor inflector use mbj-inflector from rubygems
* [fixed] Insert mutations at correct constant scope
* [fixed] Crash on mutating yield, added a noop for now
* [fixed] Crash on singleton methods defined on other than constants or self

[Compare v0.2.4..v0.2.5](https://github.com/mbj/mutant/compare/v0.2.4...v0.2.5)

# v0.2.4 2012-12-12

* [fixed] Correctly vendor inflector

[Compare v0.2.3..v0.2.4](https://github.com/mbj/mutant/compare/v0.2.3...v0.2.4)

# v0.2.3 2012-12-08

* [fixed] Prepend extra elements to hash and array instead of append. This fixes unkillable mutators in parallel assignments!

[Compare v0.2.2..v0.2.3](https://github.com/mbj/mutant/compare/v0.2.2...v0.2.3)

# v0.2.2 2012-12-07

* [feature] Add a shitload of operator expansions for dm2 strategy

[Compare v0.2.1..v0.2.2](https://github.com/mbj/mutant/compare/v0.2.1...v0.2.2)

# v0.2.1 2012-12-07

* [fixed] Crash on unavailable source location
* [fixed] Incorrect handling of if and unless statements 
* [fixed] Expand Foo#initialize to spec/unit/foo in rspec dm2 strategy
* [fixed] Correctly expand [] to element_reader_spec.rb in rspec dm2 strategy
* [fixed] Correctly expand []= to element_writer_spec.rb in rspec dm2 strategy
* [fixed] Correctly expand foo= to foo_writer_spec.rb in rspec dm2 strategy

[Compare v0.2.0..v0.2.1](https://github.com/mbj/mutant/compare/v0.2.0...v0.2.1)

# v0.2.0 2012-12-07

First public release!
