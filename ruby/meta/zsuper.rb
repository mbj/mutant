# frozen_string_literal: true

# Method with arguments - should emit super() mutation
Mutant::Meta::Example.add :zsuper, :def do
  source 'def foo(a); super; end'

  mutation 'def foo(a); end'
  mutation 'def foo(a); nil; end'
  mutation 'def foo(a); super(); end'
  mutation 'def foo(a); raise; end'
end

# Method without arguments - should NOT emit super() mutation
# because super and super() are semantically equivalent
Mutant::Meta::Example.add :zsuper, :def do
  source 'def foo; super; end'

  mutation 'def foo; end'
  mutation 'def foo; nil; end'
  mutation 'def foo; raise; end'
end

# Nested super with arguments - tests parent chain traversal
Mutant::Meta::Example.add :zsuper, :def, :if do
  source 'def foo(a); if bar; super; end; end'

  mutation 'def foo(a); raise; end'
  mutation 'def foo(a); super; end'
  mutation 'def foo(a); end'
  mutation 'def foo(a); nil; end'
  mutation 'def foo(a); if nil; super; end; end'
  mutation 'def foo(a); if true; super; end; end'
  mutation 'def foo(a); if false; super; end; end'
  mutation 'def foo(a); if bar; nil; end; end'
  mutation 'def foo(a); if bar; super(); end; end'
end

# Nested super without arguments - should NOT emit super() mutation
Mutant::Meta::Example.add :zsuper, :def, :if do
  source 'def foo; if bar; super; end; end'

  mutation 'def foo; raise; end'
  mutation 'def foo; super; end'
  mutation 'def foo; end'
  mutation 'def foo; nil; end'
  mutation 'def foo; if nil; super; end; end'
  mutation 'def foo; if true; super; end; end'
  mutation 'def foo; if false; super; end; end'
  mutation 'def foo; if bar; nil; end; end'
  # No super() mutation here - method has no arguments
end

# Singleton method with arguments - should emit super() mutation
Mutant::Meta::Example.add :zsuper, :defs do
  source 'def self.foo(a); super; end'

  mutation 'def self.foo(a); end'
  mutation 'def self.foo(a); nil; end'
  mutation 'def self.foo(a); super(); end'
  mutation 'def self.foo(a); raise; end'
end

# Singleton method without arguments - should NOT emit super() mutation
Mutant::Meta::Example.add :zsuper, :defs do
  source 'def self.foo; super; end'

  mutation 'def self.foo; end'
  mutation 'def self.foo; nil; end'
  mutation 'def self.foo; raise; end'
end
