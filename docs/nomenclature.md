Nomenclature
============

This document explains several nouns you may experience in mutant's
documentation.  It's a good idea to familiarize yourself before moving on.

## Mutation Testing
The practice of systematically applying small changes one at a time to a
codebase then re-running the (relevant) tests for each change. If the tests
fail, then they cover the semantics of those changes. If the tests continue to
pass with the changes in place, the tests do not cover the complete semantics of
the changed parts of the codebase.

Each type of change (for example, `a && b` to `a`) is known as a
[Mutation](#mutation), and is applied to the pristine codebase - that is, the
changes are not stacked up, but applied in isolation. The places in the code
where the changes can be made are called [Subjects](#subject). The changed
Subject is then referred to (potentially confusingly) as a Mutant, or sometimes
a Mutation.

Mutation testing can be useful for suggesting semantic simplifications to your
code, as well as highlighting gaps in your tests as you are writing them.

## AST

Acronym for [Abstract Syntax Tree][AST] and the level of abstraction mutant
operates on. In short, this is a representation of the structure and content of
your code stored in memory which mutant alters.

[AST]: https://en.wikipedia.org/wiki/Abstract_syntax_tree

## Subject

An addressable piece of code to be targeted for mutation testing.

Mutant currently supports the following subjects:

* Instance methods
* Singleton (class) methods

Other subjects are possible (even project-specific subjects) but aren't
implemented in the OSS version. Some examples are:
* Constants
* Class bodies for DSLs

The more subjects that mutant can alter in your project, the more mutations it
can create, and so the higher the confidence you can have that your tests cover
the semantics of your application. Please get in touch if you require subjects
beyond those implemented in Mutant already - support may be available in the
commercial version.

## Mutation

An alteration to your codebase. Each mutation represents a hypothesis that
ideally gets falsified by the tests. Some examples of mutations and the
hypotheses they represent:

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

### Categories of mutation
Mutations broadly fall into a couple of categories. There is no reason to
deliberately seek to learn these categories (there’s no quiz at the end of this
semester!) - we’re just providing them to give you some ideas of what high-level
classes of changes mutant makes to your code. For a full list of all the types
of mutation that mutant can perform, see the code in the [meta directory][meta]

**Evil** mutations are mutations which should cause the test suite to fail,
while **neutral** mutations are expected not to break the test suite.
[No-ops](#no-op) are the only form of neutral mutation in mutant - all others
are evil.

[meta]: https://github.com/mbj/mutant/tree/master/meta

#### Semantic Reduction

This type of transformation replaces a piece of code which has somewhat complex
semantics with one that has simpler semantics. To aid understanding, here are a
couple of different sub-categories you could put them into.

* **Method call replacement**

    Example:

    ```ruby
    num == 1
    # gets replaced by
    num.eql?(1)
    ```

    `#==` commonly performs conversion between types in addition to checking
    equality, while `#eql?`  tends to check only that the class and instance
    variables are equal. (sticking with numbers, `1 == 1.0`, but `!1.eql?(1.0)`)
    Therefore, `#== -> #eql?` is a semantic reduction.

    You could also think of a semantic reduction in these cases as an increase
    in “strictness” of the code. `#equal?` (object identity) is a stricter
    equality test than `#eql?`, which is stricter than `#==`.

* **Code removal**

    Example:

     ```ruby
     def my_method
       if some_condition?
         do_something
       end
     end

     # replaced by

     def my_method
     end
     ```

    It's arguable whether or not this is its own category - we include it only
    to show that entire chunks of code are removed in some mutations performed
    by mutant. These mutations make mutant the ultimate ruby dead code finder!

* **Interface reduction**

    Example:

    ```ruby
    def join2(one, two, options)
      one + two
    end

    # replaced by

    def join2(one two)
      one + two
    end
    ```

#### Orthogonal Replacement
Example:

```ruby
def true?
  a.equal?(true)
end

def true?
  a.equal?(false)
end
```

Unlike semantic reduction, where the result is a simpler or stricter version of
the input, an orthogonal replacement changes code with a given function into
code which does something quite different (usually the opposite, or a different
value of the same type). This category is probably better understood by
examples:
   * `true` -> `false`
   * `#>` -> `#<`

These mutations are less frequent, owing to their relative lack of use as
suggestions for dead code removal or code simplification. The category really
only exists to include constant replacements such as `true` -> `false` - which
is needed to ensure that you have tested that `true` is indeed the required
value in that circumstance.

#### **No-Op**

This type of mutation makes no changes to the code, but performs the test
execution in exactly the same way as an "evil" mutation It is needed in order
to ensure that mutant’s presence, and prior mutations’ side effects, do not
cause the test suite to fail.

A no-op mutation is added at the beginning of the mutation test run (to ensure
that using mutant alone doesn't cause the test suite to fail)

## Insertion

The process of inserting a mutation into the runtime environment.
Mutant currently supports insertion via dynamically created monkeypatches.

Other insertion strategies (such as "boot time") are possible but aren't
implemented in the OSS version.

## Isolation

The attempt to isolate the (side) effects of killing a mutation via an
integration to prevent a mutation leaking into adjacent concurrent, or future
mutations.

Examples of sources for leaks are

* Global variable writes
* Thread local writes
* DB State
* File system

Natively, mutant offers fork isolation. This works for any state within the
executing Ruby process. For all state reachable via IO, it's the test author's
responsibility to provide proper isolation (for example, by wrapping tests which
touch the database in a transaction)

## Integration

The method used to determine if a specific inserted mutation is covered by
tests.

Currently mutant supports integrations for:

* [mutant-rspec](/docs/mutant-rspec.md) for [rspec][rspec]
* [mutant-minitest](/docs/mutant-minitest.md) for [minitest][minitest]

[rspec]: https://rspec.info
[minitest]: https://github.com/seattlerb/minitest

## Report

Mutant currently provides two different reporters:

* Progress (printed during mutation testing).
* Summary (printed at the end of a finished analysis run)

A reporter producing a machine readable report does not exist in the OSS version
at the time of writing this documentation.

See the [reading-reports.md](./reading-reports.md) file for documentation on the
information provided by those reports.
