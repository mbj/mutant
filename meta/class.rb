# frozen_string_literal: true

Mutant::Meta::Example.add :class do
  source 'class Foo; bar; end'

  mutation 'class Foo; nil; end'
end

Mutant::Meta::Example.add :class do
  source 'class Foo; end'
end
