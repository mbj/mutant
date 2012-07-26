mutant
======

[![Build Status](https://secure.travis-ci.org/mbj/mutant.png?branch=master)](http://travis-ci.org/mbj/mutant)
[![Dependency Status](https://gemnasium.com/mbj/mutant.png)](https://gemnasium.com/mbj/mutant)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/mbj/mutant)

Mutant is a mutation testing tool for ruby under rubinius.

The idea is that if code can be changed and your tests don't notice, either that code isn't being covered or it doesn't do anything.

Mutants idea is based on [heckle](https://github.com/seattlerb/heckle).
The motivation is from reading the other [mutants code](https://github.com/txus/mutant).
The idea an concept is from this [gist](https://gist.github.com/1065789).

Installation
------------

There is no gem release and the code is under development and unusable.

Examples
--------

Credits
-------

* Justin Ko ([justinko] (https://github.com/justinko))
* Josep M. Bach ([txus](https://github.com/txus))
* Dan Kubb ([dkubb](https://github.com/dkubb))

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
