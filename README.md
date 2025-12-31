mutant
======

![Build Status](https://github.com/mbj/mutant/workflows/CI/badge.svg)
[![Gem Version](https://img.shields.io/gem/v/mutant.svg)](https://rubygems.org/gems/mutant)
[![Discord](https://img.shields.io/discord/767914934016802818.svg)](https://discord.gg/BSr62b4RkV)

## What is Mutant?

An automated code review tool, with a side effect of producing semantic code coverage
metrics.

Think of mutant as an expert developer that simplifies your code while making sure that all tests pass.

That developer never has a bad day and is always ready to jump on your PR.

Each reported simplification signifies either:

A) A piece of code that does more than the tests ask for.
   You can probably use the simplified version of the code. OR:

B) If you have a reason to not take the simplified version as it violates a requirement:
   There was no test that proves the extra requirement. Likely you are missing an
   important test for that requirement.

On extensive mutant use A) happens more often than B), which leads to overall less code enter
your repository at higher confidence for both the author and the reviewer.

BTW: Mutant is a mutation testing tool, which is a form of code coverage.
But each reported uncovered mutation is actually a call to action, just like a flag in a code review
would be.

## Rust Implementation

Parts of Mutant are being incrementally rewritten in Rust for improved performance.
This is currently **opt-in** and requires no changes for existing users. See [RUST.md](RUST.md)
for details.

## Getting started:

* Start with reading the [nomenclature](/docs/nomenclature.md). No way around that one, sorry.
* Then select and setup your [integration](/docs/nomenclature.md#integration), also make sure
  you can reproduce the examples in the integration specific documentation.
* Before running mutation testing, verify the configuration works with the [test runner](/docs/test-runner.md).
  This ensures tests pass in mutant's environment and parallel execution works correctly.
* Use mutant during code reviews and on CI in [incremental](/docs/incremental.md) mode.
* Do not merge code with new alive mutations. If you really must bypass:
  Add the subjects with open problems to the ignored subjects.

## Operating Systems

Mutant is supported and tested under Linux and Mac OS X.

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
  * rspec integration-misc: Integration tests for isolation and parallelism
  * rspec integration-minitest: Integration tests for minitest support
  * rspec integration-rspec: Integration tests for rspec support
  * rspec integration-generation: Tests for mutation generation
  * rubocop: Style and lint checks

This results in 160 test jobs per commit (4 Ruby versions x 5 targets x 8 test suites).

## Ruby Versions

Mutant supports multiple ruby versions at different levels:

* Runtime, indicates mutant can execute on a specific Ruby Version / implementation.
* Syntax, depends on Runtime support, and indicates syntax new to that Ruby version can be used.
* Mutations, depends on Syntax support, and indicates syntax new to that Ruby version is being analysed.

Supported indicates if a specific Ruby version / Implementation is actively supported. Which means:

* New releases will only be done if all tests pass on supported Ruby versions / implementations.
* New features will be available.

| Implementation | Version        | Runtime            | Syntax             | Mutations          | Supported          |
| -------------- | -------------- | -------            | ------------------ | ------------------ | ------------------ |
| cRUBY/MRI      | 3.2            | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| cRUBY/MRI      | 3.3            | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| cRUBY/MRI      | 3.4            | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| cRUBY/MRI      | 4.0            | :heavy_check_mark: | TBD                | TBD                | :heavy_check_mark: |
| jruby          | TBD            | :email:            | :email:            | :email:            | :email:            |
| mruby          | TBD            | :email:            | :email:            | :email:            | :email:            |
| cRUBY/MRI      | < 3.2          | :no_entry:         | :no_entry:         | :no_entry:         | :no_entry:         |


Labels:

* :heavy_check_mark: Supported.
* :warning: Experimental Support.
* :soon: Active work in progress.
* :email: Planned, please contact me on interest.
* :no_entry: Not being planned, or considered, still contact me on interest.

## Licensing

Mutant is commercial software, with a free usage option for opensource projects.
Opensource projects have to be on a public repository.

Commercial projects have to pay a monthly or annual subscription fee.

## Opensource usage

Usage is free and does not require a signup. But it requires the code is under an
opensource license and public. Specify `--usage opensource` on the CLI or `usage: opensource`
in the config file.

## Commercial usage

Commercial use requires payment via a subscription and requires a signup. See [pricing](#pricing) for
available plans.

After payment specify `--usage commercial` on the CLI or `usage: commercial` in the config file.

### Pricing

**Mutant is free for [opensource use](#opensource-usage)!**

For commercial use mutants pricing is subscription based.

| Currency | Duration | Cost    | Payment Methods                                       |
| -------- | -------  | ------- | ----------------------------------------------------- |
| USD      | 1 month  | 90$     | Credit Card                                           |
| USD      | 1 year   | 900$    | Credit Card, ACH transfer                             |
| EUR      | 1 month  | 90€     | Credit Card, SEPA Direct Debit                        |
| EUR      | 1 year   | 900€    | Credit Card, SEPA Direct Debit, SEPA Transfer         |

Costs are **per developer using mutant on any number of repositories**.

Volume subscriptions with custom plans are available on request.

Should you want to procure a commercial mutant subscription please
[mail me](mailto:mbj@schirp-dso.com?subject=Mutant%20Commercial%20License) to start the payment
process.

Please include the following information:

* Your business invoice address.
* A payment email address, if different from your email address.
* Only for the EU: A valid VAT-ID is *required*, no sales to private customers to avoid the
  horrors cross border VAT / MOSS.
  VAT for EU customers outside of Malta will use **reverse charging**.

Also feel free to ask any other question I forgot to proactively answer here.

Also checkout the [commercial FAQ](/docs/commercial.md).

## Topics

* [Test Runner](/docs/test-runner.md)
* [Debugging and Utilities](/docs/debugging.md)
* [Commercial use / private repositories](/docs/commercial.md)
* [Nomenclature](/docs/nomenclature.md)
* [Reading Reports](/docs/reading-reports.md)
* [Limitations](/docs/limitations.md)
* [Concurrency](/docs/concurrency.md)
* [Rspec Integration](/docs/mutant-rspec.md)
* [Minitest Integration](/docs/mutant-minitest.md)
* [Configuration](/docs/configuration.md)
* [Hooks](/docs/hooks.md)
* [Sorbet](/docs/sorbet.md)

## Communication

Try the following:

* [Discord Channel](https://discord.gg/BSr62b4RkV) reach for `@mbj`.
* [Github Issues](https://github.com/mbj/mutant/issues)
* [Release Announcement Mailing List](https://announce.mutant.dev/signup)

## Sponsoring

Mutant, as published in the opensource version, would not exist without the help
of [contributors](https://github.com/mbj/mutant/graphs/contributors) spending lots
of their private time.

Additionally, the following features where sponsored by organizations:

* The `mutant-minitest` integration was sponsored by [Arkency](https://arkency.com/)
* Mutant's initial concurrency support was sponsored by an undisclosed company that does
  currently not wish to be listed here.

### Legal

Contents of this repository are maintained by:

```
Schirp DSO LTD
Director: Markus Schirp
Email: info@schirp-dso.com
Vat-ID: MT24186727
Registration: C80467

Office address:
2, Carob Lane,
Sir Harry Luke Street
Naxxar NXR 2209,
Malta

Registred Address
Phoenix Business Centre,
The Penthouse,
Old Railway Track,
Santa Venera SVR9022,
Malta
```
