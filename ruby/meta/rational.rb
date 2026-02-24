# frozen_string_literal: true

Mutant::Meta::Example.add :rational do
  source '10r'

  singleton_mutations

  mutation '0r'
  mutation '1r'
  mutation '11r'
  mutation '9r'
end
