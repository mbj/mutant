# frozen_string_literal: true

Mutant::Meta::Example.add :float do
  source '10.0'

  singleton_mutations

  # edge cases
  mutation '0.0'
  mutation '1.0'
  mutation '(0.0 / 0.0)'
  mutation '(1.0 / 0.0)'
  mutation '(-1.0 / 0.0)'

  # negative
  mutation '-10.0'
end

Mutant::Meta::Example.add :float do
  source '0.0'

  singleton_mutations
  mutation '1.0'
  mutation '(0.0 / 0.0)'
  mutation '(1.0 / 0.0)'
  mutation '(-1.0 / 0.0)'
end

Mutant::Meta::Example.add :float do
  source '-0.0'

  singleton_mutations
  mutation '1.0'
  mutation '(0.0 / 0.0)'
  mutation '(1.0 / 0.0)'
  mutation '(-1.0 / 0.0)'
end
