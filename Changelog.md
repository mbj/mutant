# v0.8.14 2017-07-06

* Support ruby 2.4 #719

# v0.8.13 2017-06-01

* Allow empty match expressions on CLI
* Add support for rspec-3.6 by @krzysiek150
* Add support for configurable corpus glob exprssions by @jekuta

# v0.8.12 2016-10-17

* Add mutation from `/foo|bar/` to `/foo/` and `/bar/`
* Add mutation from `/$/` to `/\z/`
* Add mutation from `/\h/` to `/\H/`
* Add mutation from `/\H/` to `/\h/`
* Add mutation from `/\Z/` to `/\z/`
* Add mutation from `flat_map` to `map`
* Add mutation from `/(foo)/` to `/(?:foo)/`
* Add mutation from `/a*/` to `/a+/`
* Add mutation from `/a*/` to `/a/`
* Add mutation from `!!foo` to `foo`
* Add mutation from `proc { }` to `lambda { }`

# v0.8.11 2016-08-01

* Add support for rspec-3.5
* Remove misleading `--debug` option
* Remove misleading `--expect-coverage` option
* Add basic support for regexp mutations (machinery and simple anchor mutations)
* Add support for mutating csend (duck tape operator) into regular sends
* Add mutation from `foo&.bar` to `foo.bar`
* Add mutation from `#to_a` to `#to_set`
* Add mutation from `foo.dig(a, b)` to `foo.fetch(a).dig(b)`
* Add mutation from `def foo(bar:); end` to `def foo(_bar:); end`
* Add mutation from `def foo(bar: baz); end` to `def foo(_bar: baz); end`
* Add mutation from `/regex/i` to `/regex/`
* Add mutation from `foo[n..-1]` to `foo.drop(n)`
* Add mutation from `/^/` to `/\A/`
* Add mutation from `#first` to `#last`
* Add mutation from `#last` to `#first`
* Add mutation from `#sample` to `#first` and `#last`
* Remove mutations from `1..n` to `1..(0.0 / 0.0)` and `1..(1.0 / 0.0)`

# v0.8.10 2016-01-24

* Add support for parser 2.3 (via unparser 0.2.5)

# v0.8.9 2016-01-05

