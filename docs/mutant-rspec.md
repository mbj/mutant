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

2. Run mutant against the rspec integration

   ```sh
   bundle exec mutant --include lib --require 'your_library.rb' --use rspec -- 'YourLibrary*'
   ```

## Run through example

This uses [mbj/auom](https://github.com/mbj/auom) a small library that
has 100% mutation coverage. Its tests execute very fast and do not have any IO
so its a good playground example to interact with.

All the setup described above is already done.

```sh
git clone https://github.com/mbj/auom
cd auom
bundle install # gemfile references mutant-rspec already
bundle exec mutant --include lib --require auom --use rspec -- 'AUOM*'
```

This prints a report like:

```sh
Mutant configuration:
Matcher:         #<Mutant::Matcher::Config match_expressions: [AUOM*]>
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
Overhead:        -74.26%
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
Matcher:         #<Mutant::Matcher::Config match_expressions: [AUOM*]>
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
Overhead:        -73.21%
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

Rails
-------

To mutation test Rails models with rspec, comment out `require 'rspec/autorun'`
from your `spec_helper.rb` file. Having done so you should be able to use
commands like the following:

```sh
RAILS_ENV=test bundle exec mutant -r ./config/environment --use rspec User
```

Passing in RSpec Options
------------------------

**NOTE: Experimental**

You can control some aspects of RSpec using the `SPEC_OPTS` environment variable as usual. If you want mutant to only pay attention to specs in a certain directory, you can run

```sh
SPEC_OPTS="--pattern spec/subdir_only/**/*_spec.rb" bundle exec mutant --use rspec SomeClass
```
