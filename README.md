mutant
======

[![Build Status](https://secure.travis-ci.org/mbj/mutant.png?branch=master)](http://travis-ci.org/mbj/mutant)
[![Dependency Status](https://gemnasium.com/mbj/mutant.png)](https://gemnasium.com/mbj/mutant)
[![Code Climate](https://codeclimate.com/github/mbj/mutant.png)](https://codeclimate.com/github/mbj/mutant)

Mutant is a mutation testing tool for ruby.

The idea is that if code can be changed and your tests do not notice, either that code isn't being covered
or it does not have a speced side effect.

A more readable introduction can be found under: http://solnic.eu/2013/01/23/mutation-testing-with-mutant.html

Mutant supports MRI and RBX 1.9 and 2.0, while support for jruby is planned. It should also work under
any ruby engine that supports POSIX-fork(2) semantics.

Only rspec2 is supported currently. This is subject to change.

It is easy to write a mutation killer for other test/spec frameworks than rspec2.
Just create your own Mutant::Killer subclass, and make sure I get a PR!

See this [ASCII-Cast](http://ascii.io/a/1707) for mutant in action! (v0.2.1)

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
* various small/minor stuff under https://github.com/mbj

Feel free to ping me to add your project to the list!

Installation
------------

Install the gem `mutant` via your preferred method.

The 0.2 series is stable but has outdated dependencies. The 0.3 series is in beta phase currently.

```ruby
gem install mutant --pre
```

Mutations
---------

Mutant supports a very wide range of mutation operators. Listing them all in detail would blow this document up.

It is planned to parse a list of mutation operators from the source. In the meantime please refer to the
[code](https://github.com/mbj/mutant/tree/master/lib/mutant/mutator/node) each subclass of `Mutant::Mutator::Node`
emits around 3-6 mutations.

Currently mutant covers the majority of ruby's complex nodes that often occur in method bodies.

A some stats from the [axiom](https://github.com/dkubb/axiom) library:

```
Subjects:  417       # Amount of subjects being mutated (currently only methods)
Mutations: 5442      # Amount of mutations mutant generated (~13 mutations per method)
Kills:     5385      # Amount of successfully killed mutations
Runtime:   1898.11s  # Total runtime
Killtime:  1884.17s  # Time spend killing mutations
Overhead:  0.73%
Coverage:  98.95%    # Coverage score
Alive:     57        # Amount of alive mutations.
```


Nodes still missing a dedicated mutator are handled via the
[Generic](https://github.com/mbj/mutant/blob/master/lib/mutant/mutator/node/generic.rb) mutator.
The goal is to remove this mutator and have dedicated mutator for every type of node and removing
the Generic handler altogether.

Examples
--------

CLI will be simplified in the next releases, but currently stick with this:

```
cd virtus
# Run mutant on virtus namespace (that uses the dm-2 style spec layout)
mutant --rspec-dm2 '::Virtus*'
# Run mutant on specific virtus class
mutant --rspec-dm2 ::Virtus::Attribute
# Run mutant on specific virtus class method
mutant --rspec-dm2 ::Virtus::Attribute.build
# Run mutant on specific virtus instance method
mutant --rspec-dm2 ::Virtus::Attribute#name
```

Strategies
----------

Mutation testing is slow. The key to making it fast is selecting the correct set of tests to run.
Mutant currently supports the following built-in strategies for selecting tests/specs.

### --rspec-dm2

This strategy is the *fastest* but requires discipline in spec file naming.

The following specs are executed to kill a mutation on:
```
Public instance  methods: spec/unit/#{namespace}/#{class_name}/#{method_name}_spec.rb
Public singleton methods: spec/unit/#{namespace}/#{class_name}/class_methods/#{method_name}_spec.rb
Private instance  methods: spec/unit/#{namespace}/#{class_name}/*_spec.rb
Private singleton methods: spec/unit/#{namespace}/#{class_name}/class_methods/*_spec.rb
```

#### Expansions:

Symbolic operator-like methods are expanded, e.g. ```Foo#<<``` is expanded to:
```
spec/unit/foo/left_shift_operator_spec.rb
````

The full list of expansions can be found here:

https://github.com/mbj/mutant/blob/master/lib/mutant/constants.rb

### --rspec-unit

This strategy executes all specs under ``./spec/unit`` for each mutation.

### --rspec-integration

This strategy executes all specs under ``./spec/integration`` for each mutation.

### --rspec-full

This strategy executes all specs under ``./spec`` for each mutation.

In the future, we plan on allowing explicit selections on the specs to be run, as well as support for other test frameworks.
Custom project specific strategies are also on the roadmap.

Alternatives
------------

* [heckle](https://github.com/seattlerb/heckle)

Support
-------

I'm very happy to receive/answer feedback/questions and critism.

Your options:

* GitHub Issues https://github.com/mbj/mutant/issues
* Ping me on https://twitter.com/_m_b_j_
* #mutant channel on freenode, I hang around on CET daytimes. (nick mbj) 
  You'll also find others [ROM](https://github.com/rom-rb) team members here that can answer questions.

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
