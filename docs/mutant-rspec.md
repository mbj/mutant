mutant-rspec
============

The integration into rspec.

Install `mutant-rspec` and use the `--use rspec` switch in your mutant command line.

```sh
bundle exec mutant --include lib --require 'your_code' --use rspec -- 'YourCode*'
```

Examples
--------

```
cd virtus
# Run mutant on virtus namespace
bundle exec mutant --include lib --require virtus --use rspec Virtus*
# Run mutant on specific virtus class
bundle exec mutant --include lib --require virtus --use rspec Virtus::Attribute
# Run mutant on specific virtus class method
bundle exec mutant --include lib --require virtus --use rspec Virtus::Attribute.build
# Run mutant on specific virtus instance method
bundle exec mutant --include lib --require virtus --use rspec Virtus::Attribute#type
```

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
