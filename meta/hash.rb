# frozen_string_literal: true

Mutant::Meta::Example.add :hash do
  source '{true => true, false => false}'

  singleton_mutations

  # Mutation of each key and value in hash
  mutation '{ false => true  ,  false => false }'
  mutation '{ true  => false ,  false => false }'
  mutation '{ true  => true  ,  true  => false }'
  mutation '{ true  => true  ,  false => true  }'

  # Remove each key once
  mutation '{ true => true }'
  mutation '{ false => false }'

  # Empty hash
  mutation '{}'
end
