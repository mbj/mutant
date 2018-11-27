Nomenclature
============

The following explains several nouns you may experience in mutant's documentation.
It's a good idea to familiarize yourself before moving on.

## AST

Acronym for [Abstract Syntax Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree)
and the level of abstraction mutant operates on.

## Subject

An addressable piece of code to be targeted for mutation testing.

Mutant currently supports the following subjects:

* Instance methods
* Singleton (class) methods

Other subjects (constants, class bodies for DSLs, ...) are possible but aren't
implemented in the OSS version.

## Mutation operator

A transformation applied to the AST of a subject. Mutant knows the following high level operator
classes:

* Semantic Reduction
* Orthogonal Replacement
* [Noop](#neutral-noop-tests)

An exhaustive list can be found in the [mutant-meta](https://github.com/mbj/mutant/tree/master/meta)
subdirectory of the source.

## Mutation

The result of applying a mutation operator to the AST of a subject. A mutation represents a
hypothesis that ideally gets falsified by the tests.

## Insertion

The process of inserting a mutation into the runtime environment.
Mutant currently supports insertion via dynamically created monkeypatches.

Other insertion strategies (such as "boot time") are possible but aren't implemented
in the OSS version.

## Isolation

The attempt to isolate the (side) effects of killing a mutation via an integration
to prevent a mutation leaking into adjacent concurrent, or future mutations.

Examples of sources for leaks are

* Global variable writes
* Thread local writes
* DB State
* File system

Natively, mutant offers fork isolation. This works for any state within the executing
Ruby process. For all state reachable via IO, it's the test author's responsibility to
provide proper isolation.

## Integration

The method used to determine if a specific inserted mutation is covered by tests.

Currently mutant supports integrations for:

* [mutant-rspec](/docs/mutant-rspec.md) for [rspec](https://rspec.info)
* [mutant-minitest](/docs/mutant-minitest.md) for [minitest](https://github.com/seattlerb/minitest)

## Report

Mutant currently provides two different reporters:

* Progress (printed during mutation testing).
* Summary (printed at the end of a finished analysis run)

A reporter producing a machine readable report does not exist in the OSS version
at the time of writing this documentation.