* Add mutation from `Hash#[]` to `Hash#key?` (#511)
* Add mutation from `Hash#fetch` to `Hash#key?` (#511)
* Add mutation from `#at` to `#key?` (#511)
* Add mutation from `Hash#values_at` to `Hash#fetch_values` (#510)

# v0.8.8 2015-11-15

* Drop support for rspec-3.2
* Remove CI specific job number default
* Add support for rspec-3.3.4
* Add mutations/s performance metric to report

# v0.8.7 2015-10-30

* Fix blackliting regexp to correctly match the String `(eval)` absolutely.

# v0.8.6. 2015-10-27

* Add mutation from `Date.parse` to more strict parsing methods #448
* Add mutation from `foo.to_i` to `Integer(foo)` #455
* Add mutation from `@foo` to `foo` #454

# v0.8.5 2015-09-11

* Fix misimplementation of block gluing operator that
  as side effect could also cause invalid AST crashes

# v0.8.4 2015-09-10

* Add mutation from `a != b` to `!a.eql?(b)` and `!a.equal?(b)` #417
* Add mutation `A.const_get(:B)` -> `A::B` #426
* Add mutation `def foo(*args); end` into `def foo(*args); args = []; end` #423
* Add mutation from `foo.baz { bar }` to `foo.bar` #416
* Update anima dependency to 0.3.0

# v0.8.3 2015-09-01

* Remove invalid mutation `super(...)` to `super`
* Add mutation from `def foo(a = true); end` to `def foo(a = true); a = true; end` #419
* Add mutation from `def foo; end` to `remove_method :foo` #413

# v0.8.2 2015-08-11

* Remove invalid mutation `foo or bar` to `!(foo or bar)` see #287
* Add mutation from `#to_h` to `#to_hash` #218
* Add mutation from `super` to `super()` #309
* Add mutation from `#defined?` to `true` / `false` #399
* Reduce framed (multiline) progress reporter noise
* Fix a bug where killfork pipes where not properly closed

# v0.8.1 2015-07-24

* Add --since flag to constrain mutated subjects based on
  repository diff from HEAD to other REVISON.
* Add mutation from #[] to #at / #fetch
* Some internal improvements

# v0.8.0 2015-06-15

* Drop support for ruby < 2.1
* Remove broken `--code` option
* Remove deprecated `--score` option
* Add support for rspec-3.3
* End support for rspec-3.{0,1}
* Internal quality improvements

# v0.7.9 2015-05-30

* Deprecate `--score` flag replace with `--expected-coverage`
* Set default job count to 4 under CI environments.
* Relax parser dependency to ~>2.2.2

# v0.7.8 2015-03-8

* Kill imperfect float rounding for exact coverage expectations.

# v0.7.7 2015-02-15

* Add support for rspec-3.2

# v0.7.6 2015-01-25

* Fix crash on using the null integration.

# v0.7.5 2015-01-14

* Bump deps to support MRI 2.2.

# v0.7.4 2014-12-22

* Fix rspec example visibility on duplicate metadata examples [#279](https://github.com/mbj/mutant/issues/279).
* Add naked if/else body emitter [#280](https://github.com/mbj/mutant/issues/280).

# v0.7.3 2014-12-09

* Fix communication between workers and killforks to work for all binaries.

# v0.7.2 2014-12-08

* Fix synthetic race conditon in actor implementation
* Fix progressive reporter slowdown

# v0.7.1 2014-12-04

* Fix invalid dependencies on rspec for mutant-rspec

# v0.7.0 2014-12-04

* Use homegrown actor based parallelization
* Fix redundant spec execution in rspec integration
* Add mutation from `#send` to `#__send__` (the canonical form).

# v0.6.7 2014-11-17

* Fix duplicate neutral emit for memoized instance method subjects
* Fix neutral error detection edge cases

# v0.6.6 2014-11-11

* Fix emitter to recurse into left and right of binary nodes.

# v0.6.5 2014-10-28

* Fix killforks not to leak zombies.

# v0.6.4 2014-10-27

* Do not buffer report prints, speedup large report generation.
* Fix some cases where --fail-fast semantics stopped far to late.
* Fix crashing / stuckage from using parallel in a nested way.

# v0.6.3 2014-09-22

* Add support for rspec-3.1.

# v0.6.2 2014-09-16

* Fix matcher to ignore metaprogrammed defines [#254](https://github.com/mbj/mutant/issues/254)
* Add rescue resbody body concat-promotion mutation
* Add rescue else body concat-promotion mutation #245

# v0.6.1 2014-09-16

* Incorrectly released on partial state. Yanked.

# v0.6.0 2014-08-11

* Parallel execution / reporting.
* Add -j, --jobs flag to control concurrency.
* Fix blind spots on send with block.
* Add mutation from `foo { bar }` to `bar`
* Add mutation from `#reverse_merge` to `#merge`
* Add mutation from `#<=` to `#<`, `#==`, `#eql?`, `#equal?`
* Add mutation from `#>=` to `#>`, `#==`, `#eql?`, `#equal?`
* Add mutation from `#>` to `#==`, `#eql?`, `#equal?`
* Add mutation from `#<` to `#==`, `#eql?`, `#equal?`
* Fix reporting of diff errors to include context [tjchambers]

# v0.5.26 2014-07-07

* Fix exceptions generation matcher errors
* Fix report generation with formatted string as payload of diffs.

# v0.5.25 2014-07-07

* Make ordering of subjects and tests deterministic
* Fix performance of subject selection
* Improve noop and neutral reporting.
* Rename noop mutations to neutral mutations
* Simplify code nuked around 1kloc.

# v0.5.24 2014-06-30

* Fix invalid AST on op_assign mutations
* Make subject matching result order deterministic
* Improve internals a bit for more consistency.
* Add instance methods expression 'Foo#'
* Add singleton methods expression 'Foo.'
* Split rspec2 and rspec3 integration with minimal duplication
* Move test matching outside of integrations.

# v0.5.23 2014-06-15

* Propagate exceptions from child-isolation-killforks to master

# v0.5.22 2014-06-15

* Fix invalid AST generation on operator method mutation with self as receiver.

# v0.5.21 2014-06-15

* Readd mutation of index assignments
* Remove a bunch of useless mutations to nil.something
* Readd mutation of index reference arguments

# v0.5.20 2014-06-14

* Remove support for matchers prefixed with ::
* Fix cases where mutated source diff was empty #198
* Fix mutate to simpler primitive violation break to next #203
* Improve integration / corpus tests to spot highlevel regressions on CI level.

* Remove support for matchers prefixed with ::

# v0.5.19 2014-06-06

Changes:

* Do not emit more powerful rescue matchers #183
* Do not emit more powerful loop control #201

# v0.5.18 2014-06-04

Changes:

* Do not rename lhs of or assigns when lhs is a ivasgn. Closes #150

# v0.5.17 2014-05-27

Changes:

* Report selected tests in progress runner
* Fix scope of rspec selections to include meaningful parents.
* Add short circuits on already dead mutations under multiple test selections.

# v0.5.16 2014-05-27

Changes:

* Fix granularity of test selection under rspec
* Add mutation from [item] to item
* Add mutation from #reverse_each to #each
* Add mutation from #reverse_map to #each, #map
* Add mutation from #map to #each

# v0.5.15 2014-05-24

Changes:

* Put isolation pipe into binmode

Changes:

* Add support for rspec-3.0.0.rc1
* Remove some senseless rescue mutations

# v0.5.13 2014-05-23

Changes:

* Improve reporting of isolation problems
* Centralize test selection
* Report selected tests
* Report rspec output on noop failures
* Silence warnings on methods without source location

# v0.5.12 2014-05-09

Changes:

* Remove pointless mutation nil => Object.new

# v0.5.11 2014-04-22

Changes:

* Fix crash on while and until without body
* Better require highjack based zombifier
* Do not mutate nthref $1 to gvar $0
* Use faster duplicate guarding hashing AST::Node instances
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
