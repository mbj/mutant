# v0.14.0 2026-01-05

* Add Ruby 4.0 support.

  Mutant now supports Ruby 4.0. This includes:

  * [#1504](https://github.com/mbj/mutant/pull/1504)
    Fix IO loop compatibility with Ruby 4.0.

  * [#1490](https://github.com/mbj/mutant/pull/1490)
    Fix Minitest 6+ integration (default test framework on Ruby 4.0).

  * Update CI to test against Ruby 4.0.

  Note: Ruby 3.1 support has been removed. Minimum supported version is now Ruby 3.2.

* [#1503](https://github.com/mbj/mutant/pull/1503)

  Remove uncanonical mutation from `@foo` to `foo`. This mutation was generating
  semantically different code that changed instance variable reads to method calls.

* [#1497](https://github.com/mbj/mutant/pull/1497)

  Fix post hooks to only run after successful integration setup.

* [#1496](https://github.com/mbj/mutant/pull/1496)

  Fix frozen constant handling.

* [#1494](https://github.com/mbj/mutant/pull/1494)

  Fix eigenclass duplication issue.

* [#1493](https://github.com/mbj/mutant/pull/1493)

  Fix interrupt handling bug.

* Dependency updates:

  * Allow minitest 6.x in mutant-minitest
  * Allow irb 1.16
  * Update rspec-its to ~> 2.0
  * Update sorbet-runtime to ~> 0.6

# v0.13.5 2025-10-28

* [#1478](https://github.com/mbj/mutant/pull/1478)

  Add support for `MUTANT_JOBS` environment variable

  The `jobs` configuration can now be set via the `MUTANT_JOBS` environment variable.
  This provides an additional configuration method with the following precedence:

  1. CLI option: `-j` or `--jobs` (highest priority)
  2. Environment variable: `MUTANT_JOBS`
  3. Configuration file: `jobs:` in YAML
  4. Default: system processor count (lowest priority)

  Example usage:
  ```sh
  MUTANT_JOBS=4 bundle exec mutant run
  ```

  The environment variable value must be a valid base-10 integer. Invalid values
  (including octal or hexadecimal notation) will result in a clear error message.

# v0.13.4 2025-09-30

  [#1473](https://github.com/mbj/mutant/pull/1473)

  Fix parallel test runner to correctly setup global environment.

  Before environment customizations such as requires and includes where not run at all when
  using the parallel test runner.

# v0.13.3 2025-08-06

* [#1472](https://github.com/mbj/mutant/pull/1472)

  Change coverage criteria defaults:

  * Default mutation timeout of 5s, previous: none.
  * Coverage triteria timeout switched on, default off.

  This means mutant will stop evaluation of mutations after 5s and consider
  these as covered from now on.

  The previous behavior can be restored via:

  ```
  # mutant.yaml
  coverage_criteria:
    timeout: false
  mutation:
    timeout: 3600.0 # 1 hour
  ```

  This is not exactly equivalent as before mutant supported to be configured with unbounded mutation
  runtime, but its functionally equivalent.

# v0.13.2 2025-06-19

  Change to unparser 0.8.0 release. Which improves 3.4 support.

  On ruby-3.4 this release uses the prism parser which results in faster mutant
  boot times on especially larger code bases.

  No changes for <=ruby-3.3 still uses the whitequark parser there.

  Also add the explicit irb dependency as its no longer a default gem for 3.5 to avoid a
  load time warning.

# v0.13.1 2025-03-23

  Add new `mutant test` primary subcommand. This subcommand allows
  to run rspec (or minitest) tests via mutants *parallel* test runner.

  Standard precautions to correctly synchronize or isolate global resources
  (fileystems / database) apply.

# v0.13.0 2025-03-23

  Significant unparser upgrade. Mutant now:

  Avoids emitting mutations that do not round trip against unparsers API.

  This change generates less mutations, and currently slightly increases boot time.
  But the number of mutations that are hitting the test suite is much lower so it
  should balance.

  Also its a good step towards parallel mutation generation reducing boot times.

  Also mutations that are currently not creating round trippable ASTS are removed:

  * Negation of `if` conditions, as negating these needs operator precendence sensitive AST
    mutations mutant does not have the infrastructure for right now. The mutation to `unless` is
    still present so there is no real reduction of semantic coverage.

  * All mutations that modify the local variable scope are removed. These generated ASTs that would
    not round trip and are thus likely to be covered, execution wise these would move lvar reads to
    implicit self receivers in the past. But this was not intended by these mutations, at least not
    without explicitly changing the reads to send nodes explicitly.

# v0.12.5 2024-06-30

* [#1458](https://github.com/mbj/mutant/pull/1458)

  Fix zombifier on memoized methods (only relevant for mutant developers).

# v0.12.4 2024-06-30

* [#1455](https://github.com/mbj/mutant/pull/1455)

  Fix parsing of empty rspec descriptions

# v0.12.3 2024-06-10

* [#1453](https://github.com/mbj/mutant/pull/1453)

  Remove support for EOL Ruby-3.0.

* [#1450](https://github.com/mbj/mutant/pull/1450)
  Remove another invalid mutation to super().

# v0.12.2 2024-06-09

* [#1450](https://github.com/mbj/mutant/pull/1450)

  Remove invalid mutation operator.

# v0.12.1 2024-05-11

* [#1444](https://github.com/mbj/mutant/pull/1444)

  Add ordering mutations to full and light operator set,
  `#find/#detect/#min/#max/#min_by/#max_by -> #first/#last`. These mutations force
  to provide test cases with more than one element to observe the extra
  semantics by these methods over just `#first` and `#last`.

  Add `#first -> #last` and `#last -> #first` to full operator set. These where
  highly controversial in the past and thus where removed.
  People who do not care about ordering of their collections can choose the light operator set.

* [#1443](https://github.com/mbj/mutant/pull/1443)

  Change mutants test runner to always report in test definition order deterministically.
  Before results where recorded in order of arrival, which could result a fast test that started late to
  be reported before a slow test that started early. Basically it makes parallel test execution reporting
  deterministic.

  Change the behavior of reporting test errors on fail fast to only display the fist test that failed.
  Parallel test execution can result in one or more tests failing before the execution engine has time to
  adhere to the fail fast setting.

# v0.12.0 2024-04-22

  Drop the license gem, entirely. This reduces DRM in mutants code base to the absolute minimum.
  Mutant is *still* comercial software that requires payment if used on a commercial code base!

  Migration:

  * Commercial users: Add `usage: commercial` to your config file (or `--usage commercial` to your CLI)
  * Opensource users: Add `usage: opensource` to your config file (or `--usage opensource` to your CLI)

  [#1437](https://github.com/mbj/mutant/pull/1437)

# v0.11.34 2024-03-26

* [#1432](https://github.com/mbj/mutant/pull/1432)

  Fix const pattern mutation to not generate invalid ast. The generic node mutation would generate invalid AST.
  This also removes some recursion into the nested pattern. Still this is preferable till we add explicit
  pattern mutation operators.

# v0.11.33 2024-03-24

* [#1431](https://github.com/mbj/mutant/pull/1431)

  Add source match expression, source `source:$glob_expression`, example `source:{app,lib}/**/*.rb`
  works with anything that `Pathname#glob` suppors.

  Allows to match all toplevel class/module constants defined in the matched ruby files.

# v0.11.32 2024-03-20

* [#1430](https://github.com/mbj/mutant/pull/1430)

  Also factor in Rspec 3.9+ signal `rspec_is_quitting` to detect rspec not being able to load examples.

# v0.11.31 2024-03-14

* [#1428](https://github.com/mbj/mutant/pull/1428)

  Improve rspec integration. Mutant now properly exits early if rspec cannot load examples.

# v0.11.30 2024-03-11

* [#1427](https://github.com/mbj/mutant/pull/1427)

  Add integration setup hooks.
  * `setup_integration_pre` - called before the test integration setup.
  * `setup_integration_post` - called after the test integration setup.

# v0.11.29 2024-03-09

* [#1426](https://github.com/mbj/mutant/pull/1426)
  Fix mutations to unintentionally change constant scope.
  This fixes: https://github.com/mbj/mutant/issues/1422.

* [#1421](https://github.com/mbj/mutant/pull/1421)
  Change to optional warning display via --print-warnings environment option.

# v0.11.28 2024-02-09

* [#1418](https://github.com/mbj/mutant/pull/1418)
  Fix mutation to invalid pattern match.

* [#1416](https://github.com/mbj/mutant/pull/1416)
  Fix CLI parsing issue where arguments given to `mutant environment` where silently ignored.

* [#1415](https://github.com/mbj/mutant/pull/1415)
  Change to report efficiency instead of overhead.
  Efficiency is defined by `killtime / runtime`.

* [#1413](https://github.com/mbj/mutant/pull/1413)

  Add `Process.warmup` optimization for ruby-3.3+ which yields a noticable speed improvement.

# v0.11.27 2023-12-01

* [#1414](https://github.com/mbj/mutant/pull/1414)

  Update to parser-3.3.0 dependency.

# v0.11.26 2023-12-01

* [#1409](https://github.com/mbj/mutant/pull/1409)

  Fix config file support for AST pattern ignores. Before this fix the AST ignore
  patterns would only be picked up when specified via CLI.

* [#1405](https://github.com/mbj/mutant/pull/1406)

  Drop support for ruby 2.7.

# v0.11.25 2023-10-18

* Add support for commercial organization wide licenses

  [#1404](https://github.com/mbj/mutant/pull/1404)

# v0.11.24 2023-10-10

* Fix restarg and kwrestarg nested mutations.

  [#1403](https://github.com/mbj/mutant/pull/1403)

# v0.11.23 2023-10-08

* Fix restarg and kwrestarg invalid mutations.

  [#1402](https://github.com/mbj/mutant/pull/1402)

# v0.11.22 2023-07-16

* Introduce mutation operators config 'light' and 'full'. Mutant will default to
  light set that for the moment does not include `#== -> #eql?`.

  [#1394](https://github.com/mbj/mutant/pull/1394)

# v0.11.21 2023-06-15

* [#1389](https://github.com/mbj/mutant/pull/1389)

  Upgrade to unparser 0.6.8 dependency which ships an important bugfix
  on unparsing of csend AST nodes on binary operators.

* [#1330](https://github.com/mbj/mutant/pull/1330)

  Change to `--integration` from `--use` on CLI and `integration_name` from `integration`
  key in config file.

  The old key is still supported but deprecated.

  Add ability to provide multiple `--integration-argument` options that get passed down
  directly to rspec. Also available in the config file.

# v0.11.20 2023-05-22

* [#1382](https://github.com/mbj/mutant/pull/1382)

  Significantly optimize parsing overhead during boot. Smaller projects may see boot time speedups of 10-20%. Larger projects may see boot time improvements of 2-3x or greater. Memory consumption is also greatly reduced (by a factor of 5x or more in some small changesets).

* [#1379](https://github.com/mbj/mutant/pull/1378)

  Add support for user defined mutation worker process hooks.
  These hooks are triggered before the mutation worker process starts processing mutations.
  They can be used so setup separate test databases to avoid clobbering between
  mutation threads or do other isolation mechanisms.

* [#1377](https://github.com/mbj/mutant/pull/1377)

  Add `#available_tests` to integrations, differentiating tests eligible for
  mutation testing from all tests availabe in the integration.
  This will allow to re-use mutants test runner for all integration tests,
  outside of mutation testing.

# v0.11.19 2023-05-06

* [#1376](https://github.com/mbj/mutant/pull/1376)

  Fix crash on code that must have been a ternary on original source.

* [#1373](https://github.com/mbj/mutant/pull/1373)

  Change to more performant rspec integration. Significant rspec runner
  speed improvement on projets with a very large number of tests.

# v0.11.18 2023-01-08

* [#1367](https://github.com/mbj/mutant/pull/1367)

  Add ruby-3.2 support.

* [#1361](https://github.com/mbj/mutant/pull/1361)

  Upgrade regexp-parser to 2.6.1. This also re-implements the regexp mutation
  emitter to be more maintainable, no semantic changes expected.

* [#1362](http://github.com/mbj/mutant/pull/1362)

  Adapt to behavior change in ruby 3.1.3 where methods inherited
  from module inclusions that just got visibility changes are now
  owned by the included module/class.

# v0.11.17 2022-11-12

* [#1352](https://github.com/mbj/mutant/pull/1352)

  Add execution profiling via `--profile`. The output format is not stable
  yet, still this profile is very useful to differentiate mutant load time from
  target application load time.

* [#1358](https://github.com/mbj/mutant/pull/1358)

  Improve worker process termination speed. Reduces pause before report print
  especially on high core count machines.

# v0.11.16 2022-09-11

* [#1355](https://github.com/mbj/mutant/pull/1355)

  Fix ignore patterns support for single node def nodes.
  Fix config merge support for ignore patterns.

# v0.11.15 2022-09-05

* [#1353](https://github.com/mbj/mutant/pull/1353)

  Fix to provide a well formed `Mutant::Config::DEFAULT` constant at all times.
  Primarily useful for custom 3rd party integrations that use mutants API directly.

# v0.11.14 2022-07-31

* [#1348](https://github.com/mbj/mutant/pull/1348)

  Change to improved AST matching performance. Mutant boot performance
  is positively affected mostly on larger projects with larger AST node
  count per file.

* [#1347](https://github.com/mbj/mutant/pull/1347/files)

  Fix AST structure metadata issues.

# v0.11.13 2022-06-27

* Add support for org wide opensource licensing.

# v0.11.12 2022-06-27

* [#1341](https://github.com/mbj/mutant/pull/1341)

  Add user defined mutation filtering.

  Mutant will not emit mutations for AST patterns defined by the new
  mutation specific option `ignore_patterns`.

  ```
  mutation:
    ignore_patterns:
    - send{selector=log} # does no emit any mutation for `logger.log` or similar.
  ```

  The supported syntax is way [more powerful](https://github.com/mbj/mutant/blob/main/docs/ast-pattern.md) than this simple example.

* [#1342](https://github.com/mbj/mutant/pull/1340)

  Fix: [#1308] again.

  Properly normalize repository names on OSS license check.

* [#1340](https://github.com/mbj/mutant/pull/1340)

  Deprecate `mutation_timeout` toplevel configuration key.

  Now use:

  ```
  mutation:
    timeout: 10.0
  ```

# v0.11.11 2022-06-20

* [#1339](https://github.com/mbj/mutant/pull/1339)

  Add support for minitest-0.5.16, and its srant initalization. Currently mutant randomizes selected minitest
  tests by default. AS this is also the minitest default for versions past 0.5.16 this should be a good enough
  behavior.

* [#1333](https://github.com/mbj/mutant/pull/1333)

  Add mutation AST filtering. This allows to not emit mutations on user specified ASTS.

* [#1332](https://github.com/mbj/mutant/pull/1332)

  Fix incomplete mutations for regexp capture groups. As an example, `/(\w\d)/` now gets mutated to `/(\W\d)/` and `/(\w\D)/` instead of just the former case.

  Fix capture group -> passive group mutations which would not get properly generated in many cases. As an example, `/(\w\d)/` would get mutated to `/(?:\w)/` instead of `/(?:\w\d)/` like it will now.

# v0.11.10 2022-05-02

* [#1328](https://github.com/mbj/mutant/pull/1328)

  Fix incomplete mutations for named regexp capture groups. As an example, `/(?<name>\w\d)/` now gets mutated to `/(?<name>\W\d)/` and `/(?<name>\w\D)/` instead of just the former case.

* [#1331](https://github.com/mbj/mutant/pull/1331)

  Add graceful but urgent exit on SIGINT.

# v0.11.9 2022-05-01

* [#1327](https://github.com/mbj/mutant/pull/1327)

  Add explicit mutation handler for xstr nodes.

- [#1326](https://github.com/mbj/mutant/pull/1326)

  Fix crash with certain block argument edge cases such as `foo { |(*)| }`.

  Fix mutation from `foo { |(a, b)| }` to `foo { |(_a, b)| }` and `foo { |(a, _b)| }` instead of the less useful mutation to only `foo { |_a| }`.

  Add `foo { |(a, b)| }` -> `foo { |a, b| }` mutation.

* [#1324](https://github.com/mbj/mutant/pull/1324)

  Remove useless `loop { code }` -> `loop { nil }` mutation.

# v0.11.8 2022-04-25

* [#1320](https://github.com/mbj/mutant/pull/1320)

  Add inline mutant disable configuration. This allows individual subjects to be marked as
  disbled directly in the code.

  Use:

  ```ruby
  class Something
    # mutant:disable
    def some_method
    end
  end
  ```

# v0.11.7 2022-04-24

* [#1319](https://github.com/mbj/mutant/pull/1319)

  Fix regexp mapper to do full, ruby version specific unicode property mapping.

# v0.11.6 2022-04-10

* [#1317](https://github.com/mbj/mutant/pull/1317)

  Fix forward arg mutations.

# v0.11.5 2022-04-03

* [#1314](https://github.com/mbj/mutant/pull/1314)

  Fix visibility of mutated methods to retain original value.

  Fix: [#1242]

* [#1311](https://github.com/mbj/mutant/pull/1311)

  Change to fully enforced license.

* [#1310](https://github.com/mbj/mutant/pull/1310)

  Remove support for Ruby-2.6 as its EOL.

* [#1309](https://github.com/mbj/mutant/pull/1309)

  Change to ignore case mismatches in git repository names on license check.

# v0.11.4 2022-02-13

* [#1303](https://github.com/mbj/mutant/pull/1303)

  Add full Ruby 3.1 support.

# v0.11.3 2022-02-13

* [#1302](https://github.com/mbj/mutant/pull/1302)

  Change to parser/unparser that works on 3.1 syntax. This does not mean
  mutant is yet fully 3.1 compatible. Mostly that mutant does not block the parser
  dependency anymore. And unparser is ready for Ruby 3.1.

# v0.11.2 2021-11-15

* [#1285](https://github.com/mbj/mutant/pull/1283)

  Prevent multipath matches. Should multiple match expessions evaluate to the same subject,
  mutant now only visits that subject once.

  This prevents blowing up the mutation testing work on bigger applications with more
  complex match expressions.

* [#1283](https://github.com/mbj/mutant/pull/1283)

  Add descendants matchers. These matchers allow to select subjects in inheritance trees
  that are not namespace based.

  This is very useful for non namespaced (rails) applications. As users can now use match expressions
  like `descendants:ApplicationController` to match all descants of `ApplicationController` including
  `ApplicationController`.

  This feature is not bound to rails inheritance trees and can be used with any inheritance tree.

# v0.11.1 2021-11-08

* [#1276](https://github.com/mbj/mutant/pull/1276)

  Improve matching speed. This is especially noticeable in larger projects.
  Mutant now creates way less objects while matching subjects.

* [#1275](https://github.com/mbj/mutant/pull/1275)

  Fix: [#1273](https://github.com/mbj/mutant/issues/1273)

  Prevent crashes on degenerate object interfaces where method reflection returns
  methods that are later not accessible via `#instance_method`.

* [#1274](https://github.com/mbj/mutant/pull/1274)

  Add ability to set environment variables via the CLI.
  The environment variables are inserted before the application is
  loaded. This is especially useful to load rails in test mode via setting
  `RAILS_ENV=test`.

  For CLI use the `--env` argument.
  For config file use the `environment_variables` key.

# v0.11.0 2021-10-18

* [#1270](https://github.com/mbj/mutant/pull/1270)

  Add sorbet method matching. Allows mutant to operate on methods
  with a sorbet signature. Does not yet use the signature to constrain
  the mutations.

  This adds a direct `sorbet-runtime` dependency to mutant. Note that Mutant
  intents to use sorbet directly for its own code. `sorbet-runtime` is itself
   a clean dependency, that unless told to: Will not perform core extensions.

  As mutant is a development dependency it should not be an issue for a project
  that mutant itself will soon use sorbet type checks to accelerate its
  development.

  Please report any issues the addition of the `sorbet-runtime` dependency to
  mutant causes.

  Bumping minor version to signal this more out of the ordinary change.

# v0.10.35 2021-10-17

* [#1269](https://github.com/mbj/mutant/pull/1269)
  Add `mutant environment irb` command. Starts an IRB session for the
  configured mutant environment. Very useful for iterating on environment
  setup issues.

# v0.10.34 2021-08-30

* [#1252](https://github.com/mbj/mutant/pull/1252)
  Remove not universally useful binary left negation operator.

* [#1253](https://github.com/mbj/mutant/pull/1253)
  Remove support for Ruby-2.5, which is EOL.

* [#1255](https://github.com/mbj/mutant/pull/1255)
  Remove invalid mutations to invalid syntax

* [#1257](https://github.com/mbj/mutant/pull/1257)
  Fix crash on numblock mutations.

* [#1258](https://github.com/mbj/mutant/pull/1258)
  Add improved UI on detecting 0 tests.
  This should be beneficial in onboarding scenarios or after manual
  persistend rspec selections.

# v0.10.33 2021-08-25

* [#1249](https://github.com/mbj/mutant/pull/1249/files)
  Add `mutant util mutation` subcommand to allow inspect mutations of
  a code snippet outside a booted environment.
  This eases debugging, learning and mutant developers life.

# v0.10.32 2021-05-16

* [#1235](https://github.com/mbj/mutant/pull/1235)
  Add more ugly workaround on Ruby loosing binmode settings.

  Fix: [#1228](https://github.com/mbj/mutant/issues/1228)

# v0.10.31 2021-05-03

* [#1234](https://github.com/mbj/mutant/pull/1234)
  Add mapping for latin regexp properties to fix crash on mutating
  `\p{Latin}` regexp nodes.

  Fix: [#1231](https://github.com/mbj/mutant/issues/1231)

# v0.10.30 2021-04-25

* [#1229](https://github.com/mbj/mutant/pull/1229)
  Add workaround to a Ruby bug that looses the binmode setting on forks.

  Fix: [#1228](https://github.com/mbj/mutant/issues/1228)

# v0.10.29 2021-03-08

* [#1221](https://github.com/mbj/mutant/pull/1221)

  * Add beginless range mutations

# v0.10.28 2021-03-07

* [#1219](https://github.com/mbj/mutant/pull/1218)

  * Remove float literal negation mutations (`1.0` -> `-1.0`).

* [#1218](https://github.com/mbj/mutant/pull/1218)

  * Remove integer literal negation mutations (`1` -> `-1`).

* [#1220](https://github.com/mbj/mutant/pull/1220)

  * Ignore methods defined in non `.rb` files during matching.

# v0.10.27 2021-02-02

* [#1216](https://github.com/mbj/mutant/pull/1216)

  Fix exception serialization form rails infected code bases.
  This case can happen when the killfork terminates abnormal,
  and the resulting exception in the worker has to be propagated to
  the main process for reporting.
  On "normal" Ruby the exceptions are dump/loadable but rails and
  its core extensions break this invariant. Hence mutant now
  captures the essence of the exception in an attribute copy for
  propagation.

* [#1207](https://github.com/mbj/mutant/pull/1207)

  * Remove `#eql?` -> `#equal?` mutation

* [#1210](https://github.com/mbj/mutant/pull/1210)

  * Remove generic mutation to `self`

# v0.10.26 2021-01-16

* [#1202](https://github.com/mbj/mutant/pull/1202)

  * Add `#reduce` -> `#sum` mutations
    * `a.reduce(:+)`     -> `a.sum`
    * `a.reduce(0, &:+)` -> `a.sum(0)`

* [#1201](https://github.com/mbj/mutant/pull/1201)

  * Add `/\Astatic/` -> `#start_with?` mutations:
    * `a.match(/\Atext/)` -> `b.start_with?('text')`
    * `a.match?(/\Atext/)` -> `b.start_with?('text')`
    * `a =~ /\Atext/` -> `b.start_with?('text')`
  * Add `/static\z/` -> `#end_with?` mutations:
    * `a.match(/text\z/)` -> `b.end_with?('text')`
    * `a.match?(/text\z/)` -> `b.end_with?('text')`
    * `a =~ /text\z/` -> `b.end_with?('text')`

* [#1200](https://github.com/mbj/mutant/pull/1200)
  * Add unused group name mutation:  `/(?<foo>bar)/` -> `/(?<_foo>bar)/`.

* [#1205](https://github.com/mbj/mutant/pull/1205)

  * Add `mutant environment test list` subcommand.
    Useful to verify which tests mutant detects as candiates for test selection.

* [#1204](https://github.com/mbj/mutant/pull/1204)

  * Allow constants to be passed to minitest integrations `cover` declaration.
    `cover SomeClass` is equivalent to `cover 'SomeClass*'`.

* [#1194](https://github.com/mbj/mutant/pull/1194)

  * Add mutation from named capturing group to non-capturing group:  `/(?<foo>bar)/` -> `/(?:bar)`.

# v0.10.25 2021-01-03

* [#1198](https://github.com/mbj/mutant/pull/1198)

  * Fix configured match expression loading to properly display error
    messages on invalid expression syntax.

* [#1192](https://github.com/mbj/mutant/pull/1192)

  * Add mutations from predicate-like methods (methods ending in ?) to `true`/`false`
      * `a.b?` -> `false`
      * `a.b?` -> `true`

* [#1186](https://github.com/mbj/mutant/pull/1186)

  Add additional `*` -> `+` regexp quantifier mutations:
  - `/a*?/` -> `/a+?/`
  - `/a*+/` -> `/a++/`

* [#1188](https://github.com/mbj/mutant/pull/1188)

  Add `a === b` -> `a.is_a?(b)` mutation

* [#1189](https://github.com/mbj/mutant/pull/1189)

  * Add mutation from `=~` -> `#match?`
  * Add mutation from `#match` -> `#match?`

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

* Fix type error on subscription show subcommand with active commercial license.
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
