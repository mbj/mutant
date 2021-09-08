Mutant’s Mutation Operators
===

This directory contains all the [Mutation Operators](../docs/nomenclature.md#mutation-operator)[^mutation-operator] that Mutant can apply.

The filenames mostly correspond to the names of code elements as used by the [parser](https://github.com/whitequark/parser) and [unparser](https://github.com/mbj/unparser) libraries. For the most part they are the same as keywords within Ruby, but here are some explanations of the less obvious ones:

* `str` and `sym` are string and symbol literals that do not contain dynamic elements (`"I'm a dstring #{i_am_the_dynamic_element}"`)
    * `dst` and `dsym` are the equivalents for strings and symbols which do
* `regexp` is a regular expression without any options (`/like this/`)
    * `regopt` is a regular expression with options (`/like this/i`)
* a few come in regular and `-asgn` variants - the latter are the assignment versions. E.g., `||=` is the assignment version (`or_asgn.rb`) of `||`  (`or.rb`)
* `gvar`, `cvar`, `ivar` and `lvar` refer to global (`$VERBOSE`), class (`@@debug`), instance (`@amount`) and local (`response`) variables, respectively.
* `csend` is the conditional send operator (`&.`)
* `cbase` is a top-level constant (`::Kernel` or `::Errno::ENOENT`), whereas `const` is a "normal" constant (`Kernel` or `Errno::ENOENT`)
* `casgn` is an assignment to a constant (`VERSION = "0.1.0"`)

All the files in this directory use a fairly simple DSL. To explain it, let's run through (a slightly modified version of) `return.rb`:

```ruby
# Adds an example matching expressions like `return foo`, where foo
# can be anything. In parser's s-expression DSL, this would match
# `s(:return, s(...))`, but not the simpler `s(:return)`.
Mutant::Meta::Example.add :return do
  # Each Example can only have one source, which provides a pattern to match
  source 'return foo'

  # multiple `mutation`s are provided. Each is simply a ruby 
  # source-code representation of the code after the change, using
  # the same placeholders as the source
  mutation 'foo' # replaces `return foo` with `foo`
  mutation 'return nil' # replaces `return nil` with `nil`
  mutation 'return self' # replaces `return foo` with `return self`
end

# This Example matches the simpler `s(:return)` case (or simply, 
# `return` expressions)
Mutant::Meta::Example.add :return do
  source 'return'

  # singleton_mutations is a convenience method for the following:
  #     mutation 'nil'
  #     mutation 'self'
  # This just helps ensure consistency throughout - a very large
  # number of expressions can be usefully mutated to `nil` or `self`
  singleton_mutations
end
```

[^mutation-operator]: Remember, Mutation Operator just means “a change that can be applied to the code”