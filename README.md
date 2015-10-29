mutant
======

[![Build Status](https://circleci.com/gh/mbj/mutant.svg?style=shield&circle-token=1afd77e8f0f9d0a11fd8f15f5d7b10270f4665e2)](https://circleci.com/gh/mbj/mutant/tree/master)
[![Dependency Status](https://gemnasium.com/mbj/mutant.png)](https://gemnasium.com/mbj/mutant)
[![Code Climate](https://codeclimate.com/github/mbj/mutant.png)](https://codeclimate.com/github/mbj/mutant)
[![Inline docs](http://inch-ci.org/github/mbj/mutant.png)](http://inch-ci.org/github/mbj/mutant)
[![Gem Version](https://img.shields.io/gem/v/mutant.svg)](https://rubygems.org/gems/mutant)
[![Flattr](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/thing/1823010/mbjmutant-on-GitHub)

Mutant is a mutation testing tool for Ruby.

The idea is that if code can be changed and your tests do not notice, either that code isn't being covered
or it does not have a speced side effect.

Mutant supports ruby >= 2.1, while support for JRuby is planned.
It should also work under any Ruby engine that supports POSIX-fork(2) semantics.

Mutant uses a pure Ruby [parser](https://github.com/whitequark/parser) and an [unparser](https://github.com/mbj/unparser)
to do its magic.

Mutant does not have really good "getting started" documentation currently so please refer to presentations and blog posts below.

Installation
------------

As mutant right now only supports rspec, install the gem `mutant-rspec` via your preferred method.
It'll pull the `mutant` gem (in correct version), that contains the main engine.

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

Configuration
-------------

Occasionally mutant will produce a mutation with an infinite runtime. When this happens
mutant will look like it is running indefinitely without killing a remaining mutation. To
avoid mutations like this, consider adding a timeout around your tests. For example, in
RSpec you can add the following to your `spec_helper`:

```ruby
config.around(:each) do |example|
  Timeout.timeout(5_000, &example)
end
```

which will fail specs which run for longer than 5 seconds.

Rails
-------

To mutation test Rails models with rspec comment out ```require 'rspec/autorun'``` from your spec_helper.rb file.  Having done so you should be able to use commands like the following:

```sh
RAILS_ENV=test bundle exec mutant -r ./config/environment --use rspec User
```

Mutation-Operators:
-------------------

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

Presentations
-------------

There are some presentations about mutant in the wild:

* [RailsConf 2014](http://railsconf.com/) / http://confreaks.com/videos/3333-railsconf-mutation-testing-with-mutant
* [Wrocloverb 2014](http://wrocloverb.com/) / https://www.youtube.com/watch?v=rz-lFKEioLk
* [eurucamp 2013](http://2013.eurucamp.org/) / FrOSCon-2013 http://slid.es/markusschirp/mutation-testing
* [Cologne.rb](http://www.colognerb.de/topics/mutation-testing-mit-mutant) / https://github.com/DonSchado/colognerb-on-mutant/blob/master/mutation_testing_slides.pdf

Blog-Posts
----------

* http://www.sitepoint.com/mutation-testing-mutant/
* http://solnic.eu/2013/01/23/mutation-testing-with-mutant.html

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

Planning a presentation?
------------------------

Mutation testing lately (not only mutant) seems to attract some attention. So naturally
people do talks about it at conferences, user groups or other chances. Thx for that!

As I (the author @mbj) am not too happy with some of the facts being presented about
mutant the last month.

So if you plan to do a presentation: I offer to review your slides / talk - for free off course.
My intention is NOT to change your bias pro / against this tool. Just to help to fix
invalid statements about the tool.

Also in many cases a conversation to the author, should help you to imporve the talk
significantly. One of mutants biggest weaknesses is the bad documentation, but instead of
assumptions based on the absence of docs, use the tool authors brain to fill the gaps.

Hint, same applies to papers.

Support
-------

I'm very happy to receive/answer feedback/questions and criticism.

Your options:

* [GitHub Issues](https://github.com/mbj/mutant/issues)
* Ping me on [twitter](https://twitter.com/_m_b_j_)

There is also the [#mutant](http://irclog.whitequark.org/mutant) channel on freenode.
As my OSS time budged is very limited I cannot join it often. Please prefer to use GitHub issues with
a 'Question: ' prefix in title.

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
