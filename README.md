mutant
======

[![Build Status](https://circleci.com/gh/mbj/mutant.svg?style=shield&circle-token=1afd77e8f0f9d0a11fd8f15f5d7b10270f4665e2)](https://circleci.com/gh/mbj/mutant/tree/master)
[![Gem Version](https://img.shields.io/gem/v/mutant.svg)](https://rubygems.org/gems/mutant)
[![Slack Status](https://mutation-testing-slack.herokuapp.com/badge.svg)](https://mutation-testing.slack.com/messages/mutant)

## What is Mutant?

Mutant is a mutation testing tool for Ruby. Mutation testing is a technique to verify semantic coverage of your code.

## Why do I want it?

Mutant adds to your toolbox: Detection of uncovered semantics in your code.
Coverage becomes a meaningful metric!

On each detection of uncovered semantics you have the opportunity to:

* Delete dead code, as you do not want the extra semantics not specified by the tests
* Add (or improve a test) to cover the unwanted semantics.
* Learn something new about the semantics of Ruby and your direct and indirect dependencies.

## How Do I use it?

* Start with reading the [nomenclature](/docs/nomenclature.md) documentation.
* Then select and setup your [integration](/docs/nomenclature.md#integration), also make sure
  you can reproduce the examples in the integration specific documentation.
* Identify your preferred mutation testing strategy. It is recommended to start at the commit level,
  to test only the code you had been touching. See the [incremental](#only-mutating-changed-code)
  mutation testing documentation.

## Licensing

Mutant was recently transitioned commercial software, with a free usage plan for opensource projects.

Commercial projects have to acquire a license per developer, with unlimited repositories
per developer.

Opensource projects have to acquire their free license per repository.

The license distribution happens through the `mutant-license` gem in mutants dependencies.
This gem is dynamically generated per licensee and comes with a unique license gem source
URL.

After signup for a license the following has to be added to your `Gemfile` replacing `${key}`
with the license key and `${plan}` with `com` for commercial or `oss` for opensource usage.

```ruby
source 'https://${plan}:${key}@gem.mutant.dev' do
  gem 'mutant-license'
end
```

The mutant license gem contains metadata that allows mutant to verify licensed use.

For commercial licenses mutant checks the git commit author or the configured git email
to be in the set of licensed developers.

For opensource licenses mutant checks the git remotes against the license whitelist.
This allows the project maintainer to sign up and not bother collaborators with the details.

There are, apart from initial license gem installation, no remote interactions for
license validation.

To inquire for license please contact [Markus Schirp](mailto:mbj@schirp-dso.com?subject=Mutant%20License).

### Pricing

Only relevant for commercial use.

Mutant offers a subscription model under a monthly plan.
Yearly prepayments with discounts are available.

For higher volumes different arrangements can be negotiated.

## Topics

* [Nomenclature](/docs/nomenclature.md)
* [Reading Reports](/docs/reading-reports.md)
* [Known Problems](/docs/known-problems.md)
* [Limitations](/docs/limitations.md)
* [Concurrency](/docs/concurrency.md)
* [Rspec Integration](/docs/mutant-rspec.md)
* [Minitest Integration](/docs/mutant-minitest.md)

## Communication

Try the following:

* [Github Issues](https://github.com/mbj/mutant/issues)
* [Release Announcement Mailing List](https://announce.mutant.dev/signup)
* [Slack channel](mutation-testing.slack.com) request invite from [Markus Schirp](mailto:mbj@schirp-dso.com?subject=Mutation%20Testing%20Slack%20Channel%20Invite).

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
