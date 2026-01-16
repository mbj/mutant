# Contributing to Mutant

## Contributor License Agreement

Mutant is a commercial product. Before contributing, you must sign a Contributor License Agreement (CLA).

Contact [mbj@schirp-dso.com](mailto:mbj@schirp-dso.com?subject=Mutant%20CLA) for details.

## Getting Started

1. Fork and clone the repository
2. Run `./bin/manager ruby prepare` to set up the Ruby environment
3. Run `bundle install` in the `ruby/` directory
4. Run tests with `./bin/manager ruby rspec unit`

## CI Test Matrix

Mutant is tested on CI across the following dimensions:

* Ruby versions: 3.2, 3.3, 3.4, 4.0
* Targets:
  * aarch64-apple-darwin
  * aarch64-unknown-linux-gnu
  * aarch64-unknown-linux-musl
  * x86_64-unknown-linux-gnu
  * x86_64-unknown-linux-musl
* Test suites:
  * rspec spec-unit: Unit tests for mutant internals
  * mutant test: Verify mutant can run its own test suite
  * mutant run: Incremental mutation coverage on changed code
  * quick-start-verify: Verify the quick_start example works
  * rspec integration-misc: Integration tests for isolation and parallelism
  * rspec integration-minitest: Integration tests for minitest support
  * rspec integration-rspec: Integration tests for rspec support
  * rspec integration-generation: Tests for mutation generation
  * rubocop: Style and lint checks

This results in 180 test jobs per commit (4 Ruby versions x 5 targets x 9 test suites).

## Running Tests Locally

```bash
# Unit tests
./bin/manager ruby rspec unit

# Integration tests
./bin/manager ruby rspec integration

# Rubocop
./bin/manager ruby rubocop

# Mutation testing on changed code
./bin/manager ruby mutant run -- --since HEAD~1
```

## Communication

* [GitHub Issues](https://github.com/mbj/mutant/issues)
