mutant
======

[![Build Status](https://circleci.com/gh/mbj/mutant.svg?style=shield&circle-token=1afd77e8f0f9d0a11fd8f15f5d7b10270f4665e2)](https://circleci.com/gh/mbj/mutant/tree/master)
[![Dependency Status](https://gemnasium.com/mbj/mutant.svg)](https://gemnasium.com/mbj/mutant)
[![Code Climate](https://codeclimate.com/github/mbj/mutant.svg)](https://codeclimate.com/github/mbj/mutant)
[![Inline docs](http://inch-ci.org/github/mbj/mutant.svg)](http://inch-ci.org/github/mbj/mutant)
[![Gem Version](https://img.shields.io/gem/v/mutant.svg)](https://rubygems.org/gems/mutant)
[![Flattr](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/thing/1823010/mbjmutant-on-GitHub)
[![Slack Status](https://mutation-testing-slack.herokuapp.com/badge.svg)](https://mutation-testing.slack.com/messages/mutant)

Mutant is a mutation testing tool for Ruby.

The idea is that if code can be changed and your tests do not notice, then either that code isn't being covered
or it does not have a speced side effect.

Mutant supports ruby >= 2.1, while support for JRuby is planned.
It should also work under any Ruby engine that supports POSIX-fork(2) semantics.

Mutant uses a pure Ruby [parser](https://github.com/whitequark/parser) and an [unparser](https://github.com/mbj/unparser)
to do its magic.

Mutant does not have really good "getting started" documentation currently so please refer to presentations and blog posts below.

Installation
------------

As mutant right now only supports rspec, install the gem `mutant-rspec` via your preferred method.
It'll pull the `mutant` gem (in the correct version), that contains the main engine.

```ruby
gem install mutant-rspec
```

The minitest integration is still in the [works](https://github.com/mbj/mutant/pull/445).

Examples
--------

```
cd virtus
# Run mutant on virtus namespace
mutant --include lib --require virtus --use rspec Virtus*
# Run mutant on specific virtus class
mutant --include lib --require virtus --use rspec Virtus::Attribute
# Run mutant on specific virtus class method
mutant --include lib --require virtus --use rspec Virtus::Attribute.build
# Run mutant on specific virtus instance method
mutant --include lib --require virtus --use rspec Virtus::Attribute#type
```

Rails
-------

To mutation test Rails models with rspec, comment out ```require 'rspec/autorun'``` from your spec_helper.rb file.  Having done so you should be able to use commands like the following:

```sh
RAILS_ENV=test bundle exec mutant -r ./config/environment --use rspec User
```

Passing in RSpec Options
------------------------

**NOTE: Experimental**

You can control some aspects of RSpec using the `SPEC_OPTS` environment variable as usual. If you want mutant to only pay attention to specs in a certain directory, you can run

```sh
SPEC_OPTS="--pattern spec/subdir_only/**/*_spec.rb" mutant --use rspec SomeClass
```

Limitations
-----------

Mutant cannot emit mutations for...

* methods defined within a closure.  For example, methods defined using `module_eval`, `class_eval`,
  `define_method`, or `define_singleton_method`:

    ```ruby
    class Example
      class_eval do
        def example1
        end
      end

      module_eval do
        def example2
        end
      end

      define_method(:example3) do
      end

      define_singleton_method(:example4) do
      end
    end
    ```

* singleton methods not defined on a constant or `self`

    ```ruby
    class Foo
      def self.bar; end   # ok
      def Foo.baz; end    # ok

      myself = self
      def myself.qux; end # cannot mutate
    end
    ```

* methods defined with eval:

    ```ruby
    class Foo
      class_eval('def bar; end') # cannot mutate
    end
    ```

Mutation-Operators
------------------

Mutant supports a wide range of mutation operators. An exhaustive list can be found in the [mutant-meta](https://github.com/mbj/mutant/tree/master/meta).
The `mutant-meta` is arranged to the AST-Node-Types of parser. Refer to parsers [AST documentation](https://github.com/whitequark/parser/blob/master/doc/AST_FORMAT.md) in doubt.

There is no easy and universal way to count the number of mutation operators a tool supports.

Subjects
--------

Mutant currently mutates code in instance and singleton methods. It is planned to support mutation
of constant definitions and domain specific languages, DSL probably as plugins.

Test-Selection
--------------

Mutation testing is slow. The key to making it fast is selecting the correct set of tests to run.
Mutant currently supports the following built-in strategy for selecting tests/specs:

Mutant uses the "longest rspec example group descriptions prefix match" to select the tests to run.

Example for a subject like `Foo::Bar#baz` it will run all example groups with description prefixes in
`Foo::Bar#baz`, `Foo::Bar` and `Foo`. The order is important, so if mutant finds example groups in the
current prefix level, these example groups *must* kill the mutation.

Reading Reports
---------------

Mutation output is grouped by selection groups. Each group contains three sections:

1. An identifier for the current group.

   **Format**:

   ```text
   [SUBJECT EXPRESSION]:[SOURCE LOCATION]:[LINENO]
   ```

   **Example**:

   ```text
   Book#add_page:Book#add_page:/home/dev/mutant-examples/lib/book.rb:18
   ```

2. A list of specs that mutant ran to try to kill mutations for the current group.

   **Format**:

   ```text
   - [INTEGRATION]:0:[SPEC LOCATION]:[SPEC DESCRIPTION]
   - [INTEGRATION]:1:[SPEC LOCATION]:[SPEC DESCRIPTION]
   ```

   **Example**:

   ```text
   - rspec:0:./spec/unit/book_spec.rb:9/Book#add_page should return self
   - rspec:1:./spec/unit/book_spec.rb:13/Book#add_page should add page to book
   ```

3. A list of unkilled mutations diffed against the original unparsed source

   **Format**:

   ```text
   [MUTATION TYPE]:[SUBJECT EXPRESSION]:[SOURCE LOCATION]:[SOURCE LINENO]:[IDENTIFIER]
   [DIFF]
   -----------------------
   ```

   - `[MUTATION TYPE]` will be one of the following:
      - `evil` - a mutation of your source was not killed by your tests
      - `neutral` your original source was injected and one or more tests failed
   - `[IDENTIFIER]` - Unique identifier for this mutation

   **Example**:

   ```diff
   evil:Book#add_page:Book#add_page:/home/dev/mutant-examples/lib/book.rb:18:01f69
   @@ -1,6 +1,6 @@
    def add_page(page)
   -  @pages << page
   +  @pages
      @index[page.number] = page
      self
    end
   -----------------------
   evil:Book#add_page:Book#add_page:/home/dev/mutant-examples/lib/book.rb:18:b1ff2
   @@ -1,6 +1,6 @@
    def add_page(page)
   -  @pages << page
   +  self
      @index[page.number] = page
      self
    end
   -----------------------
   ```

Concurrency
-----------

By default, mutant will test mutations in parallel by running up to one process for each core on your system. You can control the number of processes created using the `--jobs` argument.

Mutant forks a new process for each mutation to be tested to prevent side affects in your specs and the lack of thread safety in rspec from impacting the results.

If the code under test relies on a database, you may experience problems when running mutant because of conflicting data in the database. For example, if you have a test like this:
```
m = MyModel.create!(...)
expect(MyModel.first.name).to eql(m.name)
```
It might fail if some other test wrote a record to the MyModel table at the same time as this test was executed. (It would find the MyModel record created by the other test.) Most of these issues can be fixed by writing more specific tests. Here is a concurrent safe version of the same test:
```
m = MyModel.create!(...)
expect(MyModel.find_by_id(m.id).name).to eql(m.name)
```
You may also try wrapping your test runs in transactions.

Note that some databases, SQLite in particular, are not designed for concurrent access and will fail if used in this manner. If you are using SQLite, you should set the `--jobs` to 1.

Neutral (noop) Tests
--------------------

Mutant will also test the original, unmutated, version your code. This ensures that mutant is able to properly setup and run your tests.
If an error occurs while mutant/rspec is running testing the original code, you will receive an error like the following:
```
--- Neutral failure ---
Original code was inserted unmutated. And the test did NOT PASS.
Your tests do not pass initially or you found a bug in mutant / unparser.
...
Test Output:
marshal data too short
```
Currently, troubleshooting these errors requires using a debugger and/or modyifying mutant to print out the error. You will want to rescue and inspect exceptions raised in this method: lib/mutant/integration/rspec.rb:call

Only Mutating Changed Code
--------------------------

Running mutant for the first time on an existing codebase can be a rather disheartening experience due to the large number of alive mutations found! Mutant has a setting that can help. Using the `--since` argument, mutant will only mutate code that has been modified. This allows you to introduce mutant into an existing code base without drowning in errors. Example usage that will mutate all code changed between master and the current branch:
```
mutant --include lib --require virtus --since master --use rspec Virtus::Attribute#type
```

Known Problems
==============

Mutations with Infinite Runtimes
---------------------------------

Occasionally mutant will produce a mutation with an infinite runtime. When this happens
mutant will look like it is running indefinitely without killing a remaining mutation. To
avoid mutations like this, consider adding a timeout around your tests. For example, in
RSpec you can add the following to your `spec_helper`:
```ruby
config.around(:each) do |example|
  Timeout.timeout(5, &example)
end
```
which will fail specs which run for longer than 5 seconds.

The Crash / Stuck Problem (MRI)
-------------------------------

Mutations generated by mutant can cause MRI to enter VM states its not prepared for.
All MRI versions > 1.9 and < 2.2.1 are affected by this depending on your compiler flags,
compiler version, and OS scheduling behavior.

This can have the following unintended effects:

* MRI crashes with a segfault. Mutant kills each mutation in a dedicated fork to isolate
  the mutations side effects when this fork terminates abnormally (segfault) mutant
  counts the mutation as killed.

* MRI crashes with a segfault and gets stuck when handling the segfault.
  Depending on the number of active kill jobs mutant might appear to continue normally until
  all workers are stuck into this state when it begins to hang.
  Currently mutant must assume that your test suite simply not terminated yet as from the outside
  (parent process) the difference between a long running test and a stuck MRI is not observable.
  Its planned to implement a timeout enforced from the parent process, but ideally MRI simply gets fixed.

References:

* [MRI fix](https://github.com/ruby/ruby/commit/8fe95fea9d238a6deb70c8953ceb3a28a67f4636)
* [MRI backport to 2.2.1](https://github.com/ruby/ruby/commit/8fe95fea9d238a6deb70c8953ceb3a28a67f4636)
* [Mutant issue](https://github.com/mbj/mutant/issues/265)
* [Upstream bug redmine](https://bugs.ruby-lang.org/issues/10460)
* [Upstream bug github](https://github.com/ruby/ruby/pull/822)

Presentations
-------------

There are some presentations about mutant in the wild:

* [RailsConf 2014](http://railsconf.com/) / http://confreaks.com/videos/3333-railsconf-mutation-testing-with-mutant
* [Wrocloverb 2014](http://wrocloverb.com/) / https://www.youtube.com/watch?v=rz-lFKEioLk
* [eurucamp 2013](http://2013.eurucamp.org/) / FrOSCon-2013 http://slid.es/markusschirp/mutation-testing
* [Cologne.rb](http://www.colognerb.de/topics/mutation-testing-mit-mutant) / https://github.com/DonSchado/colognerb-on-mutant/blob/master/mutation_testing_slides.pdf


Planning a presentation?
------------------------

Mutation testing lately (not only mutant) seems to attract some attention. So naturally
people do talks about it at conferences, user groups or other chances. Thanks for that!

As I (the author @mbj) am not too happy with some of the facts being presented about
mutant the last month.

So if you plan to do a presentation: I offer to review your slides / talk - for free of course.
My intention is NOT to change your bias pro / against this tool. Just to help to fix
invalid statements about the tool.

Also in many cases a conversation to the author should help you to improve the talk
significantly. One of mutants biggest weaknesses is the bad documentation, but instead of
assumptions based on the absence of docs, use the tool authors brain to fill the gaps.

Hint, same applies to papers.

Blog posts
----------

Sorted by recency:

* [A deep dive into mutation testing and how the Mutant gem works][troessner]
* [Keep calm and kill mutants (December, 2015)][itransition]
* [How to write better code using mutation testing (November 2015)][blockscore]
* [How good are your Ruby tests? Testing your tests with mutant (June 2015)][arkency1]
* [Mutation testing and continuous integration (May 2015)][arkency2]
* [Why I want to introduce mutation testing to the `rails_event_store` gem (April 2015)][arkency3]
* [Mutation testing with mutant (April 2014)][sitepoint]
* [Mutation testing with mutant (January 2013)][solnic]

[troessner]: https://troessner.svbtle.com/kill-all-the-mutants-a-deep-dive-into-mutation-testing-and-how-the-mutant-gem-works
[itransition]: https://github.com/maksar/mentat
[blockscore]: https://blog.blockscore.com/how-to-write-better-code-using-mutation-testing/
[sitepoint]: http://www.sitepoint.com/mutation-testing-mutant/
[arkency1]: http://blog.arkency.com/2015/06/how-good-are-your-ruby-tests-testing-your-tests-with-mutant/
[arkency2]: http://blog.arkency.com/2015/05/mutation-testing-and-continuous-integration/
[arkency3]: http://blog.arkency.com/2015/04/why-i-want-to-introduce-mutation-testing-to-the-rails-event-store-gem/  
[solnic]: http://solnic.eu/2013/01/23/mutation-testing-with-mutant.html

Support
-------

I'm very happy to receive/answer feedback/questions and criticism.

Your options:

* [GitHub Issues](https://github.com/mbj/mutant/issues)
* Ping me on [twitter](https://twitter.com/_m_b_j_)

There is also a mutation testing slack chat. Get an invite [here](https://mutation-testing-slack.herokuapp.com).
For discussing this project, join [#mutant](https://mutation-testing.slack.com/messages/#mutant).

Other Channels:

- [#cosmic-ray](https://mutation-testing.slack.com/messages/cosmic-ray): for discussing `cosmic-ray`, the python mutation testing tool.
- [#devtools](https://mutation-testing.slack.com/messages/devtools): for discussing the `devtools` metagem.
- [#general](https://mutation-testing.slack.com/messages/general): for general discussions about mutation testing.
- [#mutagen](https://mutation-testing.slack.com/messages/mutagen): for discussing `mutagen`, the javascript mutation testing tool.
- [#random](https://mutation-testing.slack.com/messages/random): for misc. off topic discussion.
- [#stryker](https://mutation-testing.slack.com/messages/stryker): for discussing `stryker`, the javascript mutation testing tool.
- [#wtf-dev](https://mutation-testing.slack.com/messages/wtf-dev): for sharing software development wtfs.


Credits
-------

* [Markus Schirp (mbj)](https://github.com/mbj)
* A gist, now removed, from [dkubb](https://github.com/dkubb) showing ideas.
* Older abandoned [mutant](https://github.com/txus/mutant). For motivating me doing this one.
* [heckle](https://github.com/seattlerb/heckle). For getting me into mutation testing.

Contributing
-------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with Rakefile or version
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

License
-------

See LICENSE file.
