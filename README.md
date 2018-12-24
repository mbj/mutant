mutant
======

[![Build Status](https://circleci.com/gh/mbj/mutant.svg?style=shield&circle-token=1afd77e8f0f9d0a11fd8f15f5d7b10270f4665e2)](https://circleci.com/gh/mbj/mutant/tree/master)
[![Code Climate](https://codeclimate.com/github/mbj/mutant.svg)](https://codeclimate.com/github/mbj/mutant)
[![Inline docs](http://inch-ci.org/github/mbj/mutant.svg)](http://inch-ci.org/github/mbj/mutant)
[![Gem Version](https://img.shields.io/gem/v/mutant.svg)](https://rubygems.org/gems/mutant)
[![Slack Status](https://mutation-testing-slack.herokuapp.com/badge.svg)](https://mutation-testing.slack.com/messages/mutant)

## What is Mutant?

Mutant is a mutation testing tool for Ruby. Mutation testing is a technique to verify semantic coverage of your code.

## Why do I want it?

Mutant adds to your toolbox: Detection of uncovered semantics in your code.
Coverage becomes a meaninful metric!

On each detection of uncovered semantics you have the opportunity to:

* Delete dead code, as you do not want the extra semantics not specified by the tests
* Add (or improve a test) to cover the unwanted semantics.
* Learn something new about the semantics of Ruby and your direct and indirect dependencies.

## How Do I use it?

* Start with reading the [nomenclature](/docs/nomenclature.md) documentation.
* Than select and setup your [integration](/docs/nomenclature.md#interation), also make sure
  you can reproduce the examples in the integration specific documentation.
* Identify your preferred mutation testing strategy. Its recommended to start at the commit level,
  to test only the code you had been touching. See the [incremental](#only-mutating-changed-code)
  mutation testing documentation.

Mutant uses a pure Ruby [parser](https://github.com/whitequark/parser) and an [unparser](https://github.com/mbj/unparser)
to do its magic.

Topics
------

* [Nomenclature](/docs/nomenclature.md)
* [Reading Reports](/docs/reading-reports.md)
* [Known Problems](/docs/known-problems.md)
* [Limitations](/docs/limitations.md)
* [Concurrency](/docs/concurrency.md)
* [Rspec Integration](/docs/mutant-rspec.md)
* [Minitest Integration](/docs/mutant-minitest.md)

Sponsoring
----------

Mutant, as published in the opensource version, would not exist without the help
of [contributors](https://github.com/mbj/mutant/graphs/contributors) spending lots
of their private time.

Additionally, the following features where sponsored by organizations:

* The `mutant-minitest` integration was sponsored by [Arkency](https://arkency.com/)
* Mutant's initial concurrency support was sponsored by an undisclosed company that does
  currently not wish to be listed here.

If your organization is interested in sponsoring a feature, general maintainership or bugfixes, contact
[Markus Schirp](mailto:mbj@schirp-dso.com).

Mutation-Operators
------------------

Mutant supports a wide range of mutation operators. An exhaustive list can be found in the [mutant-meta](https://github.com/mbj/mutant/tree/master/meta).
The `mutant-meta` is arranged to the AST-Node-Types of parser. Refer to parsers [AST documentation](https://github.com/whitequark/parser/blob/master/doc/AST_FORMAT.md) in doubt.

There is no easy and universal way to count the number of mutation operators a tool supports.

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
bundle exec mutant --include lib --require virtus --since master --use rspec Virtus::Attribute#type
```

Note that this feature requires at least git `2.13.0`.

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
