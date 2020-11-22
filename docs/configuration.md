# Configuration

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

#### `integration`

Specifies which mutant integration to use. If your tests are writen in [RSpec](https://rspec.info/), this should be set to `rspec`. If your tests are written in [minitest](https://github.com/seattlerb/minitest), this should be set to `minitest`.

```yml
---
integration: rspec
```

The integration can be overridden by providing the `--use` option to the CLI.

#### `fail_fast`

When `fail_fast` is enabled, mutant will stop as soon as it encounters an alive mutation. This can be helpful for incremental workflows where you want to see the output of a failed mutation immediately. Valid values are `true` and `false`.

```yml
---
fail_fast: true
```

#### `jobs`

Specify how many processes mutant uses to kill mutations. Defaults to the number of processors on your system.

```yml
---
jobs: 8
```

The number of jobs can be overridden by the `-j` or `--jobs` option in the CLI.
See mutant's configuration file, [mutant.yml](/mutant.yml), for a complete example.

#### `mutation_timeout`

Specify the maximum time, in seconds, a mutation gets analysed.

```yml
---
# Control the maximum time per mutation spend on analysis.
# Unit is in fractional seconds.
#
# Default absent.
#
# Absent value: No limit on per mutation analysis time.
# Present value: Limit per mutation analysis time to specified value in seconds.
mutation_timeout: 1.0
```

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
  # Control the test result criteria, # defaults to `true`
  # * `true` mutant will consider failing tests covering mutations.
  # * `false` mutant will ignore test results when determining mutation coverage.
  # Hint: You probably do not want to touch the default.
  test_result: true
```

At this point there is no CLI equivalent for these settings.
