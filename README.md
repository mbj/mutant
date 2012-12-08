mutant
======

[![Build Status](https://secure.travis-ci.org/mbj/mutant.png?branch=master)](http://travis-ci.org/mbj/mutant)
[![Dependency Status](https://gemnasium.com/mbj/mutant.png)](https://gemnasium.com/mbj/mutant)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/mbj/mutant)

Mutant is a mutation testing tool for ruby that aims to be better than existing mutation testers.

The idea is that if code can be changed and your tests do not notice, either that code isn't being covered 
or it doesn't do anything (useful).

Mutant does currently only support 1.9 mode under rubinius or mri. It is a young project but already 
used in the DataMapper-2.0 project.

Installation
------------

Install the gem ``mutant`` via your preferred method.

Examples
--------

```
cd your_lib
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
Mutant currently has the following buildin strategies

### --rspec-dm2

This strategy is the *fastest* but requires discipline in spec file naming.

The following specs are executed to kill a mutation on:
```
Public instance  methods: spec/unit/#{namespace}/#{class_name}/#{method_name}_spec.rb
Public singleton methods: spec/unit/#{namespace}/#{class_name}/class_methods/#{method_name}_spec.rb
Public instance  methods: spec/unit/#{namespace}/#{class_name}/
Public singleton methods: spec/unit/#{namespace}/#{class_name}/class_methods
```

### --rspec-unit

This strategy executes all specs under ``./spec/unit`` for each mutation.

### --rspec-integration

This strategy executes all specs under ``./spec/integration`` for each mutation.

### --rspec-full

This strategy executes all specs under ``./spec`` for each mutation.

It is also plannned to allow explicit selections on specs to run and to support other test frameworks.
Custom project specific strategies are also on the roadmap.

Credits
-------

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

Copyright (c) 2012 Markus Schirp

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
