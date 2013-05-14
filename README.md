mutant
======

[![Build Status](https://secure.travis-ci.org/mbj/mutant.png?branch=master)](http://travis-ci.org/mbj/mutant)
[![Dependency Status](https://gemnasium.com/mbj/mutant.png)](https://gemnasium.com/mbj/mutant)
[![Code Climate](https://codeclimate.com/github/mbj/mutant.png)](https://codeclimate.com/github/mbj/mutant)

Mutant is a mutation testing tool for ruby that aims to be better than existing mutation testers.

The idea is that if code can be changed and your tests do not notice, either that code isn't being covered
or it does not have a speced side effect.

Mutant does currently only support 1.9 mode under Rubinius or MRI. Support for JRuby is planned.

Also it is easy to write a mutation killer for other test/spec frameworks than rspec2.
Just create your own Mutant::Killer subclass, and make sure I get a PR!

See this [ASCII-Cast](http://ascii.io/a/1707) for mutant in action! (v0.2.1)

Projects using Mutant
---------------------

The following projects adopted mutant, and aim 100% mutation coverage:

* [axiom](https://github.com/dkubb/axiom)
* [axiom-types](https://github.com/dkubb/axiom-types)
* [dm-mapper](https://github.com/datamapper/dm-mapper)
* [event_bus](https://github.com/kevinrutherford/event_bus)
* [virtus](https://github.com/solnic/virtus)
* [quacky](https://github.com/benmoss/quacky)
* [substation](https://github.com/snusnu/substation)
* various small/minor stuff under https://github.com/mbj

Feel free to ping me to add your project to the list!

Installation
------------

Install the gem `mutant` via your preferred method.

Examples
--------

CLI will be simplified in the next releases, but currently stick with this:

```
cd virtus
# Run mutant on virtus namespace (that uses the dm-2 style spec layout)
mutant -I lib -r virtus --rspec-dm2 ::Virtus
# Run mutant on specific virtus class
mutant -I lib -r virtus --rspec-dm2 ::Virtus::Attribute
# Run mutant on specific virtus class method
mutant -I lib -r virtus --rspec-dm2 ::Virtus::Attribute.build
# Run mutant on specific virtus instance method
mutant -I lib -r virtus --rspec-dm2 ::Virtus::Attribute#name
```

Strategies
----------

Mutation testing is slow. To make it fast the selection of the correct set of tests to run is the key.
Mutant currently supports the following buildin strategies for selecting tests/specs.

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

Symbolic operator like method are expanded. So for example ```Foo#<<``` is expanded to:
```
spec/unit/foo/left_shift_operator_spec.rb
````

The full list of expansion can be found here:

https://github.com/mbj/mutant/blob/master/lib/mutant/constants.rb

### --rspec-unit

This strategy executes all specs under ``./spec/unit`` for each mutation.

### --rspec-integration

This strategy executes all specs under ``./spec/integration`` for each mutation.

### --rspec-full

This strategy executes all specs under ``./spec`` for each mutation.

It is also plannned to allow explicit selections on specs to run and to support other test frameworks.
Custom project specific strategies are also on the roadmap.

Alternatives
------------

* [heckle](https://github.com/seattlerb/heckle)

Support
-------

I'm very happy to receive/answer feedback/questions and critism.

Your options:

* Github Issue https://github.com/mutant/issues
* Ping me on https://twitter.com/_m_b_j_
* #datamapper channel on freenode, I hang around on CET daytimes. (nick mbj)

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
