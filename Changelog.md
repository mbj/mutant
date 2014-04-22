# v0.5.11 2014-04-22

Changes:

* Fix crash on while and until without body
* Better require highjack based zombifier
* Do not mutate nthref $1 to gvar $0
* Use faster duplicate guarding hashing AST::Node intances
* Fix lots of shadowed invalid ASTs
* Fix undefine initialize warnings, Closes #175

# v0.5.10 2014-04-06

Changes:

* Fix crash on case without conditional
* Remove dependency to descendants tracker
* Add mutation #== => #eql?, #equal?
* Add mutation #eql? =>  #equal?

# v0.5.9 2014-03-28

Changes:

* Fix mutation of memoized methods with the memoizable gem.

# v0.5.8 2014-03-26

Changes:

* Fix crash on Module#name and Class#name returning non Strings

# v0.5.7 2014-03-23

Changes:

* Fix crash on invalid partial AST unparsing, closes: #164

# v0.5.6 2014-03-09

Changes:

* Correctly specifiy diff-lcs dependency

# v0.5.5 2014-03-09

Changes:

* Morpher dependency bump

# v0.5.4 2014-03-08

Changes:

* Morpher dependency bump

# v0.5.3 2014-03-05

Changes:

* mutant-rspec now supports rspec3 beta

# v0.5.2 2014-03-04

Changes:

* Use parser 2.1.6 that has its own Parser::Meta::NODE_LIST

# v0.5.1 2014-03-03

Changes:

* Remove rspec dep from main mutant gem

# v0.5.0 2014-03-02

Changes:

* Add configurable coverage expectation via --coverage (default 100%)
* rspec integration was moved into a gem 'mutant-rspec'
* Replace filters implementation with morpher predicates
* Drop --rspec option use: --use rspec instead.

# v0.4.0 2014-02-16

Status: Yanked because of broken dependencies.

# v0.3.4 2014-01-11

Changes:

* Depend on anima-0.2.0

# v0.3.4 2014-01-11

Bugfixes:

* Correctly fix crash on attribute assignments nodes: https://github.com/mbj/mutant/issues/149

# v0.3.3 2014-01-11

Changes:

* Bump dependency to unparser-0.1.8 that fixes dozens of non reported issues.

Bugfixes:

* Fix crash on attribute assignments nodes: https://github.com/mbj/mutant/issues/149

# v0.3.2 2013-12-31

Bugfixes:

* Fix crash on until nodes: https://github.com/mbj/mutant/issues/143
* Fix missing requires: https://github.com/mbj/mutant/issues/141
* Fix crash on unknown nodes, fixes #143
* Use more durable unparser version 0.1.6

# v0.3.1 2013-12-19

Bugfixes:

* Add missing require of stringio, #141

# v0.3.0 2013-12-10

Feature:

* Rewrite all mutators on top of whitequark/parser (major!)
* Also mutate conditions in case statements
* Add tons of mutators I lost track about during development.
* Add --ignore-subject optoin supporting the same syntax as matchers

Bugfixes:

* Fix lots of crashes.
* Fix all known multiple diff errors
* Handle methods memoized with adamantium correctly

Bugfixes:

* Fix all bugs caused by mutant-melbourne

# v0.2.20 2013-03-01

* Update dependencies

