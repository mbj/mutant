# frozen_string_literal: true

Mutant::Meta::Example.add :kwbegin do
  source 'begin; true; end'

  singleton_mutations
  mutation 'begin; false; end'
  mutation 'begin; nil; end'
end
