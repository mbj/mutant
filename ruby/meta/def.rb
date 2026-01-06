# frozen_string_literal: true

Mutant::Meta::Example.add :def do
  source 'def foo; end'

  mutation 'def foo; raise; end'
  mutation 'def foo; super; end'
end

Mutant::Meta::Example.add :def do
  source 'def foo; foo; rescue; end'

  mutation 'def foo; raise; end'
  mutation 'def foo; nil; rescue; end'
  mutation 'def foo; end'
  mutation 'def foo; super; end'

  # Promote rescue resbody bodies
  mutation 'def foo; foo; end'
end

Mutant::Meta::Example.add :def do
  source 'def a; foo; rescue; bar; else; baz; end'

  # Mutate all bodies
  mutation 'def a; nil;  rescue; bar; else; baz; end'
  mutation 'def a; foo; rescue; nil;  else; baz; end'
  mutation 'def a; foo; rescue; bar; else; nil; end'

  # Promote and concat rescue resbody bodies
  mutation 'def a; foo; bar; end'

  # Promote and concat else body
  mutation 'def a; foo; baz; end'

  # Promote rescue body
  mutation 'def a; foo; end'

  # Empty body
  mutation 'def a; end'

  # Failing body
  mutation 'def a; raise; end'

  # Superclass implementation
  mutation 'def a; super; end'
end

Mutant::Meta::Example.add :def do
  source 'def foo; true; false; end'

  # Mutation of each statement in block
  mutation 'def foo; true; true; end'
  mutation 'def foo; false; false; end'

  # Remove statement in block
  mutation 'def foo; true; end'
  mutation 'def foo; false; end'

  # Remove all statements
  mutation 'def foo; end'

  mutation 'def foo; raise; end'

  mutation 'def foo; super; end'
end

Mutant::Meta::Example.add :def do
  source 'def foo(a, b); end'

  # Mutation of body
  mutation 'def foo(a, b); raise; end'
  mutation 'def foo(a, b); super; end'
end

Mutant::Meta::Example.add :def do
  source 'def foo(a, b = nil); true; end'

  mutation 'def foo(a, b = nil); end'
  mutation 'def foo(a, b = nil); raise; end'
  mutation 'def foo(a, b = nil); false; end'
  mutation 'def foo(a, b = nil); b = nil; true; end'
  mutation 'def foo(a, b); true; end'
  mutation 'def foo(a, b = nil); super; end'
end

Mutant::Meta::Example.add :def do
  source 'def foo(a = 0, b = 0); end'
  mutation 'def foo(a = 0, b = 1); end'
  mutation 'def foo(a = 0, b = -1); end'
  mutation 'def foo(a = 0, b = nil); end'
  mutation 'def foo(a = -1, b = 0); end'
  mutation 'def foo(a = nil, b = 0); end'
  mutation 'def foo(a = 1, b = 0); end'
  mutation 'def foo(a, b = 0); end'
  mutation 'def foo(a = 0, b = 0); a = 0; end'
  mutation 'def foo(a = 0, b = 0); b = 0; end'
  mutation 'def foo(a = 0, b = 0); raise; end'
  mutation 'def foo(a = 0, b = 0); super; end'
end

Mutant::Meta::Example.add :def do
  source 'def foo(a = true); end'

  mutation 'def foo(a); end'
  mutation 'def foo(a = false); end'
  mutation 'def foo(a = true); raise; end'
  mutation 'def foo(a = true); a = true; end'
  mutation 'def foo(a = true); super; end'
end

Mutant::Meta::Example.add :def do
  source 'def self.foo; true; false; end'

  # Body presence mutation
  mutation 'def self.foo; false; false; end'
  mutation 'def self.foo; true; true; end'

  # Body presence mutation
  mutation 'def self.foo; true; end'
  mutation 'def self.foo; false; end'

  # Remove all statements
  mutation 'def self.foo; end'

  mutation 'def self.foo; raise; end'

  mutation 'def self.foo; super; end'
end

Mutant::Meta::Example.add :def do
  source 'def self.foo(a, b); end'

  # Mutation of body
  mutation 'def self.foo(a, b); raise; end'
  mutation 'def self.foo(a, b); super; end'
end

Mutant::Meta::Example.add :def do
  source 'def foo(...); end'

  mutation 'def foo(...); raise; end'
  mutation 'def foo(...); super; end'
end

if RUBY_VERSION >= '3.2'
  Mutant::Meta::Example.add :def do
    source 'def foo(*); bar(*); end'

    mutation 'def foo(*); raise; end'
    mutation 'def foo(*); super; end'
    mutation 'def foo(*); end'
    mutation 'def foo(*); nil; end'
    mutation 'def foo(*); bar; end'
  end

  Mutant::Meta::Example.add :def do
    source 'def foo(**); bar(**); end'

    mutation 'def foo(**); raise; end'
    mutation 'def foo(**); super; end'
    mutation 'def foo(**); end'
    mutation 'def foo(**); nil; end'
    mutation 'def foo(**); bar; end'
  end

  Mutant::Meta::Example.add :hash do
    source 'def foo(**); { default: nil, ** }; end'

    mutation 'def foo(**); end'
    mutation 'def foo(**); nil; end'
    mutation 'def foo(**); raise; end'
    mutation 'def foo(**); super; end'
    mutation 'def foo(**); { ** }; end'
    mutation 'def foo(**); { default: nil }; end'
    mutation 'def foo(**); { default__mutant__: nil, ** }; end'
    mutation 'def foo(**); {}; end'
  end

  if RUBY_VERSION <= '3.3'
    Mutant::Meta::Example.add :hash do
      source 'def foo(**); bar { { ** } }; end'

      mutation 'def foo(**); bar { nil }; end'
      mutation 'def foo(**); bar { raise }; end'
      mutation 'def foo(**); bar { {} }; end'
      mutation 'def foo(**); bar { }; end'
      mutation 'def foo(**); bar; end'
      mutation 'def foo(**); end'
      mutation 'def foo(**); nil; end'
      mutation 'def foo(**); raise; end'
      mutation 'def foo(**); super; end'
      mutation 'def foo(**); { ** }; end'
    end

    Mutant::Meta::Example.add :hash do
      source 'def foo(*); bar { boz(*) }; end'

      mutation 'def foo(*); bar { boz }; end'
      mutation 'def foo(*); bar { nil }; end'
      mutation 'def foo(*); bar { raise }; end'
      mutation 'def foo(*); bar { }; end'
      mutation 'def foo(*); bar.boz(*); end'
      mutation 'def foo(*); bar; end'
      mutation 'def foo(*); boz(*); end'
      mutation 'def foo(*); end'
      mutation 'def foo(*); nil; end'
      mutation 'def foo(*); raise; end'
      mutation 'def foo(*); super; end'
    end
  end
end

Mutant::Meta::Example.add :def do
  source 'def foo(&); bar(&); end'

  mutation 'def foo(&); raise; end'
  mutation 'def foo(&); super; end'
  mutation 'def foo(&); end'
  mutation 'def foo(&); nil; end'
  mutation 'def foo(&); bar; end'
end

Mutant::Meta::Example.add :def do
  source 'def foo(a, ...); end'

  mutation 'def foo(a, ...); raise; end'
  mutation 'def foo(a, ...); super; end'
end

Mutant::Meta::Example.add :def, :send do
  source 'def foo(...); bar(...) end'

  mutation 'def foo(...); bar; end'
  mutation 'def foo(...); raise; end'
  mutation 'def foo(...); super; end'
  mutation 'def foo(...); nil; end'
  mutation 'def foo(...); end'
end
