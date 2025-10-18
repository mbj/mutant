# frozen_string_literal: true

Mutant::Meta::Example.add :module do
  source 'module Foo; bar; end'

  mutation 'module Foo; nil; end'
end

Mutant::Meta::Example.add :module do
  source 'module Foo; end'
end
