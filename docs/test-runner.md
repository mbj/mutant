# Test Runner

Mutant includes a parallel test runner that can run RSpec or Minitest tests without performing mutation testing. This is useful for:

- **Onboarding to mutant**: Verify that the test suite works correctly with mutant's configuration before introducing mutations
- **Fast parallel test execution**: Leverage mutant's parallel execution infrastructure for regular test runs
- **CI pipelines**: Run tests in parallel as a prerequisite before mutation testing
- **Debugging**: Isolate test failures from mutation-related issues

## Getting Started

Before running mutation testing with mutant, it is recommended to first verify the test suite runs correctly using the test runner. This helps ensure:

1. The mutant configuration is correct
2. Tests pass in mutant's execution environment
3. Parallel execution works properly with the application
4. Database isolation or other resource management is configured correctly

## Commands

### `mutant test run`

Runs all tests in parallel using mutant's test runner.

```sh
bundle exec mutant test run
```

This command:
- Uses the same configuration as `mutant run` (from `.mutant.yml`, `config/mutant.yml`, or `mutant.yml`)
- Runs tests in parallel across multiple worker processes
- Respects the `jobs` configuration or `MUTANT_JOBS` environment variable
- Uses the configured integration (RSpec or Minitest)
- Applies any hooks configured in the hooks files

**Exit Status:**
- Returns `0` if all tests pass
- Returns non-zero if any tests fail

### `mutant test list`

Lists all tests detected in the environment without running them.

```sh
bundle exec mutant test list
```

This command:
- Loads the mutant environment and integration
- Discovers all available tests
- Prints the test count and identification of each test
- Useful for verifying test discovery is working correctly

## Configuration

The test runner uses the same configuration file as mutation testing. All relevant settings apply:

### Required Configuration

```yml
# .mutant.yml
integration:
  name: rspec  # or minitest

requires:
  - my_app

includes:
  - lib
```

### Optional Configuration

```yml
# .mutant.yml
jobs: 8  # Number of parallel workers

environment_variables:
  RAILS_ENV: test

hooks:
  - rails_hooks.rb  # For database isolation, etc.
```

The number of parallel jobs can be configured through:
1. CLI option: `-j` or `--jobs`
2. Environment variable: `MUTANT_JOBS`
3. Configuration file: `jobs:`
4. Default: number of processors on the system

For example:
```sh
MUTANT_JOBS=4 bundle exec mutant test run
```

### Integration Arguments

Pass additional arguments to the test framework using integration arguments:

**Via Configuration File:**
```yml
integration:
  name: rspec
  arguments:
    - --fail-fast
    - --seed
    - '0'
    - spec
```

**Via Command Line:**
```sh
bundle exec mutant test run --integration-argument --seed --integration-argument 0
```

Note: Each argument must be specified separately with its own `--integration-argument` flag.

## Resource Isolation

When running tests in parallel, proper isolation of shared resources is critical. The most common requirement is database isolation.

### Database Isolation with Hooks

For Rails applications with PostgreSQL, use hooks to create isolated databases for each worker:

```yml
# .mutant.yml
hooks:
  - rails_hooks.rb
```

See the [Hooks documentation](/docs/hooks.md) for a complete example of Rails database isolation.

### Other Resources

Consider isolation requirements for:
- File system operations (temp files, uploads, etc.)
- External services (use test doubles or worker-specific endpoints)
- Caches (Redis, Memcached with worker-specific namespaces)
- Environment variables (set per-worker if needed)

## Typical Workflow

### 1. Initial Setup

First, ensure the test runner works correctly:

```sh
# Run tests in parallel to verify configuration
bundle exec mutant test run

# If failures occur, debug with fewer workers
bundle exec mutant test run -j 1

# List tests to verify discovery
bundle exec mutant test list
```

### 2. Add Mutation Testing

Once tests pass reliably with the test runner, introduce mutation testing:

```sh
# Start with a small scope
bundle exec mutant run --fail-fast YourClass#some_method

# Expand to broader scope
bundle exec mutant run YourNamespace*
```

### 3. CI Integration

Use the test runner in CI before running mutation testing:

```sh
# .github/workflows/ci.yml or similar
- name: Run tests in parallel
  run: bundle exec mutant test run

- name: Run mutation testing (incremental)
  run: bundle exec mutant run --fail-fast --since HEAD~1
```

