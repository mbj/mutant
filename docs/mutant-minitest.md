mutant-minitest
===============

Before starting with mutant its recommended to understand the
[nomenclature](/docs/nomenclature.md).

## Setup

To add mutant to your minitest code base you need to:

1. Add `mutant-minitest` as development dependency to your `Gemfile` or `.gemspec`

   This may look like:

   ```ruby
   # A gemfile
   gem 'mutant-minitest'
   ```

2. Add `require 'mutant/minitest/coverage'` to your test environment (example to your `test/test_helper.rb`)

   Example:

   ```ruby
   require 'minitest/autorun'
   require 'mutant/minitest/coverage'

   class YourTestBaseClass < MiniTest::Test
     # ...
   ```

3. Add `.cover` call sides to your test suite to mark them as eligible for killing mutations in subjects.

   Example:

   ```ruby
   class YourLibrarySomeClassTest < YourTestBaseClass
     cover YourLibrary::SomeClass # tells mutant which subjects this tests should cover
     cover 'YourLibrary::SomeClass#some_method' # alternative for more fine grained control.
     # ...
   ```

4. Run mutant against the minitest integration

   First verify tests work with mutant's test runner:
   ```sh
   bundle exec mutant test run --include lib --require 'your_library.rb' --integration minitest
   ```

   Then run mutation testing:
   ```sh
   bundle exec mutant run --include lib --require 'your_library.rb' --integration minitest -- 'YourLibrary*'
   ```

   **Note:** It is recommended to first verify the test suite works with `mutant test run` before
   running mutation testing. See the [test runner documentation](/docs/test-runner.md) for details.

## Run through example

This uses [mbj/auom](https://github.com/mbj/auom) a small library that
has 100% mutation coverage. Its tests execute very fast and do not have any IO
so its a good playground example to interact with.

All the setup described above is already done.

```sh
git clone https://github.com/mbj/auom
cd auom
bundle install # gemfile references mutant-minitest already
bundle exec mutant run --include lib --require auom --integration minitest -- 'AUOM*'
```

This prints a report like:

```sh
Mutant environment:
Usage:           opensource
Matcher:         #<Mutant::Matcher::Config subjects: [AUOM*]>
Integration:     Mutant::Integration::Minitest
Jobs:            8
Includes:        ["lib"]
Requires:        ["auom"]
Subjects:        23
Mutations:       1003
Results:         1003
Kills:           1003
Alive:           0
Runtime:         9.68s
Killtime:        3.80s
Efficiency:      39.25%
Mutations/s:     103.67
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

```
AUOM::Unit.new:/home/mrh-dev/auom/lib/auom/unit.rb:172
- minitest:AUOMTest::ClassMethods::New#test_reduced_unit
- minitest:AUOMTest::ClassMethods::New#test_normalized_denominator_scalar
- minitest:AUOMTest::ClassMethods::New#test_normalized_numerator_unit
- minitest:AUOMTest::ClassMethods::New#test_incompatible_scalar
- minitest:AUOMTest::ClassMethods::New#test_integer
- minitest:AUOMTest::ClassMethods::New#test_sorted_numerator
- minitest:AUOMTest::ClassMethods::New#test_unknown_unit
- minitest:AUOMTest::ClassMethods::New#test_rational
- minitest:AUOMTest::ClassMethods::New#test_normalized_numerator_scalar
- minitest:AUOMTest::ClassMethods::New#test_sorted_denominator
- minitest:AUOMTest::ClassMethods::New#test_normalized_denominator_unit
evil:AUOM::Unit.new:/home/mrh-dev/auom/lib/auom/unit.rb:172:cd9ee
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
Matcher:         #<Mutant::Matcher::Config match_expressions: [AUOM*]>
Integration:     Mutant::Integration::Minitest
Jobs:            8
Includes:        ["lib"]
Requires:        ["auom"]
Subjects:        23
Mutations:       1009
Results:         1009
Kills:           1008
Alive:           1
Runtime:         9.38s
Killtime:        3.47s
Efficiency:      39.25%
Mutations/s:     107.60
Coverage:        99.90%
```

This shows mutant detected the alive mutation. Which shows the conditional we deliberately added above is redundant.

Feel free to also remove some tests. Or do other modifications to either test or code.

## Coverage API

The `.cover` method tells mutant which subjects a test class should cover. This is required for mutant to know which tests to run for each mutation.

### Basic Usage

```ruby
require 'mutant/minitest/coverage'

class MyClassTest < Minitest::Test
  cover MyClass

  def test_some_method
    assert_equal 42, MyClass.new.some_method
  end
end
```

### Coverage Expressions

The `.cover` method accepts multiple formats:

#### Class or Module Constants

Pass the class or module constant directly:

```ruby
class UserServiceTest < Minitest::Test
  cover UserService  # Covers all methods in UserService
end
```

When a constant is passed, mutant automatically expands it to `ClassName*` (recursive coverage).

#### Expression Strings

Use expression strings for fine-grained control:

```ruby
class UserServiceTest < Minitest::Test
  # Cover specific instance method
  cover 'UserService#create'

  # Cover specific class method
  cover 'UserService.find_by_email'

  # Cover all instance methods
  cover 'UserService#'

  # Cover all class methods
  cover 'UserService.'

  # Cover entire namespace recursively
  cover 'UserService*'
end
```

See the [Configuration documentation](/docs/configuration.md) for all available expression formats.

#### Multiple Coverage Declarations

A test class can declare coverage for multiple subjects:

```ruby
class IntegrationTest < Minitest::Test
  cover UserCreator
  cover EmailService
  cover 'NotificationQueue#enqueue'

  def test_user_registration_flow
    # This test covers mutations in all three subjects
    UserCreator.create(email: 'test@example.com')
    assert_equal 1, EmailService.sent_count
  end
end
```

### Coverage Inheritance

Coverage declarations inherit to subclasses:

```ruby
class BaseServiceTest < Minitest::Test
  cover BaseService
end

class UserServiceTest < BaseServiceTest
  cover UserService
  # This test class covers both UserService and BaseService
end
```

### Best Practices

**Do:**
- Use class constants for simple cases: `cover MyClass`
- Use expression strings for specific methods: `cover 'MyClass#specific_method'`
- Declare coverage at the test class level, not in individual test methods
- Use multiple `cover` declarations for integration tests that exercise multiple subjects

**Don't:**
- Don't call `cover` inside test methods (it won't work)
- Don't use overly broad coverage (like `cover 'MyApp*'`) in individual test files
- Don't forget to add coverage declarations - tests without them won't be used by mutant

### Example: Comprehensive Coverage

```ruby
require 'minitest/autorun'
require 'mutant/minitest/coverage'

class UserTest < Minitest::Test
  # Cover the entire User class
  cover User

  def test_full_name
    user = User.new(first_name: 'John', last_name: 'Doe')
    assert_equal 'John Doe', user.full_name
  end
end

class UserValidatorTest < Minitest::Test
  # Cover only the validate method
  cover 'UserValidator#validate'

  def test_validates_email_format
    validator = UserValidator.new
    refute validator.validate(email: 'invalid')
    assert validator.validate(email: 'valid@example.com')
  end
end

class UserRegistrationFlowTest < Minitest::Test
  # Integration test covering multiple subjects
  cover UserCreator
  cover EmailService
  cover 'AuditLog#record'

  def test_successful_registration
    result = UserCreator.register(email: 'new@example.com')
    assert result.success?
    assert_equal 1, EmailService.welcome_emails_sent
    assert_equal 1, AuditLog.count
  end
end
```
