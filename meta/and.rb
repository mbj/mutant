# frozen_string_literal: true

Mutant::Meta::Example.add :and do
  source 'true and false'

  singleton_mutations
  mutation 'true'
  mutation 'false'
  mutation 'true or false'
  mutation 'false and false'
  mutation 'true and true'
end
