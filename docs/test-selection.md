# Test Selection

Mutant does not run your whole suite against every mutation. For each subject it
picks the tests that could plausibly kill that subject's mutations, and runs only
those. Selection is what makes mutation testing affordable, and it is also what
decides whether an `alive` result means "no test checks this" or "mutant never
gave the right test a chance".

Two strategies are available, and by default mutant chooses between them.

## `expression`

Each test carries one or more expressions. RSpec derives them from the leading
token of an example's full description, or from `mutant_expression` metadata.
Minitest and Test::Unit take them from the `cover` declaration. A subject
selects the tests whose expression it prefixes.

This costs nothing to set up and keeps the selection tight, but it only sees
tests that name their subject. A spec headed `describe 'clamping behaviour'`
covers `Calculator#clamp` without ever saying so, and the expression strategy
will not find it. Mutations then report alive even though a test in the suite
kills them.

## `context_map`

The `context_map` strategy replaces the guess with a measurement. It reads a per
test coverage recording and selects the tests that actually executed the
subject's own source lines, wherever those tests live and whatever they are
called.

### Recording the coverage

The recording comes from [simplecov](https://github.com/simplecov-ruby/simplecov)
1.2.0 or newer, which adds it to `coverage/coverage.json` when `track_tests` is
enabled:

```ruby
# spec/spec_helper.rb, or test/test_helper.rb
require 'simplecov'

SimpleCov.start do
  track_tests
end
```

Run the suite once from the project root to write the recording. `coverage.json`
is simplecov's published report, carrying a schema version and the project root
it was recorded against. The default HTML formatter writes it beside its report,
as does `SimpleCov::Formatter::JSONFormatter`.

Mutant reads the file, never writes it, and does not depend on simplecov at
runtime. Any tool that writes the same schema will do.

## Choosing a strategy

The default is `auto`. Mutant reads `coverage/coverage.json` when it is there and
usable, and falls back to the expressions when it is not. A project that records
per test coverage gets the better selection without asking for it, and a project
that does not is unaffected. Every run prints the strategy it settled on:

```
Selection:       context_map
```

Naming a strategy turns that judgement off:

```sh
mutant run --selection context_map   # fail unless the recording can be used
mutant run --selection expression    # never read the recording
mutant run --selection context_map --selection-path tmp/coverage
```

Under `context_map`, every reason the recording cannot be used stops the run with
an explanation rather than downgrading to a selection you did not ask for. That
is what you want on CI, where a silently missing recording would quietly change
what the build measures.

The same settings live under a `selection` key in `mutant.yml`. See
[Configuration](/docs/configuration.md#selection).

### Order

A run against a mutation stops at the first failing test, so the order the
tests are handed over in decides whether one test runs or all of them. Under
`context_map` they are ranked likeliest killer first, by three signals:

1. A test the expressions would also have picked is the subject's own unit
   test. Nothing measured beats that prior, so those go first as a block.
2. Within each block, the test spending the largest share of its own footprint
   inside this subject comes first. A test that exists for this code asserts on
   it, where a feature spec passing through may swallow the difference.
3. Reach breaks the remaining ties. A test that ran more of the subject's lines
   is likelier to have run the mutated one. A full tie falls back to the test
   id, so the order depends on the recording's content and not on the order the
   coverage tool happened to write it.

Minitest and Test::Unit run the tests in the order they are given and stop at
the first failure, so the ranking arrives intact. Rspec picks its own order for
groups and for the examples inside them, so mutant installs an ordering strategy
that sorts both by the ranking. Rspec runs one group at a time, so a group is
ranked by the best test it holds and the ranking survives as group order plus
example order within a group.

Rspec's public `register_ordering(:global)` is not enough for this. It is a noop
once `--order` was forced from the command line or `.rspec`, which most suites
do, so mutant registers with the ordering registry instead.

On a suite where thirty tests execute a subject incidentally and one asserts on
it, ranking cut the examples run from 129 to 39 for the same nine kills.

### Lines no test executes

Code that only runs while the suite loads (a constant body, a class level DSL
call) executes under no test at all, so the recording attributes it to nobody.
Subjects like that fall back to expression based selection. Reporting their
mutations alive without running a single test would be a lie, and the fallback
is what keeps `context_map` from being less honest than the default.

### What it costs

Selection by coverage is not uniformly cheaper. A subject whose lines only one
spec touches now runs one spec instead of a whole file's worth. A method that
half the suite reaches through some integration test now selects all of those
tests, and that subject gets slower.

That is the trade the strategy makes. `expression` answers "do this subject's own
unit tests pin its behaviour", `context_map` answers "does anything in the suite
notice when this subject changes". Both are worth knowing. Neither is free.

### Keeping the recording

A suite that calls `SimpleCov.start` unconditionally will rewrite the recording
every time mutant runs it, leaving an empty one behind for the next run. Start
simplecov only when you are actually measuring coverage:

```yml
# mutant.yml
environment_variables:
  MUTANT: '1'
```

```ruby
# spec/spec_helper.rb
unless ENV.key?('MUTANT')
  SimpleCov.start do
    track_tests
  end
end
```

A recording that names no test of the running suite was taken somewhere else.
Under `auto` mutant falls back to the expressions, and under `context_map` it
refuses to run, so a stale or foreign recording never quietly selects nothing.
