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
     cover 'YourLibrary::SomeClass*' # tells mutant which subjects this tests should cover
     # ...
   ```

4. Run mutant against the minitest integration

   ```sh
   bundle exec mutant --include lib --require 'your_library.rb' --use minitest -- 'YourLibrary*'
   ```

## Run through example

This uses [mbj/auom](https://github.com/mbj/auom) a small library that
has 100% mutation coverage. Its tests execute very fast and do not have any IO
so its a good playground example to interact with.

All the setup described above is already done.

```sh
git clone https://github.com/mbj/auom
cd auom
bundle install # gemfile references mutant-minitest already
bundle exec mutant --include lib --require auom --use minitest -- 'AUOM*'
```

This prints a report like:

```sh
Mutant configuration:
Matcher:         #<Mutant::Matcher::Config match_expressions: [AUOM*]>
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
Overhead:        154.30%
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
Overhead:        170.06%
Mutations/s:     107.60
Coverage:        99.90%
```

This shows mutant detected the alive mutation. Which shows the conditional we deliberately added above is redundant.

Feel free to also remove some tests. Or do other modifications to either test or code.
