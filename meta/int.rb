# frozen_string_literal: true

Mutant::Meta::Example.add :int do
  source '10'

  singleton_mutations

  # edge cases
  mutation '0'
  mutation '1'

  # negative
  mutation '-10'

  # scalar boundary
  mutation '9'
  mutation '11'
end