[Compare v0.2.17..v0.2.20](https://github.com/mbj/mutant/compare/v0.2.17...v0.2.20)

# v0.2.17 2013-01-20

* Kill mutations in #initialize from class methods.

# v0.2.17 2013-01-20

Other:

* Update dependencies

[Compare v0.2.16..v0.2.17](https://github.com/mbj/mutant/compare/v0.2.16...v0.2.17)

# v0.2.16 2013-01-20

Bugfix:

* Handle Rubinius::AST::NthRef as noop

[Compare v0.2.15..v0.2.16](https://github.com/mbj/mutant/compare/v0.2.15...v0.2.16)

# v0.2.15 2013-01-10

Bugfix:

* Do not mutate super to super() anymore. This needs a context check in future.

[Compare v0.2.14..v0.2.15](https://github.com/mbj/mutant/compare/v0.2.14...v0.2.15)

# v0.2.14 2013-01-09

Bugfix:

* Do not emit mutation to { nil => nil } for hash literals

[Compare v0.2.13..v0.2.14](https://github.com/mbj/mutant/compare/v0.2.13...v0.2.14)

# v0.2.13 2013-01-09

Bugfix:

* Capture failures that occur in the window between mutation insertion and spec run as kills

[Compare v0.2.12..v0.2.13](https://github.com/mbj/mutant/compare/v0.2.12...v0.2.13)

# v0.2.12 2013-01-03

Bugfix:

* Do not crash when trying to load methods from precompiled ruby under rbx

[Compare v0.2.11..v0.2.12](https://github.com/mbj/mutant/compare/v0.2.11...v0.2.12)

# v0.2.11 2013-01-03

Feature:

* Handle binary operator methods in dedicated mutator

Bugfix:

* Do not crash when mutating binary operator method

[Compare v0.2.10..v0.2.11](https://github.com/mbj/mutant/compare/v0.2.10...v0.2.11)

# v0.2.10 2013-01-03

Bugfix:

* Do not mutate receivers away when message name is a keyword

[Compare v0.2.9..v0.2.10](https://github.com/mbj/mutant/compare/v0.2.9...v0.2.10)

# v0.2.9 2013-01-02

Feature:

* Mutate instance and global variable assignments
* Mutate super calls

[Compare v0.2.8..v0.2.9](https://github.com/mbj/mutant/compare/v0.2.8...v0.2.9)

# v0.2.8 2012-12-29

Feature:

* Do not mutate argument or local variable names beginning with an underscore
* Mutate unary calls ```coerce(object)``` => ```object```
* Mutate method call receivers ```foo.bar``` => ```foo```

[Compare v0.2.7..v0.2.8](https://github.com/mbj/mutant/compare/v0.2.7...v0.2.8)

# v0.2.7 2012-12-21

Feature:

* Use latest adamantium and ice_nine

[Compare v0.2.6..v0.2.7](https://github.com/mbj/mutant/compare/v0.2.6...v0.2.7)

# v0.2.6 2012-12-14

Bugfix:

* Correctly set file and line of injected mutants

[Compare v0.2.5..v0.2.6](https://github.com/mbj/mutant/compare/v0.2.5...v0.2.6)

# v0.2.5 2012-12-12

Feature:

* Add --debug flag for showing killer output and mutation
* Run noop mutation per subject to guard against initial failing specs
* Mutate default into required arguments
* Mutate default literals
* Mutate unwinding of pattern args ```|(a, b), c|``` => ```|a, b, c|```
* Mutate define and block arguments
* Mutate block arguments, inklusive pattern args
* Recurse into block bodies
* Unvendor inflector use mbj-inflector from rubygems

Bugfix:

* Insert mutations at correct constant scope
* Crash on mutating yield, added a noop for now
* Crash on singleton methods defined on other than constants or self

[Compare v0.2.4..v0.2.5](https://github.com/mbj/mutant/compare/v0.2.4...v0.2.5)

# v0.2.4 2012-12-12

Bugfix:

* Correctly vendor inflector

[Compare v0.2.3..v0.2.4](https://github.com/mbj/mutant/compare/v0.2.3...v0.2.4)

# v0.2.3 2012-12-08

Bugfix:

* Prepend extra elements to hash and array instead of append. This fixes unkillable mutators in parallel assignments!

[Compare v0.2.2..v0.2.3](https://github.com/mbj/mutant/compare/v0.2.2...v0.2.3)

# v0.2.2 2012-12-07

Feature:

* Add a shitload of operator expansions for dm2 strategy

[Compare v0.2.1..v0.2.2](https://github.com/mbj/mutant/compare/v0.2.1...v0.2.2)

# v0.2.1 2012-12-07

Bugfix:

* Crash on unavailable source location
* Incorrect handling of if and unless statements
* Expand Foo#initialize to spec/unit/foo in rspec dm2 strategy
* Correctly expand [] to element_reader_spec.rb in rspec dm2 strategy
* Correctly expand []= to element_writer_spec.rb in rspec dm2 strategy
* Correctly expand foo= to foo_writer_spec.rb in rspec dm2 strategy

[Compare v0.2.0..v0.2.1](https://github.com/mbj/mutant/compare/v0.2.0...v0.2.1)

# v0.2.0 2012-12-07

First public release!
