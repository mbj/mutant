# frozen_string_literal: true

Mutant::Meta::Example.add :masgn do
  source 'a, b = nil, nil'

  singleton_mutations

  mutation 'a, b = nil'
  mutation 'a, b = []'
  mutation 'a, b = [nil]'
end
