mutant
======

[![Build Status](https://secure.travis-ci.org/mbj/mutant.png?branch=master)](http://travis-ci.org/mbj/mutant)
[![Dependency Status](https://gemnasium.com/mbj/mutant.png)](https://gemnasium.com/mbj/mutant)
[![Code Climate](https://codeclimate.com/github/mbj/mutant.png)](https://codeclimate.com/github/mbj/mutant)
[![Inline docs](http://inch-ci.org/github/mbj/mutant.png)](http://inch-ci.org/github/mbj/mutant)
[![Gem Version](https://img.shields.io/gem/v/mutant.svg)](https://rubygems.org/gems/mutant)

Mutant is a mutation testing tool for ruby.

The idea is that if code can be changed and your tests do not notice, either that code isn't being covered
or it does not have a speced side effect.

Mutant supports MRI and RBX 1.9, 2.0 and 2.1, while support for jruby is planned.
It should also work under any ruby engine that supports POSIX-fork(2) semantics.

Mutant uses a pure ruby [parser](https://github.com/whitequark/parser) and an [unparser](https://github.com/mbj/unparser)
to do its magic.

Mutant does not have really good "getting started" documentation currently so please refer to presentations and blog posts below.

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

Projects using Mutant
---------------------

The following projects adopted mutant, and aim 100% mutation coverage:

* [axiom](https://github.com/dkubb/axiom)
* [axiom-types](https://github.com/dkubb/axiom-types)
* [rom-mapper](https://github.com/rom-rb/rom-mapper)
* [rom-session](https://github.com/rom-rb/rom-session)
* [event_bus](https://github.com/kevinrutherford/event_bus)
* [virtus](https://github.com/solnic/virtus)
* [quacky](https://github.com/benmoss/quacky)
* [substation](https://github.com/snusnu/substation)
* [large_binomials](https://github.com/filipvanlaenen/large_binomials)
* [promise.rb](https://github.com/lgierth/promise.rb)
* [full_name](https://github.com/AGILiDEE/full_name)
* various small/minor stuff under https://github.com/mbj

Feel free to ping me to add your project to the list!

Installation
------------

Install the gem `mutant` via your preferred method.

```ruby
gem install mutant
```

If you plan to use the rspec integration you'll have to install `mutant-rspec` also. 
Please add an explicit dependency to `rspec-core` for the rspec version you want to use.

```ruby
gem install mutant-rspec
```

The minitest integration is still in the works.

Mutations
---------

Mutant supports a very wide range of mutation operators. Listing them all in detail would blow this document up.

It is planned to parse a list of mutation operators from the source. In the meantime please refer to the
[code](https://github.com/mbj/mutant/tree/master/lib/mutant/mutator/node) each subclass of `Mutant::Mutator::Node`
emits around 3-6 mutations.

Currently mutant covers the majority of ruby's complex nodes that often occur in method bodies.

NOTE: The textbook examples you find on mutation testing are intentionally not implemented. This is subjected to change.

Some stats from the [axiom](https://github.com/dkubb/axiom) library:

```
Subjects:  424       # Amount of subjects being mutated (currently only methods)
Mutations: 6760      # Amount of mutations mutant generated (~13 mutations per method)
Kills:     6664      # Amount of successfully killed mutations
Runtime:   5123.13s  # Total runtime
Killtime:  5092.63s  # Time spend killing mutations
Overhead:  0.60%
Coverage:  98.58%    # Coverage score
Alive:     96        # Amount of alive mutations.
```


Nodes still missing a dedicated mutator are handled via the
[Generic](https://github.com/mbj/mutant/blob/master/lib/mutant/mutator/node/generic.rb) mutator.
The goal is to remove this mutator and have dedicated mutator for every type of node and removing
the Generic handler altogether.

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

This test selection strategy is compatible with the old `--rspec-dm2` and `--rspec-unit` strategy.
The old flags were removed.  It allows to define very fine grained specs, or coarse grained - as you like.

Support
-------

I'm very happy to receive/answer feedback/questions and critism.

Your options:

* [GitHub Issues](https://github.com/mbj/mutant/issues)
* Ping me on [twitter](https://twitter.com/_m_b_j_)

There is also the [#mutant] channel on freenode. As my OSS time budged is very limited I cannot
join it often. Please prefer to use github issues with a `question` tag.

Credits
-------

* [Markus Schirp (mbj)](https://github.com/mbj)
* A [gist](https://gist.github.com/1065789) from [dkubb](https://github.com/dkubb) showing ideas.
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
