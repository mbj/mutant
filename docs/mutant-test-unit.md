mutant-test-unit
================

Before starting with mutant it's recommended to understand the
[nomenclature](/docs/nomenclature.md).

## Setup

To add mutant to your test-unit code base you need to:

1. Add `mutant-test-unit` as development dependency to your `Gemfile` or `.gemspec`

   This may look like:

   ```ruby
   # A gemfile
   gem 'mutant-test-unit'
   ```

2. Add `require 'mutant/test_unit/coverage'` to your test environment (for example to your `test/test_helper.rb`)

   Example:

   ```ruby
   require 'test/unit'
   require 'mutant/test_unit/coverage'

   class YourTestBaseClass < Test::Unit::TestCase
     # ...
   ```

3. Add `.cover` call sites to your test suite to mark them as eligible for killing mutations in subjects.

   Example:

   ```ruby
   class YourLibrarySomeClassTest < YourTestBaseClass
     cover YourLibrary::SomeClass # tells mutant which subjects this test should cover
     cover 'YourLibrary::SomeClass#some_method' # alternative for more fine-grained control
     # ...
   ```

4. Run mutant against the test-unit integration

   First verify tests work with mutant's test runner:
   ```sh
   bundle exec mutant test run --include lib --require 'your_library.rb' --integration test-unit
   ```

   Then run mutation testing:
   ```sh
   bundle exec mutant run --include lib --require 'your_library.rb' --integration test-unit -- 'YourLibrary*'
   ```

   **Note:** It is recommended to first verify the test suite works with `mutant test run` before
   running mutation testing. See the [test runner documentation](/docs/test-runner.md) for details.
