# AST-Pattern

Mutant ships with an AST pattern matching language.

This language is currently only used to define ignore patterns for
mutation generation but is targeted to also be used for mutation
definition. This language has no name yet, but can be considered a
currently quite limited "CSS for AST patterns".

The language is whitespace insensitive, so feel free to not follow
the "newline heavy" examples in this code.

### Quick example:

```
send{selector=(log,info)}
```

This pattern matches each of the following lines:

```
logger.log("some message")
log("message")
info("some info")
```

In case only the first line should be matched, the pattern would have to be more
specific:

```
send
  { selector = info
    receiver = send{selector=logger}
  }
```

This adds an additional descendant constraint on the receiver.

### Structure

The pattern langauge is structured around AST nodes of the
[parser gem](https://github.com/whitequark/parser/blob/master/doc/AST_FORMAT.md).

Syntax (currently) always begins with a valid node type and than
constraints on its children within `{ child_name = child_pattern }` groups.

Each node can have 2 kinds of children: Attributes and descendants.

Attributes are values, such as selectors for sends, constant and variable identifiers.

Descendants are children that represent other descendant nodes,
such as receivers of method calls, if expression conditionals etc.

Currently grouping is only supported for attributes.

Future extensions of the syntax will allow alternating groups between nodes,
regexp on attribute values and literals. Also shorthands will be provided for
common matches.

An index of the named children can be found in mutants
[source code](https://github.com/mbj/mutant/blob/1301e3d31d520f1dc60f409cbe792067fecbed08/lib/mutant/ast/structure.rb#L114-L876), its planned to provide a more human friendly CLI introspection
of this data in future releases.

### More examples

Matching a logger statement with a block

```ruby
logger.log { "foo" }
```

Would be done with the following AST pattern:

```
block
  { receiver = send{selector=log}
  }
```

In this example the `logger` the `log` is called upon is not required.
But could be made required via:

```
block
  { receiver = send
    { selector = log
      receiver = send{selector=logger}
    }
  }
```
