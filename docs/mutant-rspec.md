mutant-rspec
============

Before starting with mutant its recommended to understand the
[nomenclature](/docs/nomenclature.md).

## Setup

To add mutant to your rspec code base you need to:

1. Add `mutant-rspec` as development dependency to your `Gemfile` or `.gemspec`

   This may look like:

   ```ruby
   # A gemfile
   gem 'mutant-rspec'
   ```

2. Run mutant against the rspec integration via the `--integration rspec` flag.

## Run through example

This uses [mbj/auom](https://github.com/mbj/auom) a small library that
has 100% mutation coverage. Its tests execute very fast and do not have any IO
so its a good playground example to interact with.

All the setup described above is already done.

```sh
git clone https://github.com/mbj/auom
cd auom
bundle install # gemfile references mutant-rspec already

# First verify tests work with mutant's test runner
bundle exec mutant test run --include lib --require auom --integration rspec

# Then run mutation testing
bundle exec mutant run --include lib --require auom --integration rspec -- 'AUOM*'
```

**Note:** It is recommended to first verify the test suite works with `mutant test run` before
running mutation testing. See the [test runner documentation](/docs/test-runner.md) for details.

This prints a report like:

```sh
Mutant environment:
Usage:           opensource
Matcher:         #<Mutant::Matcher::Config subjects: [AUOM*]>
Integration:     Mutant::Integration::Rspec
Jobs:            8
Includes:        ["lib"]
Requires:        ["auom"]
Subjects:        23
Mutations:       1003
Results:         1003
Kills:           1003
Alive:           0
Runtime:         51.52s
Killtime:        200.13s
Efficiency:      388.45%
Mutations/s:     19.47
Coverage:        100.00%
```

Now lets try adding some redundant (or unspecified) code:

```sh
patch -p1 <<'PATCH'
--- a/lib/auom/unit.rb
+++ b/lib/auom/unit.rb
@@ -170,7 +170,7 @@ module AUOM
     # TODO: Move defaults coercions etc to .build method
     #
     def self.new(scalar, numerators = nil, denominators = nil)
-      scalar = rational(scalar)
+      scalar = rational(scalar) if true

       scalar, numerators   = resolve([*numerators], scalar, :*)
       scalar, denominators = resolve([*denominators], scalar, :/)
PATCH
```

Running mutant again prints the following:

```sh
evil:AUOM::Unit.new:/home/mrh-dev/example/auom/lib/auom/unit.rb:172:45e17
@@ -1,9 +1,7 @@
 def self.new(scalar, numerators = nil, denominators = nil)
-  if true
-    scalar = rational(scalar)
-  end
+  scalar = rational(scalar)
   scalar, numerators = resolve([*numerators], scalar, :*)
   scalar, denominators = resolve([*denominators], scalar, :/)
   super(scalar, *[numerators, denominators].map(&:sort)).freeze
 end
-----------------------
Mutant configuration:
Matcher:         #<Mutant::Matcher::Config subjects: [AUOM*]>
Integration:     Mutant::Integration::Rspec
Jobs:            8
Includes:        ["lib"]
Requires:        ["auom"]
Subjects:        23
Mutations:       1009
Results:         1009
Kills:           1008
Alive:           1
Runtime:         50.93s
Killtime:        190.09s
Efficiency:      388.45%
Mutations/s:     19.81
Coverage:        99.90%
```

This shows mutant detected the alive mutation. Which shows the conditional we deliberately added above is redundant.

Feel free to also remove some tests. Or do other modifications to either test or code.

Test-Selection
--------------

Mutation testing is slow. The key to making it fast is selecting the correct
set of tests to run.  Mutant currently supports the following built-in
strategy for selecting tests/specs:

Mutant uses the "longest rspec example group descriptions prefix match" to
select the tests to run.

Example for a subject like `Foo::Bar#baz` it will run all example groups with
description prefixes in `Foo::Bar#baz`, `Foo::Bar` and `Foo`. The order is
important, so if mutant finds example groups in the current prefix level,
these example groups *must* kill the mutation.

### RSpec Metadata for Test Control

RSpec tests can use metadata to control how mutant interacts with them.

#### Excluding Tests: `:mutant` Metadata

Use `mutant: false` to exclude specific tests from mutation testing:

```ruby
# This test will not be used to kill mutations
it 'performs slow external API call', mutant: false do
  result = ExternalAPI.call
  expect(result).to be_success
end
```

**Use cases:**
- Exclude slow integration tests that don't test business logic
- Exclude tests for external service interactions
- Exclude flaky tests temporarily while debugging
- Speed up mutation testing by focusing on unit tests

**Important:** Excluded tests still run normally with RSpec, they just won't be selected by mutant to kill mutations.

#### Explicit Subject Mapping: `:mutant_expression` Metadata

Use `mutant_expression` to explicitly specify which subjects a test covers, overriding the default prefix matching:

```ruby
# Single expression
it 'validates user input', mutant_expression: 'UserValidator#validate' do
  # Test code
end

# Multiple expressions
it 'orchestrates user creation', mutant_expression: ['UserCreator#create', 'UserMailer#welcome'] do
  # Test code that exercises multiple subjects
end
```

**Use cases:**
- Integration tests that cover multiple subjects
- Tests where the example group name doesn't match the subject naming convention
- Explicit mapping when automatic prefix matching is insufficient
- Cross-cutting concerns where one test covers multiple classes

**Example:**

```ruby
RSpec.describe 'User Registration Flow' do
  # This test covers multiple subjects explicitly
  it 'creates user and sends email',
     mutant_expression: ['UserService#register', 'EmailService#send_welcome'] do
    UserService.register(email: 'user@example.com')
    expect(User.count).to eq(1)
    expect(email_sent?).to be true
  end

  # This test is excluded from mutation testing
  it 'integrates with external payment system', mutant: false do
    # Slow external API call
  end
end
```

```sh
RAILS_ENV=test bundle exec mutant run -r ./config/environment --integration rspec User
```
