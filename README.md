mutant
======

[![Build Status](https://circleci.com/gh/mbj/mutant.svg?style=shield&circle-token=1afd77e8f0f9d0a11fd8f15f5d7b10270f4665e2)](https://circleci.com/gh/mbj/mutant/tree/master)
[![Gem Version](https://img.shields.io/gem/v/mutant.svg)](https://rubygems.org/gems/mutant)
[![Slack Status](https://mutation-testing-slack.herokuapp.com/badge.svg)](https://mutation-testing.slack.com/messages/mutant)

## What is Mutant?

Mutant is a mutation testing tool for Ruby. Mutation testing is a technique to verify semantic coverage of your code.

## Why do I want it?

Mutant adds to your toolbox: Detection of uncovered semantics in your code.
Coverage becomes a meaninful metric!

On each detection of uncovered semantics you have the opportunity to:

* Delete dead code, as you do not want the extra semantics not specified by the tests
* Add (or improve a test) to cover the unwanted semantics.
* Learn something new about the semantics of Ruby and your direct and indirect dependencies.

## How Do I use it?

* Start with reading the [nomenclature](/docs/nomenclature.md) documentation.
* Than select and setup your [integration](/docs/nomenclature.md#interation), also make sure
  you can reproduce the examples in the integration specific documentation.
* Identify your preferred mutation testing strategy. Its recommended to start at the commit level,
  to test only the code you had been touching. See the [incremental](#only-mutating-changed-code)
  mutation testing documentation.

Topics
------

* [Nomenclature](/docs/nomenclature.md)
* [Reading Reports](/docs/reading-reports.md)
* [Known Problems](/docs/known-problems.md)
* [Limitations](/docs/limitations.md)
* [Concurrency](/docs/concurrency.md)
* [Rspec Integration](/docs/mutant-rspec.md)
* [Minitest Integration](/docs/mutant-minitest.md)

Sponsoring
----------

Mutant, as published in the opensource version, would not exist without the help
of [contributors](https://github.com/mbj/mutant/graphs/contributors) spending lots
of their private time.

Additionally, the following features where sponsored by organizations:

* The `mutant-minitest` integration was sponsored by [Arkency](https://arkency.com/)
* Mutant's initial concurrency support was sponsored by an undisclosed company that does
  currently not wish to be listed here.

If your organization is interested in sponsoring a feature, general maintainership or bugfixes, contact
[Markus Schirp](mailto:mbj@schirp-dso.com).
