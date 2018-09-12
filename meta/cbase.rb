# frozen_string_literal: true

Mutant::Meta::Example.add :cbase do
  source '::A'

  singleton_mutations
  mutation 'A'
end
