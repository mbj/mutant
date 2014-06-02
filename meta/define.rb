# encoding: utf-8

Mutant::Meta::Example.add do
  source 'def foo; end'

  mutation 'def foo; raise; end'
end

Mutant::Meta::Example.add do
  source "def foo\nfoo\nrescue\nend"

  mutation 'def foo; raise; end'
  mutation 'def foo; nil; rescue; end'
  mutation 'def foo; end'
end

Mutant::Meta::Example.add do
  source 'def foo; true; false; end'

  # Mutation of each statement in block
  mutation 'def foo; true; true; end'
  mutation 'def foo; false; false; end'
  mutation 'def foo; true; nil; end'
  mutation 'def foo; nil; false; end'

  # Remove statement in block
  mutation 'def foo; true; end'
  mutation 'def foo; false; end'

  # Remove all statements
  mutation 'def foo; end'

  mutation 'def foo; raise; end'
end

Mutant::Meta::Example.add do
  source 'def foo(a, b); end'

  # Deletion of each argument
  mutation 'def foo(a); end'
  mutation 'def foo(b); end'

  # Deletion of all arguments
  mutation 'def foo; end'

  # Rename each argument
  mutation 'def foo(a__mutant__, b); end'
  mutation 'def foo(a, b__mutant__); end'

  # Mutation of body
  mutation 'def foo(a, b); raise; end'
end

Mutant::Meta::Example.add do
  source 'def foo(_unused); end'

  mutation 'def foo(_unused); raise; end'
  mutation 'def foo; end'
end

Mutant::Meta::Example.add do
  source 'def foo(_unused = true); end'

  mutation 'def foo(_unused = nil); end'
  mutation 'def foo(_unused = false); end'
  mutation 'def foo(_unused = true); raise; end'
  mutation 'def foo(_unused); end'
  mutation 'def foo; end'
end

Mutant::Meta::Example.add do
  source 'def foo(a = true); end'

  mutation 'def foo(a); end'
  mutation 'def foo(); end'
  mutation 'def foo(a = false); end'
  mutation 'def foo(a = nil); end'
  mutation 'def foo(a__mutant__ = true); end'
  mutation 'def foo(a = true); raise; end'
end

Mutant::Meta::Example.add do
  source 'def self.foo; true; false; end'

  # Body presence mutation
  mutation 'def self.foo; false; false; end'
  mutation 'def self.foo; true; true; end'
  mutation 'def self.foo; true; nil; end'
  mutation 'def self.foo; nil; false; end'

  # Body presence mutation
  mutation 'def self.foo; true; end'
  mutation 'def self.foo; false; end'

  # Remove all statements
  mutation 'def self.foo; end'

  mutation 'def self.foo; raise; end'
end

Mutant::Meta::Example.add do

  source 'def self.foo(a, b); end'

  # Deletion of each argument
  mutation 'def self.foo(a); end'
  mutation 'def self.foo(b); end'

  # Deletion of all arguments
  mutation 'def self.foo; end'

  # Rename each argument
  mutation 'def self.foo(a__mutant__, b); end'
  mutation 'def self.foo(a, b__mutant__); end'

  # Mutation of body
  mutation 'def self.foo(a, b); raise; end'
end
