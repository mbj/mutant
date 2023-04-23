# Configuration

There are 3 ways of configuring mutant:

1. In the source code via processing comments.
2. Via the CLI
3. Via a config file.

### Processing Comments

Mutant currently only supports the `mutant:disable` directive that can be added in a
source code comment to ignore a specific subject.

Example:

```ruby
class SomeClass
  # mutant:disable
  def some_method
  end
end
```

More inline configuration will be made available over time.

### Configuration File

Mutant can be configured with a config file that can be named one of the following: `.mutant.yml`, `config/mutant.yml`, or `mutant.yml`

The following options can be configured through the config file:

#### `includes`

The includes key takes a list of strings to add to ruby's `$LOAD_PATH`. This is similar to ruby's `-I` option.

```yml
---
includes:
- lib
```

Additional includes can be added by providing the `-I` or `--include` option to the CLI.

#### `requires`

The requires key takes a list of ruby files to be required. This is how mutant loads your application code.

```yml
---
requires:
- my_app
```

Additional requires can be added by providing the `-r` or `--require` option to the CLI.

#### `environment_variables`

Allows to set environment variables that are loaded just before the target application is
loaded. This is especially useful when dealing with rails that has to be initialized with
`RAILS_ENV=test` to behave correctly under mutation testing.

```yml
---
environment_variables:
  RAILS_ENV: test
```

Additional environment variables can be added by providing the `--env KEY=VALUE` option to the CLI.

#### `integration`

Configures the [integration](/docs/integration.md) to use, via the `name` key.

If your tests are written in [RSpec](https://rspec.info/), this should be set to `rspec`.
If your tests are written in [minitest](https://github.com/seattlerb/minitest), this should be set to `minitest`.

```yml
---
integration:
  name: rspec
  # Optional per integration arguments. Proxies through to the integrations native CLI processor.
  # Currently for minitest integration arguments are ignored.
  # Note that when set this *OVERWRITES* the hardcoded defaults mutant provides. So should you
  # provide your own arguments, for rspec you *need* to specify the `spec` directory at a minimum.
  # Mutant is not compatible with many rspec options, take care you do not violate mutants invariants.
  # During CLI executions you can manually add new integration arguments via `--integration-argument`,
  # you have to specify it once per argument, so: `--integration-argument seed --integration-argument 0`
  # would execute rspec with the `--seed 0` flag.
  # Below shows an example configuring rspec to use a static seed from the config file.
  arguments:
  - --fail-fast # rspec integration default, keep this when specifying manual options!
  - --seed # option
  - '0' # option value, needs to be a string.
  - spec # rspec integration default, tell rspec integration where to find specs
```

The integration can be overridden by providing the `--integration` option to the CLI.

#### `fail_fast`

When `fail_fast` is enabled, mutant will stop as soon as it encounters an alive mutation. This can be helpful for incremental workflows where you want to see the output of a failed mutation immediately. Valid values are `true` and `false`.

```yml
---
fail_fast: true
```

#### `matcher`

Allows to set subject matchers in the configration file.

```yml
matcher:
  # Subject expressions to find subjects for mutation testing.
  # Multiple entries are allowed and matches from each expression
  # are unioned.
  #
  # Subject expressions can also be specified on the command line. Example:
  # `bundle exec mutant run YourSubject`
  #
  # Note that expressions from the command line replace the subjects
  # configured in the config file!
  subjects:
  - Your::App::Namespace # select all subjects on a specific constant
  - Your::App::Namespace* # select all subjects on a specific constant, recursively
  - Your::App::Namespace#some_method # select a specific instance method
  - Your::App::Namespace.some_method # select a specific class method
  - descendants:ApplicationController # select all descendands of application controller (and itself)
  # Expressions of subjects to ignore during mutation testing.
  # Multiple entries are allowed and matches from each expression
  # are unioned.
  #
  # Subject ignores can also be specified on the command line, via `--ignore-subject`. Example:
  # `bundle exec mutant run --ignore-subject YourSubject#some_method`
  #
  # Note that subject ignores from the command line are added to the subject ignores
  # configured on the command line!
  #
  # Also matcher ignores generally shold be used for entire namespaces, and individual
  # methods be disabled directly in source code via `mutant:disable` directives.
  ignore:
  - Your::App::Namespace::Dirty # ignore all subjects on a specific constant
  - Your::App::Namespace::Dirty* # ignore all subjects on a specific constant, recursively
  - Your::App::Namespace::Dirty#some_method # ignore a specific instance method
  - Your::App::Namespace::Dirty#some_method # ignore a specific class method
```

If you specify match expressions on the command line they overwrite all expressions
in the config file.

Also note that a subject can only be matched once. So `Foo*` and `Foo::Bar*` expressions
would not match duplicate subjects.

#### `jobs`

Specify how many processes mutant uses to kill mutations. Defaults to the number of processors on your system.

```yml
---
jobs: 8
```

The number of jobs can be overridden by the `-j` or `--jobs` option in the CLI.
See mutant's configuration file, [mutant.yml](/mutant.yml), for a complete example.

#### `mutation`

Configuration of the mutations generator.

```yml
mutation:
  # Control the maximum time per mutation spend on analysis.
  # Unit is in fractional seconds.
  #
  # Default absent.
  #
  # Absent value: No limit on per mutation analysis time.
  # Present value: Limit per mutation analysis time to specified value in seconds.
  timeout: 1.0
  # Add ignore AST patterns that skip mutation generation
  # This is useful to not emit mutations for log statements etc
  ignore_patterns:
  - send{selector=log}
  # Select full mutation operators by default mutant only applies the light set
  # Only difference between full and light right now is that light does not apply
  # `#== -> #eql?` mutation
  # At this moment there is no CLI equivalent for this setting.
  operators: full # or `light`
```

Please consult the [AST-Pattern documentation](/docs/ast-pattern.md) for details of AST pattern
matching.

The toplevel key `mutation_timeout` is a deprecated alias for the `timeout` key under `mutation`.

Use `timeout` setting under `coverage_criteria` in the config file to control
if timeouts are allowed to cover mutations.

#### `coverage_criteria`

A configuration file only setting to control which criteria apply to determine mutation coverage.

```yml
---
coverage_criteria:
  # Control the timeout criteria, defaults to `false`:
  # * `true` - mutant will consider timeouts as covering mutations.
  # * `false` mutant will ignore timeouts when determining mutation coverage.
  timeout: false
  # Control the process status abort criteria, defaults to `false`:
  # * `true` - mutant will consider unexpected process aborts (example segfaults)
  #   as covering the mutation that caused this behavior.  This includes bugs in the test
  #   framework not producing a test result. Use with care.
  # * `false` - mutant will ignore unexpected process aborts when determining coverage.
  process_abort: false
  # Control the test result criteria, # defaults to `true`
  # * `true` mutant will consider failing tests covering mutations.
  # * `false` mutant will ignore test results when determining mutation coverage.
  # Hint: You probably do not want to touch the default.
  test_result: true
```

At this point there is no CLI equivalent for these settings.
