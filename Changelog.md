# v0.10.24 2021-01-01

* [#1176](https://github.com/mbj/mutant/pull/1176)
  [#1185](https://github.com/mbj/mutant/pull/1185)

  Allow [subject matcher configuration](https://github.com/mbj/mutant/blob/master/docs/configuration.md#matcher)
  in the configuration file.

* [#1166](https://github.com/mbj/mutant/pull/1166)

  Reintroduce regexp mutation support

# v0.10.23 2020-12-30

* [#1179](https://github.com/mbj/mutant/pull/1181)

  * Remove unuseful kwarg mutations.
  * Remove argument promotion on kwarg mutations. These yield AST that
    when unparsed have invalid syntax.

# v0.10.22 2020-12-26

* [#1178](https://github.com/mbj/mutant/pull/1178)

  * Add ruby-3.0 syntax and mutation support.

# v0.10.21 2020-12-23

* [#1174](https://github.com/mbj/mutant/pull/1174)

  * Add mutation from `#any?` to `#all?` and vice versa.

* [#1069](https://github.com/mbj/mutant/pull/1096)

  * Add GIL scaling and memory optimization via intermediary sub-processes.
    This architecture improves mutant performance slightly on the average (incremental)
    case but has a significant increase for longer coverage runs.
    Mostly this process model reduces the friction from forking from an ever
    growing main process.
    Also it reduces the chance of GC amplification, while enabling future
    optimizations in the area.

# v0.10.20 2020-12-16

  [#1159](https://github.com/mbj/mutant/pull/1159)
  [#1160](https://github.com/mbj/mutant/pull/1160)

  * Substantially improve performance on coverage attempts that involve many selected tests.
  * Reduce (but not eliminate) performance degeneration on larger subject sets.
  * This release for many average cases should get 2x the performance.

# v0.10.19 2020-12-14

* [#1158](https://github.com/mbj/mutant/pull/1158)

  * Change to strict integration version bounds.
  * Mutant is evolving the integration interface, and will keep doing so.
  * Before this change integrations would declare they can work with many
    future mutant releases, but this is actually not the case.

* [#1155](https://github.com/mbj/mutant/pull/1155)

  * Add `defined?(@a)` -> `instance_variable_defined?(:@a)` mutation.
  * Remove invalid mutations from `defined?` -> `true`.
  * Remove mutations of `defined?()` arguments, the `defined?` method
    is not fully evaluating the argument but instead partially evaluates the
    AST, or inspects the AST.
    Delegating to the value semantics based "generic" mutation engine does create
    too many hard to cover mutations.

# v0.10.18 2020-12-13

* [#1151](https://github.com/mbj/mutant/pull/1151)

  * Add support for unicode ruby method names.
  * Fixes long standing bug on expression parsing of method operators.
    This means that mutant is now selecting a more narrow / correct set of
    tests for operators.
    As a side effect measure coverage may drop. But for a good reason as mutant
    before would select way more tests even if a specific test for such an operator
    was available. Enforcing that this specific test actually covers the subject.

* [#1152](https://github.com/mbj/mutant/pull/1152)

  * Fix matching non existing constants.

* [#1153](https://github.com/mbj/mutant/pull/1153)

  * Improve minitest integration to also render minitest failures in reports.
    This is useful when reacting to noop errors.

* [#1154](https://github.com/mbj/mutant/pull/1154)

  * Add subcommand `environment subject list`. It allows to list
    all matched subjects.

# v0.10.17 2020-12-09

* Fix low frequency stuck isolation reads.

  [#1147](https://github.com/mbj/mutant/pull/1147)

# v0.10.16 2020-12-08

* Minor performance improvements on small runs.

  [#1145](https://github.com/mbj/mutant/pull/1145)

# v0.10.15 2020-12-07

* Add support for incremental mutation testing when the working directory
  is not the git repository root.

  [#1142](https://github.com/mbj/mutant/pull/1142)

# v0.10.14 2020-12-03

* Change process abort coverage criteria to also cover nonzero killfork exits.

  [#1137](https://github.com/mbj/mutant/pull/1137)

# v0.10.13 2020-12-03

* Fix to properly propagate coverage criteria from config file.

  [#1135](https://github.com/mbj/mutant/pull/1134)

# v0.10.12 2020-12-03

* Fix absent jobs on CLI to not shadow file configuration.
* Performance improvements on caching more work in the master process.

  [#1134](https://github.com/mbj/mutant/pull/1134)

# v0.10.11 2020-12-02

* Add `environment show` subcommand to display environment without coverage run.
* Fix unspecified integration to have dedicated error message.

  [#1130](https://github.com/mbj/mutant/pull/1130)

# v0.10.10 2020-11-30

* Fix CLI overwrites of config file.
  [#1127](https://github.com/mbj/mutant/pull/1127).

# v0.10.9 2020-11-29

* Add support for specifying multiple subject expressions with the RSpec integration.
  [#1125](https://github.com/mbj/mutant/pull/1125)

# v0.10.8 2020-11-22

* Add support for process abort as coverage condition.

  This allows mutation to be covered on abnormal process aborts, such as segfaults.

  [#1120](https://github.com/mbj/mutant/pull/1120)

# v0.10.7 2020-11-22

* Add support for external mutation timeouts.

  New config file settings. `mutation_timeout` and `coverage_criteria`
  to control timeouts and coverage conditions.

  - [#1105](https://github.com/mbj/mutant/pull/1105)
  - [#1118](https://github.com/mbj/mutant/pull/1118)

* Improve CLI reporting to be less noisy:
  - [#1117](https://github.com/mbj/mutant/pull/1117)
  - [#1106](https://github.com/mbj/mutant/pull/1106)

* Fix crash on static send mutation. [#1108](https://github.com/mbj/mutant/pull/1108)

* Add more verbose configuration [documentation](https://github.com/mbj/mutant/blob/master/docs/configuration.md).

# v0.10.6 2020-11-06

* Change to always display help on invalid CLI. [#1093](https://github.com/mbj/mutant/pull/1093)

# v0.10.5 2020-11-04

* Fix config inheritance between environment, config file and CLI options.

# v0.10.4 2020-11-02

* Fix mutant-minitest and mutant rspec to not rely on git anymore in gemspec. [#1087](https://github.com/mbj/mutant/pull/1087)

# v0.10.3 2020-11-02

* Fix mutant-minitest to ship minitest/coverge file. [#1086](https://github.com/mbj/mutant/pull/1086)

# v0.10.2 2020-11-02

* Fix type error on subscription show subcommand whith active commercial license.
  [#1074](https://github.com/mbj/mutant/pull/1084)

# v0.10.1 2020-10-29

* Add support for multiple cover expressions in minitest integration [#1076](https://github.com/mbj/mutant/pull/1076)

# v0.10.0 2020-10-29

* Add subcommad interface `mutant run|license` [#1073](https://github.com/mbj/mutant/pull/1073).
* Add experimental Ruby 3.0 support [#1066](https://github.com/mbj/mutant/pull/1066)

# v0.9.14 2020-10-16

* Add 2.7 syntax support. [#1062](https://github.com/mbj/mutant/pull/1062).

# v0.9.13 2020-10-07

* Improve isolation error reporting [#1055](https://github.com/mbj/mutant/pull/1055).
* Add --start-subject CLI option. [#1057](https://github.com/mbj/mutant/pull/1057).

# v0.9.12 2020-09-10

* Add symbol-to-proc block mutations (`map(&:to_s)` -> `map(&to_str)`) [#1048](https://github.com/mbj/mutant/pull/1048)
* Add block-pass mutations (`foo(&method(:bar))` -> `foo(&public_method(:bar))`) [#1047](https://github.com/mbj/mutant/pull/1047)
* Add new mutation of `Array(foo)` -> `[foo]` [#1043](https://github.com/mbj/mutant/pull/1043)
* Add new mutation to mutate dynamic sends to static sends ({`foo.__send__(:bar)`, `foo.send(:bar)`, `foo.public_send(:bar)`} -> `foo.bar`) [#1040](https://github.com/mbj/mutant/pull/1040) and [#1049](https://github.com/mbj/mutant/pull/1049)
* Change packaging to not rely on git anymore. [#1053](https://github.com/mbj/mutant/pull/1053)

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
