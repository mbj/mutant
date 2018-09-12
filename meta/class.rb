# frozen_string_literal: true

Mutant::Meta::Example.add :class do
  source 'class Foo; bar; end'

  mutation 'class Foo; nil; end'
  mutation 'class Foo; self; end'
  mutation 'module Foo; bar; end'
end

Mutant::Meta::Example.add :class do
  source 'class Foo; end'

  mutation 'module Foo; end'
end

Mutant::Meta::Example.add :class do
  source 'class Foo < Baz; end'

  mutation 'module Foo; end'
end