## Differences from Native Test Runners

### vs. RSpec

Compared to `rspec --parallel` or similar tools:

**Advantages:**
- Uses mutant's robust process isolation
- Consistent environment with mutation testing
- Leverages existing mutant configuration and hooks
- Battle-tested parallel execution infrastructure
- **Dynamic work allocation**: Workers pull tests from a shared queue on-demand, providing better load balancing for slow tests

**Differences:**
- Does not support all RSpec CLI options directly (use `--integration-argument`)
- Requires mutant configuration to be set up
- Different output format

**Work Allocation:**

Mutant uses dynamic work allocation where workers pull tests from a shared queue as they become available. This differs from static pre-allocation used by most parallel test runners.

- **Static allocation** (typical RSpec parallel runners): Work is divided upfront before execution starts, based on file count, file size, or historical runtime data
- **Dynamic allocation** (mutant): Workers pull the next test when ready, distributing work at runtime based on actual performance

**Trade-offs:**

- **More effective for slow tests**: Dynamic allocation prevents workers from sitting idle while others process slow tests. Particularly beneficial for Rails integration tests with variable execution times.
- **Less effective for many fast tests**: Dynamic allocation has coordination overhead. For suites with thousands of very fast unit tests (< 10ms each), static allocation may be more efficient. Note: Mutant intends to address this limitation in the future via dynamic batching.
- **Better load balancing**: Fast workers automatically get more work, slow workers don't hold up the entire suite

### vs. Minitest

Compared to `rake test` or minitest parallel runners:

**Advantages:**
- Automatic parallel execution without additional gems
- Process isolation prevents test pollution
- Consistent with mutation testing environment
- Dynamic work allocation (same benefits as described for RSpec above)

**Differences:**
- Different CLI interface
- Requires mutant configuration

## Troubleshooting

### Tests Fail in Parallel but Pass Serially

This indicates shared resource conflicts. Common causes:

1. **Database conflicts**: Implement database isolation with hooks
2. **File system conflicts**: Use unique temp directories per worker
3. **Global state**: Avoid or properly isolate global variables/constants
4. **External services**: Mock or use worker-specific instances

Debug by running with a single worker:
```sh
bundle exec mutant test run -j 1
```

### Tests Not Discovered

If `mutant test list` shows no tests or fewer than expected:

1. Verify integration configuration (`integration.name` is set correctly)
2. Check `requires` loads the test framework and application
3. Ensure `includes` points to the correct directories
4. For RSpec: verify `spec` directory is in integration arguments

### Slow Test Execution

If tests run slower than expected:

1. Check job count is appropriate for the system: `mutant test run -j 4`
2. Verify hooks aren't performing expensive operations
3. Consider if database setup is duplicating work across workers
4. Profile individual tests to find bottlenecks

### Configuration Errors

If mutant cannot load the environment:

1. Verify configuration file exists and is valid YAML
2. Check `requires` paths are correct
3. Ensure `environment_variables` are set correctly (e.g., `RAILS_ENV: test`)
4. Review `includes` paths

## Advanced Usage

### Running Specific Tests

To run specific tests, use integration arguments:

**RSpec:**
```sh
bundle exec mutant test run --integration-argument spec/models
```

**Minitest:**
```sh
bundle exec mutant test run --integration-argument test/models
```

### Custom Worker Count

Override job count for specific runs:

```sh
# Use all available processors
bundle exec mutant test run

# Limit to 4 workers
bundle exec mutant test run -j 4

# Single worker for debugging
bundle exec mutant test run -j 1
```

### Integration with Existing Tools

The test runner can complement existing test infrastructure:

```sh
# Run fast tests with native runner
bundle exec rspec spec/unit

# Run slow integration tests with mutant's parallel runner
bundle exec mutant test run --integration-argument spec/integration
```

## See Also

- [Configuration](/docs/configuration.md) - Complete configuration options
- [Hooks](/docs/hooks.md) - Database isolation and custom behavior
- [Concurrency](/docs/concurrency.md) - Understanding parallel execution
- [Rspec Integration](/docs/mutant-rspec.md) - RSpec-specific details
- [Minitest Integration](/docs/mutant-minitest.md) - Minitest-specific details
