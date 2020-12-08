Nomenclature
============

This document explains several nouns you may experience in mutant's documentation.
It's a good idea to familiarize yourself before moving on.

## Mutation Testing
The practice of systematically applying small changes one at a time to a codebase then re-running the (relevant) tests for each change. If the tests fail, then they cover the semantics of those changes. If the tests continue to pass with the changes in place, the tests do not cover the complete semantics of the changed parts of the codebase.

Each type of change (for example, “change `a && b` to `a`”) is known as a [Mutation Operator](#mutation-operator), and is applied to the pristine codebase - that is, the changes are not stacked up, but applied in isolation. The places in which the Mutation Operators can make their changes are called [Subjects](#subject). The changed Subject is then referred to as a [Mutation](#mutation).

Mutation testing can be useful for suggesting semantic simplifications to your code, as well as highlighting gaps in your tests as you are writing them.

## AST

Acronym for [Abstract Syntax Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree)
and the level of abstraction mutant operates on.
In short, this is a representation of the structure and content of your code
stored in memory which mutant alters.

## Subject

An addressable piece of code to be targeted for mutation testing.

Mutant currently supports the following subjects:

* Instance methods
* Singleton (class) methods

Other subjects are possible (even project-specific subjects) but aren't implemented in the OSS version. Please get in touch with the authors. Some examples are:
* Constants
* Class bodies for DSLs

The more subjects that mutant can alter in your project, the more mutations it can create, and so the higher your confidence you can have that your tests cover the semantics of your application. Please get in touch if you require subjects beyond those implemented in Mutant already - support may be available in the commercial version.

## Mutation Operator

A transformation applied to the AST of a subject. Mutant knows the following high level operator classes (you will not be tested on your knowledge of these terms)

Please be aware that there is no reason to learn these terms (there’s no quiz at the end of this semester!) - we’re just providing them to give you some ideas of what high-level classes of changes mutant makes to your code. For a full list of all the Mutation Operators in mutant, see the code in the [meta directory](https://github.com/mbj/mutant/tree/master/meta).

* **Semantic Reduction**

    This type of transformation replaces a piece of code which has somewhat complex semantics with one that has simpler semantics. To aid understanding, here are a couple of different sub-categories you could put them into. 
    
    * **Method call replacement** - for example, `#==` -> `#eql?` -> `#equal?`

        `#==` commonly performs conversion between types in addition to checking equality, while `#eql?`  tends to check only that the class and instance variables are equal. Therefore we would say that #== is semantically simpler.
        
        You could also think of a semantic reduction in these cases as an increase in “strictness” of the code. `#equal?` is a stricter equality test than `#eql?`, and so on
        
    * **Code removal** - For example, `def my_method; do_something; end` -> `def my_method; end`
     
        We could argue[^1] that this category includes all of the following:
        
        *  Removing a particular expression, from the AST entirely
        *  Replacing an expression with `nil`, or `true`, or `false`, or other simple literals.

    * **Interface reduction**

        TODO


[^1]: After all; these are not official terms handed down from an authority on mutation testing. We’ve invented them for the purposes of introducing the concepts here.

* **Orthogonal Replacement** - for example `>` -> `<`

   Unlike semantic reduction, where the result is a “simpler” version of the input, an orthogonal replacement transforms some code with a given function into code with a similar semantic complexity, but which does something different (usually opposite). This category is probably better understood by examples:
   * `true` -> `false`
   * `#>` -> `#<`
   
   These transformations are less common,
* **No-Op** - This type of operator does nothing. It is needed in order to ensure that mutant’s presence, and prior mutations’ side effects, do not cause the test suite to fail.

An exhaustive list can be found in the 
subdirectory of the source.

## Mutation

The result of applying a mutation operator to the AST of a subject. A mutation
represents a hypothesis that ideally gets falsified by the tests. Some example hypotheses:

```ruby
# before application of mutation operator
def equal_to_5?(number)
  number == 5
end

# after application of `#==` -> `#eql?`
# hypothesis: the conversion semantics of #== are not necessary for this method
def equal_to_5?
  number.eql?(5)
end

# after removal of `number == 5`
# hypothesis: that line of the method is dead code
def equal_to_5?; end

# after replacement of `number == 5` with `true`
# hypothesis: the tests only check the happy-path
def equal_to_5?(number)
  true
end
```

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
