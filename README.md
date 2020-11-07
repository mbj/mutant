mutant
======

![Build Status](https://github.com/mbj/mutant/workflows/CI/badge.svg)
[![Gem Version](https://img.shields.io/gem/v/mutant.svg)](https://rubygems.org/gems/mutant)
[![Slack Status](https://mutation-testing-slack.herokuapp.com/badge.svg)](https://mutation-testing.slack.com/messages/mutant)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fmbj%2Fmutant&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=PAGE+VIEWS&edge_flat=false)](https://hits.seeyoufarm.com)

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

## Getting started:

* Start with reading the [nomenclature](/docs/nomenclature.md). No way around that one, sorry.
* Then select and setup your [integration](/docs/nomenclature.md#integration), also make sure
  you can reproduce the examples in the integration specific documentation.
* Use mutant during code reviews and on CI in [incremental](/docs/incremental.md) mode.
* Do not merge code with new alive mutations. If you really must bypass:
  Add the subjects with open problems to the ignored subjects.

## Operating Systems

Mutant is supported and tested under Linux and Mac OS X.

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
| cRUBY/MRI      | 2.5            | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| cRUBY/MRI      | 2.6            | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| cRUBY/MRI      | 2.7            | :heavy_check_mark: | :heavy_check_mark: | :soon:             | :heavy_check_mark: |
| cRUBY/MRI      | 3.0            | :warning:          | :soon:             | :soon:             | :soon:             |
| jruby          | TBD            | :email:            | :email:            | :email:            | :email:            |
| mruby          | TBD            | :email:            | :email:            | :email:            | :email:            |
| cRUBY/MRI      | < 2.5          | :no_entry:         | :no_entry:         | :no_entry:         | :no_entry:         |


Labels:

* :heavy_check_mark: Supported.
* :warning: Experimental Support.
* :soon: Active work in progress.
* :email: Planned, please contact me on interest.
* :no_entry: Not being planned, or considered, still contact me on interest.

## Licensing

Mutant was recently transitioned commercial software, with a free usage plan for opensource projects.

Commercial projects have to acquire a license per developer, with unlimited repositories
per developer. CI usage for licensed developers is included.

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

For opensource licenses mutant checks the git remotes against the licensed git repositories.
This allows the project maintainer to sign up and not bother collaborators with the details.

There are, apart from initial license gem installation, no remote interaction for
license validation.

### Getting an Opensource license

As stated above: Opensource projects of any kind are free to use mutant.

Just mail [me](mailto:mbj@schirp-dso.com?subject=Mutant%20Opensource%20License): Please
include:

* Just the git remote URL of your repository. Repository can be anywhere, must not be on Github, just has to be public.

I do not need any more details.

### Getting a commercial license

Mutant offers a per developer subscription a monthly plan for 30$, or an annual plan for 300$.

Above 10 developer licensees per customer I'm open to negotiate more discounts.

Should you want to procure a commercial mutant license please [mail me](mailto:mbj@schirp-dso.com?subject=Mutant%20Commercial%20License).

Please include the following information:

* Your invoice address, including your Tax ID (For EU customers VAT-ID is mandatory)
* Per licensed user the git author email address as returned by `git config user.email`

Also feel free to ask any other question I forgot to proactively answer here.

#### Payment methods

* For monthly subscriptions: Exclusively CC.
* For annual subscriptions: CC (worldwide) or ACH (US) / SEPA (EU) wire transfer.

#### Pricing Why?

The idea is to charge 1$ per developer per day. Mutant reduces the time spend on code reviews.

This time saved should be worth way more than the 1$ per day.

If you think this is not true for your code base, either my claims are wrong our your use of mutant is wrong.
I'd be happy to hear about your case as I'm certainly willing to help you in using mutant right, and in case
I'm wrong I'd be happy to improve mutant to the point I'm right again.

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
