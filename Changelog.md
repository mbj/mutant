# Unreleased

* Add block-pass mutations (`foo(&method(:bar))` -> `foo(&public_method(:bar))`) [#1047](https://github.com/mbj/mutant/pull/1047)
* Add new mutation of `Array(foo)` -> `[foo]` [#1043](https://github.com/mbj/mutant/pull/1043)
* Add new mutation to mutate dynamic sends to static sends ({`foo.__send__(:bar)`, `foo.send(:bar)`, `foo.public_send(:bar)`} -> `foo.bar`) [#1040](https://github.com/mbj/mutant/pull/1040)

# v0.9.11 2020-08-25

* Remove mutation to equivalent semantics on endless ranges [#1036](https://github.com/mbj/mutant/pull/1036).

# v0.9.10 2020-08-25

* Remove bounds to allow `diff-lcs 1.4.x` [#1032](https://github.com/mbj/mutant/pull/1032).
* Fix crash on endless ranges [#1026](https://github.com/mbj/mutant/pull/1026).
* Fix memoized subjects to preserve freezer option [#973](https://github.com/mbj/mutant/pull/973).

# v0.9.9 2020-08-25

+ Add support for mutating methods inside eigenclasses `class <<`. [#1009](https://github.com/mbj/mutant/pull/1009)
- Remove `<` -> `<=` and `>` -> `>=` mutations as non canonical. [#1020](https://github.com/mbj/mutant/pull/1020)
- Remove `true` -> `nil` and `false` -> `nil` mutations as non canonical. [#1018](https://github.com/mbj/mutant/pull/1018)

# v0.9.8 2020-08-02

* Change to generic catch all node mutator. This allows better cross parser version compatibility.

# v0.9.7 2020-07-22

* Bump parser dependency to 2.7.1, note this still does not support Ruby 2.7 syntax.
  But it supports running bundling with that parser version.
* Nail diff-lcs to 1.3 till output difference for 1.4 can be addressed.

# v0.9.6 2020-04-20

* Dependencies upgrade, should not change user facing semantics.
* Bump license nudge to 40s

# v0.9.5 2020-02-02

* Change to 2.7 parser series.
  This does not drop support for < 2.7 but enables to in the future add full Ruby 2.7 support.

# v0.9.4 2020-01-03

* Bump unparser dependency

# v0.9.3 2020-01-03

* Change to soft dependency on mutant-license.
  Rationale its fine to bundle mutant if not used.
  This can easily happen on transitive dependencies.

# v0.9.2 2020-01-02

* Upgrade to parser ~> 2.6.5

# v0.9.1 2020-01-02

* Packaging bugfix.

# v0.9.0 2020-01-02

* New license.
* Fix mutations to void value expressions to not be reported as integration error.
* Remove regexp body mutations
* Remove restarg mutations
* Remove support for rspec-3.{4,5,6}

# v0.8.25 2018-12-31

* Change to {I,M}Var based concurrency
* Remove actors

# v0.8.24 2018-12-29

* Change to always insert mutations with frozen string literals
* Fix various invalid AST or source mutations
* Handle regexp `regexp_parser` cannot parse but MRI accepts gracefully

# v0.8.23 2018-12-23

* Improved isolation error reporting
* Errors between isolation and tests do not kill mutations anymore.

# v0.8.22 2018-12-04

* Remove hard ruby version requirement. 2.5 is still the only officially supported version.

# v0.8.21 2018-12-03

* Change to modern ast format via unparser-0.4.1.

# v0.8.20 2018-11-27

* Replace internal timers with monotonic ones.

Find older changelogs in the project [history](https://github.com/mbj/mutant/blob/84d119fe49ebad51b213cb08285b95e6e7c4fab6/Changelog.md#v0821-2018-12-03)
