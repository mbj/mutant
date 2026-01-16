mutant
======

![Build Status](https://github.com/mbj/mutant/workflows/CI/badge.svg)
[![Gem Version](https://img.shields.io/gem/v/mutant.svg)](https://rubygems.org/gems/mutant)
[![Discord](https://img.shields.io/discord/767914934016802818.svg)](https://discord.gg/BSr62b4RkV)

## What is Mutant?

**AI writes your code. AI writes your tests. But who tests the tests?**

Copilot, Claude, and ChatGPT generate code faster than humans can review it. They'll even
write tests that pass. But passing tests aren't the same as *meaningful* tests.

Mutant is mutation testing for Ruby. It systematically modifies your code and verifies your
tests actually catch each change. When a mutation survives, you've found either:

- **Dead code** - the AI over-engineered something you can delete
- **A blind spot** - the AI forgot to test a behavior that matters

The more code AI writes for you, the more you need verification you can trust.

## Quick Start

```ruby
# lib/person.rb
class Person
  def initialize(age:)
    @age = age
  end

  def adult?
    @age >= 18
  end
end
```

```ruby
# spec/person_spec.rb
RSpec.describe Person do
  describe '#adult?' do
    it 'returns true for age 19' do
      expect(Person.new(age: 19).adult?).to be(true)
    end

    it 'returns false for age 17' do
      expect(Person.new(age: 17).adult?).to be(false)
    end
  end
end
```

Tests pass. But run mutant:

```bash
gem install mutant-rspec
mutant run --use rspec --usage opensource --require ./lib/person 'Person#adult?'
```

Mutant finds a surviving mutation indicating a shallow test:

```diff
 def adult?
-  @age >= 18
+  @age > 18
 end
```

Your tests don't cover `age == 18`. The mutation from `>=` to `>` doesn't break them.

A full working example is available in the [quick_start](quick_start/) directory.

## Next Steps

1. Learn the [nomenclature](/docs/nomenclature.md) (subjects, mutations, operators)
2. Set up your [integration](/docs/nomenclature.md#integration): [RSpec](/docs/mutant-rspec.md) or [Minitest](/docs/mutant-minitest.md)
3. Run mutant on CI in [incremental](/docs/incremental.md) mode

## Ruby Versions

Mutant is supported on Linux and macOS.

| Version | Runtime | Syntax | Mutations |
| ------- | ------- | ------ | --------- |
| 3.2     | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| 3.3     | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| 3.4     | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| 4.0     | :heavy_check_mark: | :heavy_check_mark: | :construction:* |

*Mutations specific to Ruby 4.0 syntax pending [parser](https://github.com/whitequark/parser) gem support.

## Licensing

**Free for open source.** Use `--usage opensource` for public repositories.

**Commercial use** requires a subscription ($90/month per developer).
See [commercial licensing](/docs/commercial.md) for pricing and details.

## Documentation

* [Configuration](/docs/configuration.md)
* [RSpec Integration](/docs/mutant-rspec.md)
* [Minitest Integration](/docs/mutant-minitest.md)
* [Incremental Mode](/docs/incremental.md)
* [Reading Reports](/docs/reading-reports.md)
* [Concurrency](/docs/concurrency.md)
* [Hooks](/docs/hooks.md)
* [Sorbet](/docs/sorbet.md)
* [Nomenclature](/docs/nomenclature.md)
* [Limitations](/docs/limitations.md)

## Communication

* [Discord](https://discord.gg/BSr62b4RkV)
* [GitHub Issues](https://github.com/mbj/mutant/issues)
* [Release Announcements](https://announce.mutant.dev/signup)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.

## Sponsoring

Mutant, as published in the opensource version, would not exist without the help
of [contributors](https://github.com/mbj/mutant/graphs/contributors) spending lots
of their private time.

Additionally, the following features where sponsored by organizations:

* The `mutant-minitest` integration was sponsored by [Arkency](https://arkency.com/)
* Mutant's initial concurrency support was sponsored by an undisclosed company that does
  currently not wish to be listed here.

## Rust Implementation

Parts of Mutant are being incrementally rewritten in Rust for improved performance.
This is currently **opt-in** and requires no changes for existing users. See [RUST.md](RUST.md)
for details.
